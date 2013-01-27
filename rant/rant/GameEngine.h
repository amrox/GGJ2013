//
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>

#define MAX_PLAYER_HEALTH 10
#define TOTAL_HITS_TO_CANCEL_ATTACK 4
#define ATTACK_PREPARATION_TIME 5

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
	EGameEventType_MONSTER_PREPARING_TO_ATTACK,
	EGameEventType_MONSTER_ATTACK_DIMINISHED,
	EGameEventType_MONSTER_ATTACK_BLOCKED,
} EGameEventType;

typedef struct {
	int			bossHealth;
    int         playerCount;
    int			playerHeath[4];
	int			healReady;			// 1 if ready, 0 otherwise
	int			healerPlayerId;
	int			monsterPreparingToAttackPlayerId;	//-1 of none
	int			millisecondsBeforeMonsterAttacks;
	int			monsterAttackPreparationType;
	int			monsterHitsLeftForCancel;
} GameState;

typedef struct {
	int     	source;
	int			type;	//EGameEventType
    int         targetPlayerId; // 0-3=player
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

@property (nonatomic, strong) GameKitEventEngine *networkEngine;

@property (nonatomic, weak) NSObject<GameEngineDelegate> *delegate;

@property (assign) GameState currentState;

- (void)reset;

- (void)sendEventAsClient:(GameEvent *)event;

// -- Server Only
- (BOOL)isServer;
- (void)processEvent:(GameEvent *)event;

// -- Client Only
- (void)receiveStateFromServer:(GameState *)state event:(GameEvent *)event;



- (void)update:(float)deltaTime;

- (int) myPlayerNum;
- (int)playerCount;

@end
