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

- (void)processEvent:(GameEvent *)event
{
	if (!self.networkEngine)
	{
		// todo: also need to actually process the event.  And only send applicable events back to the client.
		// just putting this here so I can test stuff

		GameState state = self.currentState;
		[self.delegate clientReceivedEvent:event withState:&state];
	}

    // alter game state here
    
    if (![self isServer]) {
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



@end
