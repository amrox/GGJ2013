//
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GameEngine.h"
#import "EventEngine.h"

extern NSString *const GameEngineGameBeginNotification;
extern NSString *const GameEngineGameEndNotification;

typedef struct {
    GameEvent event;
    GameState state;
} GamePacket;

@interface NetworkEngine : NSObject <GKMatchDelegate>
{
//    int _gameUniqueID;
    int _gamePacketNumber;
}

+ (NetworkEngine *)sharedNetworkEngine;

@property (strong) GameEngine *engine;

- (void)authenticate;
- (void)authenticateWithCompletionHandler:(void(^)(NSError *error))completionHandler;
- (BOOL)isAuthenticated;

@property (strong, readonly) GKMatch *match;
- (void)findMatch;
- (BOOL)isMatchReady;

@property (assign, readonly) BOOL isServer;

- (void)begin;

- (void)end;

- (void)sendEvent:(GameEvent *)event;

- (BOOL) isGameStarted;

@end
