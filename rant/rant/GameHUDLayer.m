//
//  GameHUDLayer.m
//  rant
//

#import "GameHUDLayer.h"
#import "cocos2d.h"

#import "GameGestureLayer.h"


@implementation GameHUDLayer

- (void)onEnter
{
    [super onEnter];
    
}

- (void)gestureRegistered:(Gesture *)gesture
{
    NSLog(@"Gesture registered: %d", gesture.gesture);
}

@end
