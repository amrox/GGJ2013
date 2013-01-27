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
