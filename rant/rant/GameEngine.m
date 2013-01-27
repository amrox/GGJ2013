//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"
#import "GameKitEventEngine.h"

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

- (void)setNetworkEngine:(GameKitEventEngine *)networkEngine
{
    _networkEngine = networkEngine;
    _networkEngine.engine = self;
}

- (void)broadcastEventAsServer:(GameEvent *)event
{
    event->source = 0; // server is always 0
    
    NSLog(@"*** [GAME] [SEND] broadcast event src=%lld type=%d", event->source, event->type);
    
    GameState state = self.currentState;
    [self.delegate clientReceivedEvent:event withState:&state];
    
    if (self.networkEngine) {
        [self.networkEngine broadcastEventAsServer:event state:&state];
    }
}

- (void)receiveStateFromServer:(GameState *)state event:(GameEvent *)event
{
    NSAssert(![self isServer], @"should only be called on clients");
    
    self.currentState = *state;
    
    [self.delegate clientReceivedEvent:event withState:state];
}


- (void)sendEventAsClient:(GameEvent *)event
{
    event->source = [self myPlayerNum];
    
    NSLog(@"*** [GAME] [SEND] client event src=%lld type=%d", event->source, event->type);
    
	if ([self isServer])
	{
        [self processEvent:event];
	}
    else
    {
        [self.networkEngine sendEventAsClient:event];
    }
}

- (BOOL)isServer
{
    if (self.networkEngine != nil) {
        return [self.networkEngine isServer];
    }
    return YES;
}

- (int) myPlayerNum
{
    if (self.networkEngine) {
        return [self.networkEngine myPlayerIndex];
    }
    return 0;
}


// game specific stuff here

- (void)processEvent:(GameEvent *)event
{
	int sendingPlayerId = event->source;


    NSAssert([self isServer], @"should only be called on the server");

	if (event->type == EGameEventType_ATTACK_FIRE ||
		event->type == EGameEventType_ATTACK_WIND ||
		event->type == EGameEventType_ATTACK_ICE)
	{
		GameState state = self.currentState;
		state.bossHealth = MAX(0, state.bossHealth - event->value);
		self.currentState = state;

		GameEvent broadcastEvent;
		broadcastEvent.type = EGameEventType_MONSTER_DAMAGED_FIRE + (event->type - EGameEventType_ATTACK_FIRE);
		broadcastEvent.targetPlayerId = sendingPlayerId;
		broadcastEvent.value = event->value;

		[self broadcastEventAsServer:&broadcastEvent];

		if (state.bossHealth == 0)
		{
			broadcastEvent.type = EGameEventType_MONSTER_DEAD;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
	else if (event->type == EGameEventType_HEAL)
	{
		GameState state = self.currentState;
		state.healReady = 1;
		state.healerPlayerId = sendingPlayerId;
		self.currentState = state;
	}
	else if (event->type == EGameEventType_RECEIVE_HEAL)
	{
		GameState state = self.currentState;
		if (state.healReady == 1 && state.healerPlayerId != sendingPlayerId)
		{
			state.healReady = 0;

			if (sendingPlayerId >= 0 && sendingPlayerId < 4)
			{
				state.playerHeath[sendingPlayerId] = MIN(MAX_PLAYER_HEALTH, state.playerHeath[sendingPlayerId] + event->value);
			}
			self.currentState = state;

			GameEvent broadcastEvent;
			broadcastEvent.type = EGameEventType_PLAYER_RECEIVED_HEAL;
			broadcastEvent.targetPlayerId = sendingPlayerId;
			broadcastEvent.value = event->value;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
}

- (void)update:(float)deltaTime
{
    if (!self.isServer) return; // hack
    
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
			int realPlayerCount = MAX(1, self.playerCount);
			int playerToAttack = arc4random() % realPlayerCount;
			int damage = (arc4random() % 10) + 3;

			timeToNextAttack = -1;

			GameState state = self.currentState;
			state.playerHeath[playerToAttack] = MAX(0, state.playerHeath[playerToAttack] - damage);
			self.currentState = state;

			GameEvent broadcastEvent;
			broadcastEvent.type = EGameEventType_PLAYER_HIT;
			broadcastEvent.targetPlayerId = playerToAttack;
			broadcastEvent.value = damage;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
}

@end
