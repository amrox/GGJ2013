#import "GameScene.h"
#import "ResultsScene.h"

#import "GameBackgroundLayer.h"
#import "GameMonsterLayer.h"
#import "GameHUDLayer.h"
#import "GameHeroLayer.h"

@protocol GameClientDelegate <NSObject>

- (void)monsterHPChangedTo:(int)hp;

@end


@interface GameClient

- (void)attack;

@property (nonatomic, weak) NSObject<GameClientDelegate> * delegate;

@end



@implementation GameClient

- (void)attack
{
	[self.delegate monsterHPChangedTo:10];
}

@end


@interface GameScene() <GameClientDelegate>
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
    [gestureLayer setDelegate:self];
    
    [self addChild:backgroundLayer];
    [self addChild:monsterLayer];
    [self addChild:heroLayer];
    [self addChild:hudLayer];
    [self addChild:gestureLayer];
}

- (void)monsterHPChangedTo:(int)hp
{
	NSLog(@"monster HP changed to %d", hp);
}

#pragma mark - Gesture Receiver methods

- (void)gestureRegistered:(Gesture *)gesture
{
    [hudLayer gestureRegistered:gesture];
}

- (void)gestureChainCompleted:(NSArray *)gestureChain
{
    
}

@end



