#import "MainMenuScene.h"
#import "LobbyScene.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "StoryScene.h"


@interface MainMenuLayer : CCLayer
{
}

@end



@implementation MainMenuLayer
{
	CCMenuItemImage * singlePlayerGameButton;
    CCLabelTTF * singlePlayerGameLabel;

    CCMenuItemImage * mmPlayButton;

}


-(void)onEnter
{
    // Create the layer hierarchy
    [super onEnter];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgmusic1.caf"];
    
    CCSprite *homeBackground = [CCSprite spriteWithFile:@"mainMenuBackground.png"];
    [homeBackground setPosition:ccp(160, 240)];
    [self addChild:homeBackground];

    CCSprite *titleText = [CCSprite spriteWithFile:@"titleText2.png"];
    [titleText setPosition:ccp(160, 240)];
    [self addChild:titleText];


    
    
    mmPlayButton = [CCMenuItemImage itemWithNormalImage:@"mainMenuPlayButton.png"
                                                              selectedImage:@"mainMenuPlayButtonPressed.png"
                                                                     target:self
                                                                   selector:@selector(multiPlayerPressed:)];

    
    [mmPlayButton setPosition:ccp(0, -190)];
    
    
    singlePlayerGameButton = [CCMenuItemImage itemWithNormalImage:@"buttonBlue.png"
                                                    selectedImage:@"buttonBluePressed.png"
                                                           target:self
                                                         selector:@selector(singlePlayerPressed:)];
    
    [singlePlayerGameButton setPosition:ccp(-80,180)];
    
    CGPoint savedPoint = ccp([singlePlayerGameButton boundingBox].size.width * 0.5f,
                             [singlePlayerGameButton boundingBox].size.height * 0.5f);
    
    singlePlayerGameLabel = [CCLabelTTF labelWithString:@"1 Player" fontName:RANT_FONT fontSize:32];
    [singlePlayerGameLabel setColor:ccWHITE];
    [singlePlayerGameButton addChild:singlePlayerGameLabel];
    [singlePlayerGameLabel setPosition:savedPoint];
    
    [singlePlayerGameButton setScale:0.5];
    
    
    
    CCMenuItemImage *storyButton = [CCMenuItemImage itemWithNormalImage:@"buttonBlue.png"
                                                          selectedImage:@"buttonBluePressed.png"
                                                                 target:self
                                                               selector:@selector(storyPressed:)];
    
    [storyButton setPosition:ccp(80,180)];
    
    savedPoint = ccp([storyButton boundingBox].size.width * 0.5f,
                             [storyButton boundingBox].size.height * 0.5f);
    
    CCLabelTTF *storyGameLabel = [CCLabelTTF labelWithString:@"Story" fontName:RANT_FONT fontSize:32];
    [storyGameLabel setColor:ccWHITE];
    [storyButton addChild:storyGameLabel];
    [storyGameLabel setPosition:savedPoint];
    
    [storyButton setScale:0.5];
    
    
    CCMenu *menu = [CCMenu menuWithItems:mmPlayButton, singlePlayerGameButton, storyButton, nil];
    [self addChild:menu];
}

- (void)multiPlayerPressed:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LobbyScene scene] withColor:ccWHITE]];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];   
    [[SimpleAudioEngine sharedEngine] playEffect:@"click1.caf"];

}

- (void)singlePlayerPressed:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene scene] withColor:ccWHITE]];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playEffect:@"click1.caf"];

    
//	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LobbyScene scene] withColor:ccWHITE]];
}

- (void)storyPressed:(id)sender
{
    StoryScene *scene = [[StoryScene alloc] initWithIndex:1];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playEffect:@"click1.caf"];
}

@end



@implementation MainMenuScene

+(CCScene *) scene
{
	CCScene *scene = [MainMenuScene node];
    
	MainMenuLayer *layer = [MainMenuLayer node];
    
	[scene addChild: layer];
    
	return scene;
}

-(void) onEnter
{
	[super onEnter];
}

@end



