//
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>

#define MAX_PLAYER_HEALTH 10

typedef enum
{
	EGameEventType_ATTACK_FIRE,
	EGameEventType_ATTACK_ICE,
	EGameEventType_ATTACK_WIND,
	EGameEventType_HEAL,
	EGameEventType_RECEIVE_HEAL,
	EGameEventType_MONSTER_DAMAGED_FIRE,
	EGameEventType_MONSTER_DAMAGED_ICE,
	EGameEventType_MONSTER_DAMAGED_WIND,
	EGameEventType_MONSTER_DEAD,
	EGameEventType_PLAYER_HIT,
	EGameEventType_PLAYER_RECEIVED_HEAL,
} EGameEventType;

typedef struct {
	int			bossHealth;
    int         playerCount;
    int			playerHeath[4];
	int			healReady;			// 1 if ready, 0 otherwise
} GameState;

typedef struct {
	int			source;
	int			type;	//EGameEventType
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



@class GameKitEventEngine;

@interface GameEngine : NSObject


@property (assign) int playerMaxHealth;
@property (assign) int playerCount;

@property (nonatomic, strong) GameKitEventEngine *networkEngine;

@property (nonatomic, weak) NSObject<GameEngineDelegate> *delegate;

@property (assign) GameState currentState;

- (void)reset;

- (void)sendEventAsClient:(GameEvent *)event;

- (BOOL)isServer;

- (void)processEvent:(GameEvent *)event;

- (void)update:(float)deltaTime;

@end
