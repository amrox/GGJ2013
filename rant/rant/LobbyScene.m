#import "LobbyScene.h"
#import "GameScene.h"


#define RANT_FONT @"Bernard MT Condensed"



@interface LobbyLayer : CCLayer
{
}

@end



@implementation LobbyLayer
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
    enterGameLabel = [CCLabelTTF labelWithString:@"Menu text" fontName:RANT_FONT fontSize:26];
    [enterGameButton addChild:enterGameLabel];
    [enterGameLabel setPosition:savedPoint];

	CCMenu *menu = [CCMenu menuWithItems:enterGameButton, nil];
    [self addChild:menu];
}

- (void)enterGamePressed:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene scene] withColor:ccWHITE]];
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



