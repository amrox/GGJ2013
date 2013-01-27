//
//  GameHUDLayer.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Gesture;

@interface GameHUDLayer : CCLayer {
    
}

- (void)gestureRegistered:(Gesture *)gesture;

@end
