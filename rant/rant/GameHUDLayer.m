//
//  GameHUDLayer.m
//  rant
//

#import "GameHUDLayer.h"
#import "cocos2d.h"

#import "GameGestureLayer.h"
#import "GameMonsterHealthBar.h"


@interface SpellBookLayer : CCLayer {

}

@end



@implementation SpellBookLayer
{
	CCMenuItemImage * spell1Button;
	CCMenuItemImage * spell2Button;
	CCMenuItemImage * spell3Button;
	CCMenuItemImage * spell4Button;
	CCMenuItemImage * spell5Button;
	CCMenuItemImage * spell6Button;
    
    GameMonsterHealthBar *monsterHealthBar;
}

-(void)onEnter
{
    [super onEnter];

    spell1Button = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
															selectedImage:@"start-menu-button-pressed.png"
																   target:self
																 selector:@selector(spell1Pressed:)];
    [spell1Button setPosition:ccp(-80,220)];
	
	CCMenu *menu = [CCMenu menuWithItems:spell1Button, nil];
    [self addChild:menu];
    
    monsterHealthBar = [GameMonsterHealthBar node];
    [monsterHealthBar setPosition:ccp(160, 400)];
    [self addChild:monsterHealthBar];
}

- (void)spell1Pressed:(id)sender
{
}

@end





@implementation GameHUDLayer
{
	CCMenuItemImage * spellBookButton;
	SpellBookLayer * spellBookLayer;
}

-(void)onEnter
{
    [super onEnter];

//    spellBookButton = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
//											 selectedImage:@"start-menu-button-pressed.png"
//													target:self
//												  selector:@selector(spellBookPressed:)];
//
//    [spellBookButton setPosition:ccp(-80,220)];
//
//	CCMenu *menu = [CCMenu menuWithItems:spellBookButton, nil];
//    [self addChild:menu];
//
//	spellBookLayer = [SpellBookLayer node];
//    [self addChild:spellBookLayer];
}

- (void)gestureRegistered:(Gesture *)gesture
{
}

- (void)spellBookPressed:(id)sender
{
}

@end
