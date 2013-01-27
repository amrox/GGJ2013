    //
//  GameEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef struct {
	int			foo;
} PacketData;

@interface GameEngine : NSObject <GKMatchDelegate>
{
    int _gameUniqueID;
    int _gamePacketNumber;
}

+ (GameEngine *)sharedGameEngine;

@property (strong) GKMatch *match;

- (BOOL) isReady;

- (void)authenticate;

- (void)findMatch;

- (void)begin;

- (void)end;


@end
