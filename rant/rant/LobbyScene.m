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
    NSMutableArray *heroes;
    
    int lastPlayerCount;
}

- (void)pollMatch
{
    int curPlayerCount = [[GameKitEventEngine sharedNetworkEngine] matchPlayerCount];
    
    if (lastPlayerCount > curPlayerCount) {
        [self clearPlayerIcons];
    }

    int heroesToAdd = curPlayerCount - [heroes count];
    for (int i=0; i<heroesToAdd; i++) {
        [self addPlayerIconWithIndex:[heroes count] isPlayer:YES];
        
    }
    lastPlayerCount = curPlayerCount;
    
    [self enableEnterGameButton:(curPlayerCount > 1)];
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
    heroAnims = [NSMutableArray array];
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
    
    heroes = [NSMutableArray array];
}

- (void)gameBegin:(NSNotification *)note
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene scene] withColor:ccWHITE]];

}

- (void)didTapFindMatchButton:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click1.caf"];
    [[GameKitEventEngine sharedNetworkEngine] findMatch];
}

- (void)didTapEnterGameButton:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click1.caf"];
    [[GameKitEventEngine sharedNetworkEngine] begin];
}

- (void)enableEnterGameButton:(BOOL)enable
{
    [enterGameButton setVisible:enable];
}

- (void)clearPlayerIcons
{
    for (CCSprite *hero in heroes)
    {
        [hero removeFromParentAndCleanup:YES];
    }
    
    [heroes removeAllObjects];
}

- (void)loopPlayerIcon:(id)sender data:(int)index {
    CCSprite *sprite = [heroes objectAtIndex:index];
    [sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[heroAnims objectAtIndex:index]]]];
}

- (void)addPlayerIconWithIndex:(int)index isPlayer:(BOOL)isPlayer // index 0-3
{
    NSAssert((index >= 0 && index <= 3), @"Invalid index");
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"User Icon %dA.png", index+1]];
    [spriteSheet addChild:sprite];
    
    [heroes addObject:sprite];
    
    float random = (float)(arc4random() % 100) / 100.0;
    
    [sprite runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:random],
                       [CCCallFuncND actionWithTarget:self selector:@selector(loopPlayerIcon:data:) data:(void *)index],
                       nil
                       ]
     ];
    
    [sprite setPosition:ccp(160, 90)];
    [sprite setScale:0.2];
    
    [self assembleHeroes];
}

- (void)assembleHeroes
{
    CGPoint center = ccp(160, 90);
    
    static int offset = 60;
    
    int index = 0;
    int total = [heroes count]-1;
    for (CCSprite *hero in heroes)
    {
        [hero runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(center.x - (offset/2 * total) + (offset * index), center.y)]];
        [hero runAction:[CCScaleTo actionWithDuration:1.0 scale:0.8]];
        index++;
    }
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



