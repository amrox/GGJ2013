//
//  GameHUDLayer.m
//  rant
//

#import "GameHUDLayer.h"
#import "cocos2d.h"

#import "GameGestureLayer.h"


@implementation GameHUDLayer
{
	CCMenuItemImage * spellBookButton;
}

-(void)onEnter
{
    [super onEnter];

    spellBookButton = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
											 selectedImage:@"start-menu-button-pressed.png"
													target:self
												  selector:@selector(spellBookPressed:)];

    [spellBookButton setPosition:ccp(-80,220)];

	CCMenu *menu = [CCMenu menuWithItems:spellBookButton, nil];
    [self addChild:menu];
}

- (void)gestureRegistered:(Gesture *)gesture
{
}

- (void)spellBookPressed:(id)sender
{
}

@end
