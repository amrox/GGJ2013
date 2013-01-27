#import "MainMenuScene.h"
#import "LobbyScene.h"
#import "GameScene.h"




@interface MainMenuLayer : CCLayer
{
}

@end



@implementation MainMenuLayer
{
	CCMenuItemImage * enterGameButton;
	CCLabelTTF * enterGameLabel;
}

-(void)onEnter
{
    // Create the layer hierarchy
    [super onEnter];

	// ask director for the window size
//	CGSize size = [[CCDirector sharedDirector] winSize];

    enterGameButton = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
										  selectedImage:@"start-menu-button-pressed.png"
												 target:self
											   selector:@selector(enterGamePressed:)];

    CGPoint savedPoint = ccp([enterGameButton boundingBox].size.width * 0.5f,
                             [enterGameButton boundingBox].size.height * 0.5f);

    [enterGameButton setPosition:ccp(0,-100)];
    enterGameLabel = [CCLabelTTF labelWithString:@"Find Game" fontName:RANT_FONT fontSize:26];
    [enterGameLabel setColor:ccWHITE];
    [enterGameButton addChild:enterGameLabel];
    [enterGameLabel setPosition:savedPoint];

	CCMenu *menu = [CCMenu menuWithItems:enterGameButton, nil];
    [self addChild:menu];
}

- (void)enterGamePressed:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LobbyScene scene] withColor:ccWHITE]];
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



