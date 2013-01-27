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

@interface GameKitEventEngine : NSObject <GKMatchDelegate>
{
    int _gamePacketNumber;
}

+ (GameKitEventEngine *)sharedNetworkEngine;

@property (strong) GameEngine *engine;

- (void)authenticate;
- (void)authenticateWithCompletionHandler:(void(^)(NSError *error))completionHandler;
- (BOOL)isAuthenticated;

@property (strong, readonly) GKMatch *match;
- (void)findMatch;
- (BOOL)isMatchReady;

/**
 @discussion Number of players in the match, including yourself. Will always return at least 1.
 */
- (int) matchPlayerCount;

@property (readonly, nonatomic) BOOL isServer;
- (BOOL) isRunning;

/*
 @discussion ORDERED list of PlayerIDs. PlayerID is a STRING, which comes from GameCenter. Format is like 'G:123123123'
 */
@property (readonly, strong) NSArray *allPlayerIDs;

/**
 @discussion my PlayerID from GameCenter, like 'G:123123123123';
 */
@property (readonly) NSString *myPlayerID;

/*
 @discussion My playerIndex
 */
@property (readonly, assign) int myPlayerIndex;

- (void)begin;

- (void)end;

- (void)sendEventAsClient:(GameEvent *)event;

- (void)broadcastEventAsServer:(GameEvent *)event state:(GameState *)state;

@end
