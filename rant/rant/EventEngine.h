//
//  EventEngine.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

@protocol EventEngine <NSObject>

- (void)processEvent:(GameEvent *)event;


@end