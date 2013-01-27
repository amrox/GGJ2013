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
    
    
}

- (void)spell1Pressed:(id)sender
{
}

@end





@implementation GameHUDLayer
{
	CCMenuItemImage * spellBookButton;
	SpellBookLayer * spellBookLayer;
    
    CCSprite *attackBar;
}

@synthesize monsterHealthBar;
@synthesize monsterAttackBar;
@synthesize heroHealthBar;

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
    
    
    monsterHealthBar = [[GameMonsterHealthBar alloc] initWithGreenBar:YES];
    [monsterHealthBar setPosition:ccp(160, 440)];
    [self addChild:monsterHealthBar];
    
    monsterAttackBar = [[GameMonsterHealthBar alloc] initWithGreenBar:NO];
    [monsterAttackBar setPosition:ccp(180, 380)];
    [monsterAttackBar setScale:0.8];
    [self addChild:monsterAttackBar];
    
    heroHealthBar = [[GameMonsterHealthBar alloc] initWithGreenBar:YES];
    [heroHealthBar setPosition:ccp(80, 160)];
    [heroHealthBar setScale:0.5];
    [self addChild:heroHealthBar];
    
    
}

- (void)gestureRegistered:(Gesture *)gesture
{
}

- (void)spellBookPressed:(id)sender
{
}

@end
