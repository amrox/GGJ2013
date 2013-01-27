//
//  GameHUDLayer.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Gesture;
@class GameMonsterHealthBar;

@interface GameHUDLayer : CCLayer {
    
}

@property (nonatomic, strong) GameMonsterHealthBar *monsterHealthBar;
@property (nonatomic, strong) GameMonsterHealthBar *heroHealthBar;

- (void)gestureRegistered:(Gesture *)gesture;

@end
