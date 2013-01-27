//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"
#import "NetworkEngine.h"

#define BOSS_MAX_HEALTH 100

@implementation GameEngine
{
	float timeToNextAttack;
}

- (void)reset
{
    GameState state;
    state.bossHealth = BOSS_MAX_HEALTH;
    state.playerCount = self.playerCount;
	state.healReady = 0;
    for (int i = 0; i < 4; i++) {
        state.playerHeath[i] = self.playerMaxHealth;
    }
	self.currentState = state;
	timeToNextAttack = -1;
}

- (void)setNetworkEngine:(NetworkEngine *)networkEngine
{
    _networkEngine = networkEngine;
    _networkEngine.engine = self;
}

- (void)broadcastEventAsServer:(GameEvent *)event
{
    if (!self.networkEngine) {
        GameState state = self.currentState;
        [self.delegate clientReceivedEvent:event withState:&state];
    }
}

- (void)processEvent:(GameEvent *)event
{
	if (event->type == EGameEventType_ATTACK_FIRE ||
		event->type == EGameEventType_ATTACK_WIND ||
		event->type == EGameEventType_ATTACK_ICE)
	{
		GameState state = self.currentState;
		state.bossHealth = MAX(0, state.bossHealth - event->value);
		self.currentState = state;

		GameEvent broadcastEvent;
		broadcastEvent.type = EGameEventType_MONSTER_DAMAGED_FIRE + (event->type - EGameEventType_ATTACK_FIRE);
		broadcastEvent.target = 0;
		broadcastEvent.value = event->value;

		[self broadcastEventAsServer:&broadcastEvent];

		if (state.bossHealth == 0)
		{
			broadcastEvent.type = EGameEventType_MONSTER_DEAD;
			broadcastEvent.target = 0;
			broadcastEvent.value = 0;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
	else if (event->type == EGameEventType_HEAL)
	{
		GameState state = self.currentState;
		state.healReady = 1;
		self.currentState = state;
	}
	else if (event->type == EGameEventType_RECEIVE_HEAL)
	{
		GameState state = self.currentState;
		if (state.healReady == 1)
		{
			//todo: make the player who sent the message the one who receives the healing

			state.healReady = 0;
			int playerId = event->target - 1;
			if (playerId >= 0 && playerId < 4)
			{
				state.playerHeath[playerId] = MIN(MAX_PLAYER_HEALTH, state.playerHeath[playerId] + event->value);
			}
			self.currentState = state;

			GameEvent broadcastEvent;
			broadcastEvent.type = EGameEventType_PLAYER_RECEIVED_HEAL;
			broadcastEvent.target = event->target;
			broadcastEvent.value = event->value;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
}

- (void)sendEventAsClient:(GameEvent *)event
{
	if (!self.networkEngine)
	{
        [self processEvent:event];
        
//		GameState state = self.currentState;
//		[self.delegate clientReceivedEvent:event withState:&state];
	} else {
        
        // andy does stuff
        
        [self.networkEngine sendEvent:event];
    }
}

- (BOOL)isServer
{
    if (self.networkEngine != nil) {
        return [self.networkEngine isServer];
    }
    return YES;
}


- (void)update:(float)deltaTime
{
#define MIN_ATTACK_TIME 2
#define MAX_ATTACK_TIME 6

	if (timeToNextAttack == -1)
	{
		timeToNextAttack = (float)(arc4random() % 1000) / 1000.0f * (MAX_ATTACK_TIME - MIN_ATTACK_TIME) + MIN_ATTACK_TIME;
	}
	else
	{
		timeToNextAttack -= deltaTime;
		if (timeToNextAttack <= 0)
		{
			timeToNextAttack = -1;

			GameEvent broadcastEvent;
			broadcastEvent.type = EGameEventType_PLAYER_HIT;
			broadcastEvent.target = 1;
			broadcastEvent.value = 10;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
}

@end
