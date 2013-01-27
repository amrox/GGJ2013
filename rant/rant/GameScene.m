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
#import "GameMonsterNode.h"
#import "MainMenuScene.h"
#import "GameMonsterHealthBar.h"

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
	float monsterPrepareTime;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameEnd) name:GameEngineGameEndNotification object:[GameKitEventEngine sharedNetworkEngine]];
}

- (void)gameEnd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GameEngineGameEndNotification object:[GameKitEventEngine sharedNetworkEngine]];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccWHITE]];
}

- (void)shakeCamera
{
	cameraShakeTimeLeft = SHAKE_TIME;
}

- (void)update:(ccTime)deltaTime
{
	[gameEngine update:deltaTime];
	monsterPrepareTime -= deltaTime;
	[self updateMonsterPrepareTime];

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
	NSLog(@"got event.  monster hp is %d.  player 0 health is %d", state->bossHealth, state->playerHeath[0]);

	if (event->type == EGameEventType_MONSTER_DEAD)
	{
		NSLog(@"monster dead.  you win!");
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccWHITE]];
	}
	else if (event->type == EGameEventType_PLAYER_HIT && event->targetPlayerId == [gameEngine myPlayerNum])
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
	else if (event->type == EGameEventType_MONSTER_PREPARING_TO_ATTACK && event->targetPlayerId == [gameEngine myPlayerNum])
	{
		[monsterLayer.monster playAttack3Anim];
		monsterPrepareTime = ATTACK_PREPARATION_TIME;
	}
	else if (event->type == EGameEventType_PLAYER_DIED)
	{
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccWHITE]];
	}
	else if (event->type == EGameEventType_MONSTER_ATTACK_BLOCKED)
	{
		monsterPrepareTime = 0;
	}

	int playerId = [gameEngine myPlayerNum];
	int playerHealth = state->playerHeath[playerId];
	int bossHealth = state->bossHealth;

	[hudLayer.heroHealthBar setHealthBarPercentage:(float)playerHealth / MAX_PLAYER_HEALTH animated:YES];
	[hudLayer.monsterHealthBar setHealthBarPercentage:(float)bossHealth / BOSS_MAX_HEALTH animated:YES];

	[self updateMonsterPrepareTime];
}

- (void)updateMonsterPrepareTime
{
	if (monsterPrepareTime <= 0)
	{
		hudLayer.monsterAttackBar.visible = NO;
	}
	else
	{
		float perc = monsterPrepareTime / ATTACK_PREPARATION_TIME;
		hudLayer.monsterAttackBar.visible = YES;
		[hudLayer.monsterAttackBar setHealthBarPercentage:perc animated:YES];
	}
}

- (void)playAnimationWithEventType:(EGameEventType)eventType
{
    if (eventType == EGameEventType_ATTACK_FIRE)
    {
		[heroLayer.hero playAttackAnim];
    }
    else if (eventType == EGameEventType_ATTACK_ICE)
    {
		[heroLayer.hero playAttackAnim];
    }
    else if (eventType == EGameEventType_ATTACK_WIND)
    {
		[heroLayer.hero playAttackAnim];
    }

	if (gameEngine.currentState.monsterPreparingToAttackPlayerId == -1)
	{
        [self runAction:[CCSequence actions:
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
