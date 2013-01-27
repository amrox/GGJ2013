#import "GameScene.h"
#import "ResultsScene.h"

#import "GameBackgroundLayer.h"
#import "GameMonsterLayer.h"
#import "GameHUDLayer.h"
#import "GameHeroLayer.h"
#import "GameEngine.h"
#import "GameGestureLayer.h"


@interface GameScene() <GameEngineDelegate, GestureReceiver>
@end


@implementation GameScene
{
	GameEngine * gameEngine;
}

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
    [gestureLayer setDelegate:self];
    
    [self addChild:backgroundLayer];
    [self addChild:monsterLayer];
    [self addChild:heroLayer];
    [self addChild:hudLayer];
    [self addChild:gestureLayer];

	gameEngine = [[GameEngine alloc] init];
	gameEngine.delegate = self;
}

- (void)clientReceivedEvent:(GameEvent *)event withState:(GameState *)state;
{
	NSLog(@"got event");
}

#pragma mark - Gesture Receiver methods

- (void)gestureRegistered:(Gesture *)gesture
{
    [hudLayer gestureRegistered:gesture];
}

- (void)gestureChainCompleted:(NSArray *)gestureChain
{
	GameEvent event;
	event.target = 0;
	event.type = 1;
	event.value = 0;
    [gameEngine processEvent:&event];
}

@end



