#import "GameScene.h"
#import "ResultsScene.h"

#import "GameBackgroundLayer.h"
#import "GameGestureLayer.h"
#import "GameMonsterLayer.h"
#import "GameHUDLayer.h"


#define RANT_FONT @"Bernard MT Condensed"


@interface GameLayer : CCLayer
{
}

@end



@implementation GameLayer
{
}

-(void)onEnter
{
    // Create the layer hierarchy
    [super onEnter];
    
    [self addChild:[GameBackgroundLayer node]];
    [self addChild:[GameMonsterLayer node]];
    [self addChild:[GameHUDLayer node]];
    [self addChild:[GameGestureLayer node]];
}

@end



@implementation GameScene

+(CCScene *) scene
{
	CCScene *scene = [GameScene node];

	return scene;
}

-(void) onEnter
{
	[super onEnter];
}

@end



