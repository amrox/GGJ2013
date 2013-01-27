#import "GameScene.h"
#import "ResultsScene.h"

#import "GameBackgroundLayer.h"
#import "GameMonsterLayer.h"
#import "GameHUDLayer.h"
#import "GameHeroLayer.h"
#import "GameEngine.h"
#import "GameGestureLayer.h"
#import "GameHeroNode.h"
#import "GameKitEventEngine.h"
#import "SimpleAudioEngine.h"

#define SHAKE_TIME 0.7f
#define SHAKE_1_PERIOD 0.2f
#define SHAKE_1_AMP 10
#define SHAKE_2_PERIOD 0.1365f
#define SHAKE_2_AMP 13
#define SHAKE_1_X 0.7f
#define SHAKE_1_Y 0.7f
#define SHAKE_2_X 0.9
#define SHAKE_2_Y 0.1f


@interface GameScene() <GameEngineDelegate, GestureReceiver>
@end


@implementation GameScene
{
	GameEngine * gameEngine;
	float cameraShakeTimeLeft;
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
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"fastbeat1.caf"];

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
	[gameEngine reset];
	gameEngine.delegate = self;
    
    // this is SUPER hacky
    if ([[GameKitEventEngine sharedNetworkEngine] isRunning]) {
        gameEngine.networkEngine = [GameKitEventEngine sharedNetworkEngine];
    }
    

	[self scheduleUpdate];
}

- (void)shakeCamera
{
	cameraShakeTimeLeft = SHAKE_TIME;
}

- (void)update:(ccTime)deltaTime
{
	[gameEngine update:deltaTime];

	cameraShakeTimeLeft = MAX(0, cameraShakeTimeLeft - deltaTime);
	if (cameraShakeTimeLeft <= 0)
	{
		[backgroundLayer setPosition:ccp(0, 0)];
	}
	else
	{
		float period1 = cameraShakeTimeLeft / SHAKE_1_PERIOD;
		period1 = period1 - floorf(period1);
		float amp1 = SHAKE_1_AMP * sinf(period1 * 3.14159 * 2.0);

		float period2 = cameraShakeTimeLeft / SHAKE_2_PERIOD;
		period2 = period2 - floorf(period2);
		float amp2 = SHAKE_2_AMP * sinf(period2 * 3.14159 * 2.0);

		float envelope = MIN(1, cameraShakeTimeLeft / SHAKE_TIME);

		amp1 *= envelope;
		amp2 *= envelope;

		CGPoint offset = ccp(amp1 * SHAKE_1_X + amp2 * SHAKE_2_X, amp1 * SHAKE_1_Y + amp2 * SHAKE_2_Y);

		[backgroundLayer setPosition:offset];
		[monsterLayer setPosition:offset];
		[heroLayer setPosition:offset];
	}
}

- (void)clientReceivedEvent:(GameEvent *)event withState:(GameState *)state;
{
	NSLog(@"got event.  monster hp is %d", state->bossHealth);

	if (event->type == EGameEventType_MONSTER_DEAD)
	{
		NSLog(@"monster dead.  you win!");
	}

	if (event->type == EGameEventType_PLAYER_HIT && event->targetPlayerId == [gameEngine myPlayerNum])
	{
        [self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:monsterLayer.monster selector:@selector(playAttack1Anim)],
                         [CCDelayTime actionWithDuration:0.7],
                         [CCCallFunc actionWithTarget:heroLayer.hero selector:@selector(playHitAnim)],
                         [CCCallFunc actionWithTarget:self selector:@selector(shakeCamera)],
                         [CCDelayTime actionWithDuration:0.7],
                         [CCCallFunc actionWithTarget:heroLayer.hero selector:@selector(playHitAnim)],
                         [CCCallFunc actionWithTarget:self selector:@selector(shakeCamera)],
                         nil]];
	}
}

- (void)playAnimationWithEventType:(EGameEventType)eventType
{
    if (eventType == EGameEventType_ATTACK_FIRE)
    {
        [self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:heroLayer.hero selector:@selector(playAttackAnim)],
                         [CCDelayTime actionWithDuration:0.5],
                         [CCCallFunc actionWithTarget:monsterLayer.monster selector:@selector(playHitAnim)],
                         nil]];
    }
    else if (eventType == EGameEventType_ATTACK_ICE)
    {
        [self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:heroLayer.hero selector:@selector(playAttackAnim)],
                         [CCDelayTime actionWithDuration:0.5],
                         [CCCallFunc actionWithTarget:monsterLayer.monster selector:@selector(playHitAnim)],
                         nil]];
    }
    else if (eventType == EGameEventType_ATTACK_WIND)
    {
        [self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:heroLayer.hero selector:@selector(playAttackAnim)],
                         [CCDelayTime actionWithDuration:0.5],
                         [CCCallFunc actionWithTarget:monsterLayer.monster selector:@selector(playHitAnim)],
                         nil]];
    }
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
			event.type = EGameEventType_ATTACK_FIRE;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
            [self playAnimationWithEventType:event.type];
		}
		else if (singleGesture.gesture == EGesture_WIND)
		{
			GameEvent event;
			event.type = EGameEventType_ATTACK_WIND;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
            [self playAnimationWithEventType:event.type];
		}
		else if (singleGesture.gesture == EGesture_ICE)
		{
			GameEvent event;
			event.type = EGameEventType_ATTACK_ICE;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
            [self playAnimationWithEventType:event.type];
		}
		else if (singleGesture.gesture == EGesture_HEAL)
		{
			GameEvent event;
			event.type = EGameEventType_HEAL;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
            [self playAnimationWithEventType:event.type];
		}
		else if (singleGesture.gesture == EGesture_RECEIVE_HEAL)
		{
			GameEvent event;
			event.type = EGameEventType_RECEIVE_HEAL;
			event.value = 1;
			[gameEngine sendEventAsClient:&event];
            [self playAnimationWithEventType:event.type];
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
				event.type = EGameEventType_ATTACK_FIRE;
				event.value = 3;
				[gameEngine sendEventAsClient:&event];
                [self playAnimationWithEventType:event.type];
			}
			else if (firstGesture.gesture == EGesture_WIND)
			{
				GameEvent event;
				event.type = EGameEventType_ATTACK_WIND;
				event.value = 3;
				[gameEngine sendEventAsClient:&event];
                [self playAnimationWithEventType:event.type];
			}
			else if (firstGesture.gesture == EGesture_ICE)
			{
				GameEvent event;
				event.type = EGameEventType_ATTACK_ICE;
				event.value = 3;
				[gameEngine sendEventAsClient:&event];
                [self playAnimationWithEventType:event.type];
			}
		}
	}
}

@end
