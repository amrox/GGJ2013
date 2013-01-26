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

	CGSize windowSize = [[CCDirector sharedDirector] winSize];

    [self addChild:[GameBackgroundLayer node]];
    [self addChild:[GameMonsterLayer node]];
    [self addChild:[GameHUDLayer node]];
	CCLayer * gestureLayer = [GameGestureLayer node];
	[gestureLayer setPosition:ccp(-windowSize.width*0.5f, -windowSize.height*0.5f)];
    [self addChild:gestureLayer];
}

@end



