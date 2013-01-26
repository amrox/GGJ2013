//
//  GameGestureLayer.m
//  rant
//

#import "GameGestureLayer.h"

#define RANT_FONT @"Bernard MT Condensed"


@implementation GameGestureLayer
{
	CCMenuItemImage * gestureButton1;
	CCMenuItemImage * gestureButton2;
	CCMenuItemImage * gestureButton3;
}

- (CCMenuItemImage*)makeButtonWithText:(NSString*)text pos:(CGPoint)pos selector:(SEL)selector
{
    CCMenuItemImage * button = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
											selectedImage:@"start-menu-button-pressed.png"
												   target:self
												 selector:selector];

    CGPoint savedPoint = ccp([gestureButton1 boundingBox].size.width * 0.5f,
                             [gestureButton1 boundingBox].size.height * 0.5f);

    [button setPosition:pos];
    CCLabelTTF * label = [CCLabelTTF labelWithString:text fontName:RANT_FONT fontSize:26];
    [label setPosition:savedPoint];
    [button addChild:label];

	return button;
}

-(void)onEnter
{
	[super onEnter];

	CGSize windowSize = [[CCDirector sharedDirector] winSize];

	self.isTouchEnabled = YES;
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

    gestureButton1 = [self makeButtonWithText:@"1" pos:ccp(80,windowSize.height - 30) selector:@selector(gesture1Pressed:)];
    gestureButton2 = [self makeButtonWithText:@"2" pos:ccp(80,windowSize.height - 70) selector:@selector(gesture2Pressed:)];
    gestureButton3 = [self makeButtonWithText:@"3" pos:ccp(80,windowSize.height - 110) selector:@selector(gesture3Pressed:)];

	CCMenu *menu = [CCMenu menuWithItems:gestureButton1, gestureButton2, gestureButton3, nil];
    [self addChild:menu];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog(@"1");
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog(@"2");
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog(@"3");
}

- (void)gesture1Pressed:(id)sender
{
	NSLog(@"gesture 1");
}

- (void)gesture2Pressed:(id)sender
{
	NSLog(@"gesture 2");
}

- (void)gesture3Pressed:(id)sender
{
	NSLog(@"gesture 3");
}

@end
