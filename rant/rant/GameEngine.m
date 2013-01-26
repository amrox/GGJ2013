//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"

#import "Util.h"

@interface GameEngine ()

@property (assign) BOOL matchStarted;

@end

@implementation GameEngine

+ (GameEngine *)sharedGameEngine
{
    static dispatch_once_t onceToken;
    static GameEngine *engine;
    dispatch_once(&onceToken, ^{
        engine = [[GameEngine alloc] init];
    });
    return engine;
}

- (void)authenticate
{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            
            if (error != nil) {
                NSLog(@"error: %@", error);
                abort();
            }
        }];
    }
}

- (IBAction)findProgrammaticMatch: (id) sender
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            PresentError(error);
        }
        else if (match != nil)
        {
            self.match = match; // Use a retaining property to retain the match.
            match.delegate = self;
            if (!self.matchStarted && match.expectedPlayerCount == 0)
            {
//                self.matchStarted = YES;
//                // Insert game-specific code to begin the match.
//                
//                NSLog(@"begin match!");
            }
        }
    }];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSLog(@"got data!");
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (self.match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!self.matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            self.matchStarted = NO;
//            [delegate matchEnded];
            break;
    }
}

@end
