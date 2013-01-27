#import "LobbyScene.h"
#import "GameScene.h"
#import "GameKitEventEngine.h"
#import "SimpleAudioEngine.h"


#define ANIMATION_DELAY 0.3


@interface LobbyLayer : CCLayer
{
}

@end



@implementation LobbyLayer
{
	CCMenuItemImage * enterGameButton;
	CCLabelTTF * playersInGameLabel;
    
    CCSpriteBatchNode *spriteSheet;
    NSMutableArray *heroAnims;
}

- (void)pollMatch
{
    if ([[GameKitEventEngine sharedNetworkEngine] isMatchReady]) {
        
        NSLog(@"match is ready, %d players!",
              [[GameKitEventEngine sharedNetworkEngine].match.playerIDs count]+1);
    }
}

-(void)onEnter
{
    // Create the layer hierarchy
    [super onEnter];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgmusic1.caf"];
	
    [[GameKitEventEngine sharedNetworkEngine] authenticate];

    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pollMatch) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameBegin:) name:GameEngineGameBeginNotification object:[GameKitEventEngine sharedNetworkEngine]];
    
        
    CCSprite *background = [CCSprite spriteWithFile:@"lobbyBackground.png"];
    [background setPosition:ccp(160, 240)];
    [self addChild:background];
    

    playersInGameLabel = [CCLabelTTF labelWithString:@"Players: ???" fontName:RANT_FONT fontSize:26];
	[self addChild:playersInGameLabel];


	// ask director for the window size
//	CGSize size = [[CCDirector sharedDirector] winSize];

    CCMenuItemImage *findMatchButton = [CCMenuItemImage itemWithNormalImage:@"buttonBlue.png"
                                                              selectedImage:@"buttonBluePressed.png"
                                                                     target:self
                                                                   selector:@selector(didTapFindMatchButton:)];

    CGPoint savedPoint = ccp([findMatchButton boundingBox].size.width * 0.5f,
                             [findMatchButton boundingBox].size.height * 0.5f);

    [findMatchButton setPosition:ccp(0, 160)];
    CCLabelTTF *findMatchLabel = [CCLabelTTF labelWithString:@"Find Match" fontName:RANT_FONT fontSize:32];
    [findMatchButton addChild:findMatchLabel];
    [findMatchLabel setPosition:savedPoint];
    
    enterGameButton = [CCMenuItemImage itemWithNormalImage:@"buttonRed.png"
                                             selectedImage:@"buttonRedPressed.png"
                                                    target:self
                                                  selector:@selector(didTapEnterGameButton:)];
    
    savedPoint = ccp([enterGameButton boundingBox].size.width * 0.5f,
                     [enterGameButton boundingBox].size.height * 0.5f);
    
    [enterGameButton setPosition:ccp(0, 60)];
    CCLabelTTF *enterGameLabel = [CCLabelTTF labelWithString:@"Enter Game" fontName:RANT_FONT fontSize:32];
    [enterGameButton addChild:enterGameLabel];
    [enterGameLabel setPosition:savedPoint];

	CCMenu *menu = [CCMenu menuWithItems:findMatchButton, enterGameButton, nil];
    [self addChild:menu];
    
    // Animations -
    // Load spritesheet
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lobbyHeroes.plist"];
    spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"lobbyHeroes.png"];
    [self addChild:spriteSheet];
    
    // Anims
    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i)
    {
        [animFrames removeAllObjects];
        
        [animFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"User Icon %dA.png", i]]];
        [animFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"User Icon %dB.png", i]]];
        
        CCAnimation *playerAnim = [CCAnimation animationWithSpriteFrames:animFrames];
        [playerAnim setDelayPerUnit:ANIMATION_DELAY];
        [heroAnims addObject:playerAnim];
    }
}

- (void)gameBegin:(NSNotification *)note
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene scene] withColor:ccWHITE]];

}

- (void)didTapFindMatchButton:(id)sender
{
    if ([[GameKitEventEngine sharedNetworkEngine] isMatchReady]) {
        [[GameKitEventEngine sharedNetworkEngine] begin];
        
        
    } else {
        [[GameKitEventEngine sharedNetworkEngine] findMatch];
    }
}

- (void)didTapEnterGameButton:(id)sender
{
    // todo..
}

- (void)enableEnterGameButton:(BOOL)enable
{
    [enterGameButton setVisible:enable];
}

- (void)clearPlayerIcons
{
    
}

- (void)addPlayerIconWithIndex:(int)index isPlayer:(BOOL)isPlayer // index 0-3
{
    NSAssert((index >= 0 && index <= 3), @"Invalid index");
    
    
}

@end



@implementation LobbyScene

+(CCScene *) scene
{
	CCScene *scene = [LobbyScene node];

	LobbyLayer *layer = [LobbyLayer node];

	[scene addChild: layer];

	return scene;
}

-(void) onEnter
{
	[super onEnter];
}

@end



