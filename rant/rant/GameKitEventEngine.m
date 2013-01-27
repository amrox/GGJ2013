//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameKitEventEngine.h"

#import "Util.h"

static NSString *const GameUniqueIDKey = @"GameUniqueID";

NSString *const GameEngineGameBeginNotification = @"GameBegin";
NSString *const GameEngineGameEndNotification = @"GameEnd";


#define kMaxPacketSize 1024
const float kHeartbeatTimeMaxDelay = 2.0f;
#define kHeartbeatMod (10)
#define kGameloopInterval (0.033)

typedef enum {
    kStateLobby,
	kStateStartGame,
    kStateMain,
} gameStates;


typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_GAME_START,				// decide who is going to be the server
    NETWORK_EVENT,
    NETWORK_GAME_STATE,
} packetCodes;

@interface GameKitEventEngine ()

@property (strong, readwrite) GKMatch *match;
@property (assign) NSInteger gameState;
@property (strong) UIAlertView *connectionAlert;
@property (strong) NSMutableDictionary *playerInfo;
@property (assign, readwrite) GameState currentState;
@property (strong) NSMutableArray *incomingEvents;
@property (readwrite, strong) NSArray *allPlayerIDs;
@property (readwrite, assign) int myPlayerIndex;
- (void)reset;
- (NSString *)serverPlayerID;
@end


@interface PlayerInfo : NSObject

@property (strong) NSString *playerID;

@end

@implementation PlayerInfo
@end

@implementation GameKitEventEngine

+ (GameKitEventEngine *)sharedNetworkEngine
{
    static dispatch_once_t onceToken;
    static GameKitEventEngine *engine;
    dispatch_once(&onceToken, ^{
        engine = [[GameKitEventEngine alloc] init];
    });
    return engine;
}

- (id)init
{
    self = [super init];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:kGameloopInterval target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
        self.playerInfo = [NSMutableDictionary dictionaryWithCapacity:4];
        self.incomingEvents = [NSMutableArray arrayWithCapacity:20];
        self.gameState = kStateLobby;
    }
    return self;
}

- (void)broadcastNetworkPacket:(GKMatch *)match packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend
{
    [self sendNetworkPacket:match packetID:packetID withData:data ofLength:length reliable:howtosend players:self.match.playerIDs];
}


- (void)sendNetworkPacket:(GKMatch *)match packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend players:(NSArray *)players {
    
//    NSAssert([players count] > 0, @"no players");
    if ([players count] == 0) {
        NSLog(@"WARNING: empty send list");
        return;
    }

    
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
        
    }
}

- (NSString*) serverPlayerID
{
    return [self.allPlayerIDs objectAtIndex:0];
}

- (void)disconnect
{
    NSString *message = [NSString stringWithFormat:@"Lost Player Connection"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
    [alert show];
    [self end];
}

- (void)gameLoop
{
    static int counter = 0;
	switch (self.gameState) {
            
        case kStateLobby:
            break;
            
		case kStateStartGame:
			[self broadcastNetworkPacket:self.match packetID:NETWORK_GAME_START withData:NULL ofLength:sizeof(int) reliable:YES];
			self.gameState = kStateMain;
            [[NSNotificationCenter defaultCenter] postNotificationName:GameEngineGameBeginNotification object:self];
			break;
            
		case kStateMain:
            
            // check connection
            
            if (counter % kHeartbeatMod) {
                for (NSString *playerID in [self allPlayerIDs]) {
                    if (![playerID isEqualToString:[self myPlayerID]]) {
                        if (![self.match.playerIDs containsObject:playerID]) {
                            NSLog(@"lost connection with: %@", playerID);
                            [self disconnect];
                        }
                    }
                }
            }
            
            if (self.isServer) {
                [self processEvents];
            }
            
            counter++;
            
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
    
//    [[GKMatchmaker sharedMatchmaker] cancel];
    
    [self end];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    self.gameState = kStateLobby;
    
    if (self.match == nil) {
        
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
    } else {
        
        [[GKMatchmaker sharedMatchmaker] addPlayersToMatch:self.match matchRequest:request completionHandler:^(NSError *error) {
            if (error)
            {
                PresentError(error);
            }
        }];
        
    }
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
            [self begin];
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
    NSLog(@"*** [NET] [RECV] client event src=%d type=%d", event->source, event->type);

    @synchronized(self.incomingEvents) {
        NSValue *eventVal = [NSValue valueWithBytes:event objCType:@encode(GameEvent)];
        [self.incomingEvents addObject:eventVal];
    }
}

- (void)receivePacketAsClient:(GamePacket *)packet
{
    NSLog(@"*** [NET] [RECV] broad event src=%d type=%d", packet->event.source, packet->event.type);
    
    [self.engine receiveStateFromServer:&packet->state event:&packet->event];
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
        [alert show];

        [self end];
	}
}

- (void)begin
{
    if (self.gameState == kStateLobby) {
        NSAssert(self.match, @"match is nil");
        NSAssert(self.match.expectedPlayerCount == 0, @"not enough players");

        self.allPlayerIDs = [[[self.match playerIDs] arrayByAddingObject:
                              [GKLocalPlayer localPlayer].playerID] sortedArrayUsingSelector:@selector(compare:)];
        
        self.myPlayerIndex = [self.allPlayerIDs indexOfObject:[self myPlayerID]];
        NSAssert(self.myPlayerIndex >= 0 && self.myPlayerIndex < 4, @"index should be between 0 and 3");
        
        self.gameState = kStateStartGame;
        
        NSLog(@"game began with players: %@", self.allPlayerIDs);
        NSLog(@"I am player %d!", self.myPlayerIndex);
    }
}

- (void)end
{
    int prevState = self.gameState;
    
//    self.match = nil;
    self.allPlayerIDs = nil;
    self.myPlayerIndex = NSNotFound;
    self.gameState = kStateLobby;
    
    if (prevState == kStateMain) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GameEngineGameEndNotification object:self];
    }
}

- (BOOL) isMatchReady
{
    return self.match != nil && (self.match.expectedPlayerCount == 0);
}

- (int) matchPlayerCount
{
    return [[self.match playerIDs] count] + 1;
}

- (NSString *)myPlayerID
{
    return [GKLocalPlayer localPlayer].playerID;
}

- (BOOL) isServer
{
    return [self myPlayerIndex] == 0;
}

- (void)sendEventAsClient:(GameEvent *)event
{
    NSLog(@"*** [NET] [SEND] client event src=%d type=%d", event->source, event->type);
    
    NSAssert(!self.isServer, @"should not be server");
    NSAssert(self.serverPlayerID, @"server ID is nil");
    
    [self sendNetworkPacket:self.match packetID:NETWORK_EVENT withData:event ofLength:sizeof(GameEvent) reliable:YES players:[NSArray arrayWithObject:self.serverPlayerID]];
}

- (void)broadcastEventAsServer:(GameEvent *)event state:(GameState *)state
{
    NSAssert(self.isServer, @"must be server");
    
    GamePacket packet;
    packet.event = *event;
    packet.state = *state;
    
    NSLog(@"*** [NET] [SEND] broadcast event src=%d type=%d", event->source, event->type);
    
    [self broadcastNetworkPacket:self.match packetID:NETWORK_GAME_STATE withData:&packet ofLength:sizeof(GamePacket) reliable:YES];
}


- (BOOL) isRunning
{
    return _gameState == kStateMain;
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

- (void)reset
{
    self.allPlayerIDs = nil;
    self.myPlayerIndex = NSNotFound;
}


@end
