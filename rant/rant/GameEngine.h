//
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>

@class NetworkEngine;

@interface GameEngine : NSObject

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


@property (assign) int playerMaxHealth;
@property (assign) int playerCount;
@property (assign) int bossMaxHealth;

@property (nonatomic, strong) NetworkEngine *networkEngine;

@property (assign) GameState currentState;

- (void)reset;

- (void)processEvent:(GameEvent *)event;

- (BOOL)isServer;

@end
