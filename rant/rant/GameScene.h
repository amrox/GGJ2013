#import "cocos2d.h"

@class GameBackgroundLayer;
@class GameMonsterLayer;
@class GameHUDLayer;
@class GameHeroLayer;
@class GameGestureLayer;

#define RANT_FONT @"Helvetica"

@interface GameScene : CCScene
{
}

@property (nonatomic, strong) GameBackgroundLayer *backgroundLayer;
@property (nonatomic, strong) GameMonsterLayer *monsterLayer;
@property (nonatomic, strong) GameHeroLayer *heroLayer;
@property (nonatomic, strong) GameHUDLayer *hudLayer;
@property (nonatomic, strong) GameGestureLayer *gestureLayer;

+(CCScene *) scene;

@end
