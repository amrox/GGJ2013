#import "GameScene.h"
#import "ResultsScene.h"

#import "GameBackgroundLayer.h"
#import "GameGestureLayer.h"
#import "GameMonsterLayer.h"
#import "GameHUDLayer.h"
#import "GameHeroLayer.h"
#import "GameEngine.h"


@interface GameScene() <GameEngineDelegate>
@end


@implementation GameScene

@synthesize backgroundLayer;
@synthesize monsterLayer;
@synthesize hudLayer;
@synthesize gestureLayer;
@synthesize heroLayer;

+(CCScene *) scene
{
	CCScene *scene = [GameScene node];

	return scene;
}

-(void)onEnter
{
    [super onEnter];

	CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    backgroundLayer = [GameBackgroundLayer node];
    monsterLayer = [GameMonsterLayer node];
    heroLayer = [GameHeroLayer node];
    hudLayer = [GameHUDLayer node];
    gestureLayer = [GameGestureLayer node];
    
	[gestureLayer setPosition:ccp(-windowSize.width*0.5f, -windowSize.height*0.5f)];

    [self addChild:backgroundLayer];
    [self addChild:monsterLayer];
    [self addChild:heroLayer];
    [self addChild:hudLayer];
    [self addChild:gestureLayer];
}

- (void)clientReceivedEvent:(GameEvent *)event withState:(GameState *)state;
{
	NSLog(@"got event");
}

@end



