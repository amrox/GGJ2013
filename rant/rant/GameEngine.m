//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"
#import "NetworkEngine.h"

@implementation GameEngine

- (void)reset
{
    GameState state;
    state.bossHealth = self.bossMaxHealth;
    state.playerCount = self.playerCount;
    for (int i = 0; i < 4; i++) {
        state.playerHeath[i] = self.playerMaxHealth;
    }
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
		state.bossHealth -= event->value;
		self.currentState = state;

		GameEvent broadcastEvent;
		broadcastEvent.type = EGameEventType_MONSTER_DAMAGED_FIRE + (event->type - EGameEventType_ATTACK_FIRE);
		broadcastEvent.target = 0;
		broadcastEvent.value = event->value;

		[self broadcastEventAsServer:&broadcastEvent];
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
    }
}

- (BOOL)isServer
{
    if (self.networkEngine != nil) {
        return [self.networkEngine isServer];
    }
    return YES;
}



@end
