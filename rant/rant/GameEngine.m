//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"

#import "Util.h"

static NSString *const GameUniqueIDKey = @"GameUniqueID";

#define kMaxPacketSize 1024
const float kHeartbeatTimeMaxDelay = 2.0f;
#define kHeartbeatMod (10)
#define kGameloopInterval (0.033)

typedef enum {
	kStateStartGame,
    kStatePicker,
	kStateMultiplayer,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} gameStates;


typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
//	NETWORK_MOVE_EVENT,				// send position
//	NETWORK_FIRE_EVENT,				// send fire
	NETWORK_HEARTBEAT				// send of entire state at regular intervals
} packetCodes;

@interface GameEngine ()

@property (assign) NSInteger gameState;
@property (assign) BOOL matchReady;
@property (strong) UIAlertView *connectionAlert;
@property (strong) NSMutableDictionary *playerInfo;

@end


@interface PlayerInfo : NSObject

@property (assign) int cointoss;
@property (strong) NSString *playerID;
@property (strong) NSDate *lastHeartbeat;

@end

@implementation PlayerInfo
@end

@implementation GameEngine

+ (GameEngine *)sharedGameEngine
{
    static dispatch_once_t onceToken;
    static GameEngine *engine;
    dispatch_once(&onceToken, ^{
        engine = [[GameEngine alloc] init];
    });
    return engine;
}

- (void)getGameUniqueID
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:GameUniqueIDKey] == nil) {
        _gameUniqueID = [GetUUID() hash];
        [[NSUserDefaults standardUserDefaults] setInteger:_gameUniqueID forKey:GameUniqueIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        _gameUniqueID = [[NSUserDefaults standardUserDefaults] integerForKey:GameUniqueIDKey];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self getGameUniqueID];
        [NSTimer scheduledTimerWithTimeInterval:kGameloopInterval target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
        self.playerInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

- (void)sendNetworkPacket:(GKMatch *)match packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
	// the packet we'll send is resued
	static unsigned char networkPacket[kMaxPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = _gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length );
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) {
            [match sendDataToAllPlayers:packet withDataMode:GKSendDataReliable error:nil];
		} else {
            [match sendDataToAllPlayers:packet withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

- (void)updateState
{
    
}

- (void)gameLoop
{
    static int counter = 0;
	switch (self.gameState) {
        case kStatePicker:
		case kStateStartGame:
			break;
		case kStateMultiplayerCointoss:
			[self sendNetworkPacket:self.match packetID:NETWORK_COINTOSS withData:&_gameUniqueID ofLength:sizeof(int) reliable:YES];
			self.gameState = kStateMultiplayer; // we only want to be in the cointoss state for one loop
			break;
		case kStateMultiplayer:
            [self updateState];
			counter++;
			if(!(counter&kHeartbeatMod)) { // once every 8 updates check if we have a recent heartbeat from the other player, and send a heartbeat packet with current state
                
                NSArray *allPlayers = [self.playerInfo allValues];
                
                for (PlayerInfo *info in allPlayers) {
                 
                    if (info.lastHeartbeat == nil) {
                        info.lastHeartbeat = [NSDate date];
                        
                    } else if(fabs([info.lastHeartbeat timeIntervalSinceNow]) >= kHeartbeatTimeMaxDelay) { // see if the last heartbeat is too old
                        // seems we've lost connection, notify user that we are trying to reconnect (until GKSession actually disconnects)
                        NSString *message = [NSString stringWithFormat:@"Trying to reconnect..."];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
                        self.connectionAlert = alert;
                        [alert show];
                        self.gameState = kStateMultiplayerReconnect;
                    }
                }
                
                
                
//				if(self.lastHeartbeatDate == nil) {
//					// we haven't received a hearbeat yet, so set one (in case we never receive a single heartbeat)
//					self.lastHeartbeatDate = [NSDate date];
//				}
//				else if(fabs([self.lastHeartbeatDate timeIntervalSinceNow]) >= kHeartbeatTimeMaxDelay) { // see if the last heartbeat is too old
//					// seems we've lost connection, notify user that we are trying to reconnect (until GKSession actually disconnects)
//                    NSString *message = [NSString stringWithFormat:@"Trying to reconnect..."];
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
//                    self.connectionAlert = alert;
//                    [alert show];
//					self.gameState = kStateMultiplayerReconnect;
//				}

                // send a new heartbeat to other player
                //tankInfo *ts = &tankStats[self.peerStatus];
                PacketData packetData;
                [self sendNetworkPacket:self.match packetID:NETWORK_HEARTBEAT withData:&packetData ofLength:sizeof(PacketData) reliable:NO];
			}
			break;
		case kStateMultiplayerReconnect:
            // we have lost a heartbeat for too long, so pause game and notify user while we wait for next heartbeat or session disconnect.
            counter++;
            if(!(counter&kHeartbeatMod)) { // keep sending heartbeats to the other player in case it returns
                //				tankInfo *ts = &tankStats[self.peerStatus];
                PacketData packetData;
                [self sendNetworkPacket:self.match packetID:NETWORK_HEARTBEAT withData:&packetData ofLength:sizeof(PacketData) reliable:NO];
            }
			break;
		default:
			break;
	}
}

- (void)authenticate
{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            
            if (error != nil) {
                NSLog(@"error: %@", error);
                abort();
            }
        }];
    }
}

- (void)findMatch
{
    NSAssert([GKLocalPlayer localPlayer].isAuthenticated, @"not authenticated");
    
    [[GKMatchmaker sharedMatchmaker] cancel];
    
    [self end];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    self.gameState = kStatePicker;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                PresentError(error);
            });
        }
        else if (match != nil)
        {
            NSLog(@"Match found!");

            self.match = match; // Use a retaining property to retain the match.
            match.delegate = self;
            
            
            //            if (!self.matchStarted && match.expectedPlayerCount == 0)
            //            {
            //                self.matchStarted = YES;
            //                // Insert game-specific code to begin the match.
            //
            //                NSLog(@"begin match!");
            //            }
        }
    }];
}

- (PlayerInfo *)getInfoForPlayerID:(NSString *)playerID
{
    PlayerInfo *info = self.playerInfo[playerID];
    if (info == nil) {
        info = [[PlayerInfo alloc] init];
        info.playerID = playerID;
        self.playerInfo[playerID] = info;
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
	if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
		return;
	}
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_COINTOSS:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            
            PlayerInfo *playerInfo = [self getInfoForPlayerID:playerID];
            playerInfo.cointoss = coinToss;
            
            NSLog(@"player:%@ cointoss:%d", playerID, coinToss);
            
            
            //            // coin toss to determine roles of the two players
            //            int coinToss = pIntData[2];
            //            // if other player's coin is higher than ours then that player is the server
            //            if(coinToss > gameUniqueID) {
            //                self.peerStatus = kClient;
            //            }
            //
            //            // notify user of tank color
            //            self.gameLabel.text = (self.peerStatus == kServer) ? kBlueLabel : kRedLabel; // server is the blue tank, client is red
            //            self.gameLabel.hidden = NO;
            //            // after 1 second fire method to hide the label
            //            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideGameLabel:) userInfo:nil repeats:NO];
        }
			break;
            
        case NETWORK_HEARTBEAT:
        {
            //NSLog(@"%@: heartbeat %d", playerID, packetTime);
            
            PlayerInfo *playerInfo = [self getInfoForPlayerID:playerID];
            playerInfo.lastHeartbeat = [NSDate date];

            // Received heartbeat data with other player's position, destination, and firing status.
            
            // update the other player's info from the heartbeat
            PacketData *packetData = (PacketData *)&incomingPacket[8];		// tank data as seen on other client
//            int peer = (self.peerStatus == kServer) ? kClient : kServer;
//            tankInfo *ds = &tankStats[peer];					// same tank, as we see it on this client
//            memcpy( ds, ts, sizeof(tankInfo) );
            
            // update heartbeat timestamp
//            self.lastHeartbeatDate = [NSDate date];
            
            // if we were trying to reconnect, set the state back to multiplayer as the peer is back
            if(self.gameState == kStateMultiplayerReconnect) {
                if(self.connectionAlert && self.connectionAlert.visible) {
                    [self.connectionAlert dismissWithClickedButtonIndex:-1 animated:YES];
                }
                self.gameState = kStateMultiplayer;
            }
        }
			break;
    }
}



// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
    // Logging
    if(state == GKPeerStateConnected) {
        NSLog(@"player:%@ connected!", playerID);
    } else if (state == GKPeerStateDisconnected) {
        NSLog(@"player:%@ disconnected :(", playerID);
    }

    
	if(self.gameState == kStatePicker) {
        // only do stuff if we're in multiplayer, otherwise it is probably for Picker
        return;
	}
	
	if(state == GKPeerStateDisconnected) {
        
		// Update user alert or throw alert if it isn't already up
		NSString *message = [NSString stringWithFormat:@"Could not reconnect."];
		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
            // !!!: self.connectionAlert = alert;
			[alert show];
		}
		
		// go back to start mode
		self.gameState = kStateStartGame;

	}
}


- (void)begin
{
    NSAssert(self.match, @"match is nil");
    NSAssert(self.match.expectedPlayerCount == 0, @"not enough players");
    self.matchReady = YES;
    self.gameState = kStateMultiplayerCointoss;
}

- (void)end
{
    self.match = nil;
    self.matchReady = NO;
}

- (BOOL) isReady
{
    return self.match != nil && (self.match.expectedPlayerCount == 0);
}



#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// 0 index is "End Game" button
	if(buttonIndex == 0) {
		self.gameState = kStateStartGame;
	}
}


@end
