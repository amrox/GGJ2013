#import "cocos2d.h"
#import "GameGestureLayer.h"

@class GameBackgroundLayer;
@class GameMonsterLayer;
@class GameHUDLayer;
@class GameHeroLayer;

#define RANT_FONT @"Helvetica"

@interface GameScene : CCScene <GestureReceiver>
{
}

@property (nonatomic, strong) GameBackgroundLayer *backgroundLayer;
@property (nonatomic, strong) GameMonsterLayer *monsterLayer;
@property (nonatomic, strong) GameHeroLayer *heroLayer;
@property (nonatomic, strong) GameHUDLayer *hudLayer;
@property (nonatomic, strong) GameGestureLayer *gestureLayer;

+(CCScene *) scene;

@end
