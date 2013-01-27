//
//  EventEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "GameEngine.h"

@protocol EventEngineDelegate <NSObject>

- (GameState)processEvent:(GameEvent *)event;

@end


@protocol EventEngine <NSObject>

- (void)sendEventAsClient:(GameEvent *)event;


@end