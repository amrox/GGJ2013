//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"
#import "GameKitEventEngine.h"


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
        state.playerHeath[i] = MAX_PLAYER_HEALTH;
    }
	state.monsterPreparingToAttackPlayerId = -1;
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
    
    NSLog(@"*** [GAME] [SEND] broadcast event src=%d type=%d", event->source, event->type);
    
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
    
    NSLog(@"*** [GAME] [SEND] client event src=%d type=%d", event->source, event->type);
    
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

- (int)playerCount
{
    if (self.networkEngine) {
        return [self.networkEngine matchPlayerCount];
    }
    return 1;
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
		if (state.monsterPreparingToAttackPlayerId != -1)
		{
			BOOL attackTypeMatches = (state.monsterAttackPreparationType == event->type);
			if (attackTypeMatches)
			{
				state.monsterHitsLeftForCancel--;
				if (state.monsterHitsLeftForCancel <= 0)
				{
					state.monsterPreparingToAttackPlayerId = -1;
				}
				self.currentState = state;

				if (state.monsterHitsLeftForCancel <= 0)
				{
					GameEvent broadcastEvent;
					broadcastEvent.type = EGameEventType_MONSTER_ATTACK_DIMINISHED;
					[self broadcastEventAsServer:&broadcastEvent];
				}
				else
				{
					GameEvent broadcastEvent;
					broadcastEvent.type = EGameEventType_MONSTER_ATTACK_BLOCKED;
					[self broadcastEventAsServer:&broadcastEvent];
				}
			}
		}
		else
		{
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

	if (self.currentState.monsterPreparingToAttackPlayerId != -1)
	{
		GameState state = self.currentState;
		int deltaMilliseconds = ceilf(deltaTime * 1000.0f);
		state.millisecondsBeforeMonsterAttacks = MAX(0, state.millisecondsBeforeMonsterAttacks - deltaMilliseconds);

		if (state.millisecondsBeforeMonsterAttacks <= 0)
		{
			int damage = MONSTER_ATTACK_DAMAGE;

			timeToNextAttack = -1;

			int playerToAttack = self.currentState.monsterPreparingToAttackPlayerId;

			state.playerHeath[playerToAttack] = MAX(0, state.playerHeath[playerToAttack] - damage);
			state.monsterPreparingToAttackPlayerId = -1;

			if (state.playerHeath[playerToAttack] <= 0)
			{
				GameEvent broadcastEvent;
				broadcastEvent.type = EGameEventType_PLAYER_DIED;
				broadcastEvent.targetPlayerId = playerToAttack;
				broadcastEvent.value = damage;

				[self broadcastEventAsServer:&broadcastEvent];
			}
			else
			{
				GameEvent broadcastEvent;
				broadcastEvent.type = EGameEventType_PLAYER_HIT;
				broadcastEvent.targetPlayerId = playerToAttack;
				broadcastEvent.value = damage;

				[self broadcastEventAsServer:&broadcastEvent];
			}
		}

		self.currentState = state;
	}
	else if (timeToNextAttack == -1 && self.currentState.monsterPreparingToAttackPlayerId == -1)
	{
		timeToNextAttack = (float)(arc4random() % 1000) / 1000.0f * (MAX_ATTACK_TIME - MIN_ATTACK_TIME) + MIN_ATTACK_TIME;
	}
	else
	{
		timeToNextAttack -= deltaTime;
		if (timeToNextAttack <= 0)
		{
			GameState state = self.currentState;
			state.millisecondsBeforeMonsterAttacks = 1000 * ATTACK_PREPARATION_TIME;
			state.monsterPreparingToAttackPlayerId = arc4random() % self.playerCount;
			state.monsterAttackPreparationType = (arc4random() % 3) + EGameEventType_ATTACK_FIRE;
			state.monsterHitsLeftForCancel = TOTAL_HITS_TO_CANCEL_ATTACK;
			self.currentState = state;

			GameEvent broadcastEvent;
			broadcastEvent.type = EGameEventType_MONSTER_PREPARING_TO_ATTACK;
			broadcastEvent.targetPlayerId = state.monsterPreparingToAttackPlayerId;

			[self broadcastEventAsServer:&broadcastEvent];
		}
	}
}

@end
