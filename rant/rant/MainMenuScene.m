#import "MainMenuScene.h"
#import "LobbyScene.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"


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
    
    singlePlayerGameButton = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
                                                    selectedImage:@"start-menu-button-pressed.png"
                                                           target:self
                                                         selector:@selector(singlePlayerPressed:)];
    
    CGPoint singlePlayerGameButtonPoint = ccp([singlePlayerGameButton boundingBox].size.width * 0.5f,
                                              [singlePlayerGameButton boundingBox].size.height * 0.5f);
    [singlePlayerGameButton setPosition:ccp(0,-100)];
    singlePlayerGameLabel = [CCLabelTTF labelWithString:@"Single Player" fontName:RANT_FONT fontSize:26];
    [singlePlayerGameLabel setColor:ccWHITE];
    [singlePlayerGameButton addChild:singlePlayerGameLabel];
    [singlePlayerGameButton setPosition:singlePlayerGameButtonPoint];
    
    CCMenu *menu = [CCMenu menuWithItems:mmPlayButton, singlePlayerGameButton, nil];
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



