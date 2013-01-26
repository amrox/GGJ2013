    //
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameEngine : NSObject <GKMatchDelegate>


+ (GameEngine *)sharedGameEngine;

@property (strong) GKMatch *match;


- (IBAction)findProgrammaticMatch: (id) sender;

- (void)authenticate;


@end
