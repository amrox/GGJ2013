//
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>


typedef struct {
	int			bossHealth;
    int         playerCount;
    int			playerHeath[4];
} GameState;

typedef struct {
	int			type;
    int         target; // 0=boss, 1-4=player
    int			value;
} GameEvent;

typedef enum {
    GameEventTypeAttack,
    GameEventTypeSendHeal,
    GameEventTypeReceiveHeal,
} GameEventTypes;


@protocol GameEngineDelegate <NSObject>

- (void)clientReceivedEvent:(GameEvent *)event withState:(GameState *)state;

@end



@class NetworkEngine;

@interface GameEngine : NSObject


@property (assign) int playerMaxHealth;
@property (assign) int playerCount;
@property (assign) int bossMaxHealth;

@property (nonatomic, strong) NetworkEngine *networkEngine;

@property (nonatomic, weak) NSObject<GameEngineDelegate> *delegate;

@property (assign) GameState currentState;

- (void)reset;

- (void)sendEventAsClient:(GameEvent *)event;

- (BOOL)isServer;

@end
