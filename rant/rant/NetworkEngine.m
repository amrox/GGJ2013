//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "NetworkEngine.h"

#import "Util.h"

static NSString *const GameUniqueIDKey = @"GameUniqueID";

NSString *const GameEngineGameBeginNotification = @"GameBegin";
NSString *const GameEngineGameEndNotification = @"GameEnd";

static int PlayerIDNum(NSString *playerID) {
    return [[playerID substringFromIndex:2] intValue];
}

static int MyPlayerNum() {
    return PlayerIDNum([GKLocalPlayer localPlayer].playerID);
}


#define kMaxPacketSize 1024
const float kHeartbeatTimeMaxDelay = 2.0f;
#define kHeartbeatMod (10)
#define kGameloopInterval (0.033)

typedef enum {
	kStateStartGame,
    kStateLobby,
	kStateServerElectBegin,
    kStateServerElectFinish,
    kStateMultiplayer,
    //	kStateMultiplayerReconnect
} gameStates;


typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_GAME_START,				// decide who is going to be the server
    NETWORK_EVENT,
    NETWORK_GAME_STATE,
} packetCodes;

@interface NetworkEngine ()

@property (strong, readwrite) GKMatch *match;
@property (assign) NSInteger gameState;
@property (strong) UIAlertView *connectionAlert;
@property (strong) NSMutableDictionary *playerInfo;
@property (assign, readwrite) GameState currentState;
@property (strong) NSString *serverPlayerID;
@property (assign, readwrite) BOOL isServer;
@property (strong) NSMutableArray *incomingEvents;

@end


@interface PlayerInfo : NSObject

@property (strong) NSNumber* cointoss;
@property (strong) NSString *playerID;
@property (strong) NSDate *lastHeartbeat;

@end

@implementation PlayerInfo
@end

@implementation NetworkEngine

+ (NetworkEngine *)sharedNetworkEngine
{
    static dispatch_once_t onceToken;
    static NetworkEngine *engine;
    dispatch_once(&onceToken, ^{
        engine = [[NetworkEngine alloc] init];
    });
    return engine;
}

- (id)init
{
    self = [super init];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:kGameloopInterval target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
        self.playerInfo = [NSMutableDictionary dictionaryWithCapacity:4];
        //        _eventQueue = dispatch_queue_create("eventqueue", NULL);
        self.incomingEvents = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
}

- (void)broadcastNetworkPacket:(GKMatch *)match packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend
{
    [self sendNetworkPacket:match packetID:packetID withData:data ofLength:length reliable:howtosend players:self.match.playerIDs];
}


- (void)sendNetworkPacket:(GKMatch *)match packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend players:(NSArray *)players {
    
    NSAssert([players count] > 1, @"no players");
    NSLog(@"sending to players: %@", players);
    
	// the packet we'll send is resued
	static unsigned char networkPacket[kMaxPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = _gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
        
        if (data != NULL) {
            memcpy( &networkPacket[packetHeaderSize], data, length );
        }
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) {
            [match sendData:packet toPlayers:players withDataMode:GKSendDataReliable error:nil];
		} else {
            [match sendData:packet toPlayers:players withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

- (void)electServer
{
    NSString *localPlayerID = [GKLocalPlayer localPlayer].playerID;
    
    NSString *serverPlayerID = localPlayerID;
    int serverPlayerIDNum = MyPlayerNum();
    
    NSLog(@"Local Player: %@", localPlayerID);
    
    for (NSString *playerID in self.match.playerIDs) {
        
        int playerNum = PlayerIDNum(playerID);
        if (playerNum > serverPlayerIDNum) {
            serverPlayerID = playerID;
        }
    }
    
//    NSArray *allPlayers = [self.playerInfo allValues];
//    for (PlayerInfo *info in allPlayers) {
//        
//        NSLog(@"Player: %@", info.playerID);
//        NSLog(@"Coin Toss: %d", [info.cointoss integerValue]);
//        
//        NSAssert(info.cointoss != nil, @"coin toss is nil!");
//        if ([info.cointoss intValue] > serverCointoss) {
//            serverPlayerID = info.playerID;
//        }
//    }
    
    self.serverPlayerID = serverPlayerID;
    self.isServer = [self.serverPlayerID isEqualToString:localPlayerID];
    
    NSLog(@"%@ is the server!", self.serverPlayerID);
}

- (void)processEvents
{
    NSValue *eventVal = nil;
    
    @synchronized(self.incomingEvents) {
        if ([self.incomingEvents count] > 0) {
            eventVal = [self.incomingEvents objectAtIndex:0];
            [self.incomingEvents removeObjectAtIndex:0];
            
        }
    }
    
    if (eventVal != nil) {
        GameEvent event;
        [eventVal getValue:&event];
        [self.engine processEvent:&event];
        
        GamePacket packet;
        packet.event = event;
        packet.state = self.engine.currentState;
        
        [self broadcastNetworkPacket:self.match packetID:NETWORK_GAME_STATE withData:&packet ofLength:sizeof(GamePacket) reliable:YES];
        
        [self.engine.delegate clientReceivedEvent:&packet.event withState:&packet.state];
    }
}

- (void)gameLoop
{
    static int counter = 0;
	switch (self.gameState) {
        case kStateLobby:
		case kStateStartGame:
			break;
		case kStateServerElectBegin:
			[self broadcastNetworkPacket:self.match packetID:NETWORK_GAME_START withData:NULL ofLength:sizeof(int) reliable:YES];
			self.gameState = kStateServerElectFinish; // we only want to be in the cointoss state for one loop
			break;
        case kStateServerElectFinish:
        {
            NSArray *allPlayers = [self.playerInfo allValues];
            if ([allPlayers count] == [[self.match playerIDs] count]) {
                
                BOOL hasAllCointosses = YES;
                for (PlayerInfo *info in allPlayers) {
                    hasAllCointosses &= info.cointoss != nil;
                }
                
                if (hasAllCointosses) {
                    NSLog(@"Has All Coin Tosses...");
                    [self electServer];
                    _gameState = kStateMultiplayer;
                }
            }
        }
            break;
            
		case kStateMultiplayer:
            if (self.serverPlayerID == nil) {
                [self electServer];
            }
            
            counter++;

//            if (counter & kHeartbeatMod) {
//                NSLog(@"players: %@", [self.match playerIDs]);
//            }
            
            if (self.isServer) {
                [self processEvents];
            }
			break;
		default:
			break;
	}
}

- (void)authenticate
{
    [self authenticateWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            PresentError(error);
        }
    }];
}

- (BOOL)isAuthenticated
{
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

- (void)authenticateWithCompletionHandler:(void(^)(NSError *error))completionHandler
{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:completionHandler];
    }
}

- (void)findMatch
{
    NSAssert([GKLocalPlayer localPlayer].isAuthenticated, @"not authenticated");
    
//    [self getGameUniqueID];
    
    [[GKMatchmaker sharedMatchmaker] cancel];
    
    [self end];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    self.gameState = kStateLobby;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            PresentError(error);
        }
        else if (match != nil)
        {
            NSLog(@"Match found! %@", match);
            self.match = match;
            match.delegate = self;
        }
    }];
}

- (PlayerInfo *)getInfoForPlayerID:(NSString *)playerID
{
    PlayerInfo *info = [self.playerInfo objectForKey:playerID];
    if (info == nil) {
        info = [[PlayerInfo alloc] init];
        info.playerID = playerID;
        [self.playerInfo setObject:info forKey:playerID];
    }
    return info;
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
	//
	// developer  check the network time and make sure packers are in order
	//
	int packetTime = pIntData[0];
	int packetID = pIntData[1];
	if(packetTime < lastPacketTime && packetID != NETWORK_GAME_START) {
		return;
	}
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_GAME_START:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            
            PlayerInfo *playerInfo = [self getInfoForPlayerID:playerID];
            playerInfo.cointoss = [NSNumber numberWithInt:coinToss];
            
            NSLog(@"player:%@ cointoss:%d", playerID, coinToss);
            
            if (_gameState == kStateLobby) {
                _gameState = kStateServerElectBegin;
            }
        }
			break;
            
        case NETWORK_EVENT:
        {
            NSAssert(self.isServer, @"only server should receive raw events");
            GameEvent *event = (GameEvent *)&incomingPacket[8];
            [self receiveEventAsServer:event];
        }
            break;
            
        case NETWORK_GAME_STATE:
        {
            NSAssert(!self.isServer, @"server should not receive state packets");
            GamePacket *packet = (GamePacket *)&incomingPacket[8];
            [self receivePacketAsClient:packet];
        }
            break;
    }
}

- (void)receiveEventAsServer:(GameEvent *)event
{
    @synchronized(self.incomingEvents) {
        NSValue *eventVal = [NSValue valueWithBytes:event objCType:@encode(GameEvent)];
        [self.incomingEvents addObject:eventVal];
    }
}

- (void)receivePacketAsClient:(GamePacket *)packet
{
    [self.engine.delegate clientReceivedEvent:&packet->event withState:&packet->state];
}


// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
    // Logging
    if(state == GKPeerStateConnected) {
        NSLog(@"player:%@ connected!", playerID);
    } else if (state == GKPeerStateDisconnected) {
        NSLog(@"player:%@ disconnected :(", playerID);
    }
    
	if(self.gameState == kStateLobby) {
        // only do stuff if we're in multiplayer, otherwise it is probably for Picker
        return;
	}
	
	if(state == GKPeerStateDisconnected) {
        NSString *message = [NSString stringWithFormat:@"Could not reconnect."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
        // !!!: self.connectionAlert = alert;
        [alert show];
        
        [self end];
	}
}


- (void)begin
{
    NSAssert(self.match, @"match is nil");
    NSAssert(self.match.expectedPlayerCount == 0, @"not enough players");
    self.gameState = kStateServerElectBegin;
    [[NSNotificationCenter defaultCenter] postNotificationName:GameEngineGameBeginNotification object:self];
}

- (void)end
{
    self.serverPlayerID = nil;
    self.match = nil;
    self.gameState = kStateStartGame;
}

- (BOOL) isMatchReady
{
    return self.match != nil && (self.match.expectedPlayerCount == 0);
}

- (void)sendEvent:(GameEvent *)event
{
    event->source = MyPlayerNum();
    
    if (!self.isServer) {
        NSAssert(self.serverPlayerID, @"server ID is nil");
        [self sendNetworkPacket:self.match packetID:NETWORK_EVENT withData:event ofLength:sizeof(GameEvent) reliable:YES players:[NSArray arrayWithObject:self.serverPlayerID]];
    } else {
        
        [self receiveEventAsServer:event];
    }
}

- (BOOL) isGameStarted
{
    return _gameState == kStateMultiplayer;
}


#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// 0 index is "End Game" button
	if(buttonIndex == 0) {
        [self end];
	}
}


@end
