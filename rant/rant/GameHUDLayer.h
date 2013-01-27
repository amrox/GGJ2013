//
//  GameHUDLayer.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameEngine.h"

@class Gesture;
@class GameMonsterHealthBar;

@interface GameHUDLayer : CCLayer {
    
}

@property (nonatomic, strong) GameMonsterHealthBar *monsterHealthBar;
@property (nonatomic, strong) GameMonsterHealthBar *monsterAttackBar;
@property (nonatomic, strong) GameMonsterHealthBar *heroHealthBar;

- (void)gestureRegistered:(Gesture *)gesture;

- (void)displayIconWithType:(EGameEventType)type;
- (void)clearIcon;

- (void)displayEffect:(EGameEventType)type;

@end