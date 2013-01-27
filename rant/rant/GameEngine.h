//
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

extern NSString *const GameEngineGameBeginNotification;
extern NSString *const GameEngineGameEndNotification;

typedef struct {
	int			bossHealth;
    int			playerHeath[4];
} GameState;

typedef struct {
	int			type;
    int			value;
} GameEvent;


@interface GameEngine : NSObject <GKMatchDelegate>
{
    int _gameUniqueID;
    int _gamePacketNumber;
}

+ (GameEngine *)sharedGameEngine;


- (void)authenticate;
- (void)authenticateWithCompletionHandler:(void(^)(NSError *error))completionHandler;
- (BOOL)isAuthenticated;

@property (strong, readonly) GKMatch *match;
- (void)findMatch;
- (BOOL)isMatchReady;


- (void)begin;

- (void)end;

@property (assign, readonly) GameState currentState;


- (void)sendEvent:(GameEvent *)event;

@end
