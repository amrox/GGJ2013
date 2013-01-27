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
	NSLog(@"got event.  monster hp is %d", state->bossHealth);

	//todo: update stuff here
}

#pragma mark - Gesture Receiver methods

- (void)gestureRegistered:(Gesture *)gesture
{
    [hudLayer gestureRegistered:gesture];
}

- (void)gestureChainCompleted:(NSArray *)gestureChain
{
	if ([gestureChain count] == 1)
	{
		Gesture * singleGesture = [gestureChain objectAtIndex:0];
		if (singleGesture.gesture == EGesture_FIRE)
		{
			GameEvent event;
			event.target = 0;
			event.type = EGameEventType_ATTACK_FIRE;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
		}
		else if (singleGesture.gesture == EGesture_WIND)
		{
			GameEvent event;
			event.target = 0;
			event.type = EGameEventType_ATTACK_WIND;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
		}
		else if (singleGesture.gesture == EGesture_ICE)
		{
			GameEvent event;
			event.target = 0;
			event.type = EGameEventType_ATTACK_ICE;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
		}
	}
	else if ([gestureChain count] == 2)
	{
		Gesture * firstGesture = [gestureChain objectAtIndex:0];
		Gesture * secondGesture = [gestureChain objectAtIndex:1];
		if (secondGesture.gesture == EGesture_ATTACK)
		{
			if (firstGesture.gesture == EGesture_FIRE)
			{
				GameEvent event;
				event.target = 0;
				event.type = EGameEventType_ATTACK_FIRE;
				event.value = 3;
				[gameEngine sendEventAsClient:&event];
			}
			else if (firstGesture.gesture == EGesture_WIND)
			{
				GameEvent event;
				event.target = 0;
				event.type = EGameEventType_ATTACK_WIND;
				event.value = 3;
				[gameEngine sendEventAsClient:&event];
			}
			else if (firstGesture.gesture == EGesture_ICE)
			{
				GameEvent event;
				event.target = 0;
				event.type = EGameEventType_ATTACK_ICE;
				event.value = 3;
				[gameEngine sendEventAsClient:&event];
			}
		}
	}
}

@end
