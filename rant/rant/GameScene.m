#import "GameScene.h"
#import "ResultsScene.h"

#import "GameBackgroundLayer.h"
#import "GameGestureLayer.h"
#import "GameMonsterLayer.h"
#import "GameHUDLayer.h"


@implementation GameScene

+(CCScene *) scene
{
	CCScene *scene = [GameScene node];

	return scene;
}

-(void)onEnter
{
    [super onEnter];

    [self addChild:[GameBackgroundLayer node]];
    [self addChild:[GameMonsterLayer node]];
    [self addChild:[GameHUDLayer node]];
    [self addChild:[GameGestureLayer node]];
}

@end



