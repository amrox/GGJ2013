//
//  GameEngine.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"

@interface GameEngine ()

@property (strong) GKMatch *myMatch;
@property (assign) BOOL matchStarted;

@end

@implementation GameEngine

- (IBAction)findProgrammaticMatch: (id) sender
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            // Process the error.
        }
        else if (match != nil)
        {
            self.myMatch = match; // Use a retaining property to retain the match.
            match.delegate = self;
            if (!self.matchStarted && match.expectedPlayerCount == 0)
            {
                self.matchStarted = YES;
                // Insert game-specific code to begin the match.
            }
        }
    }];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSLog(@"got data!");
    
}

@end
