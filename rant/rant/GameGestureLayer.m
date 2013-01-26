//
//  GameGestureLayer.m
//  rant
//

#import "GameGestureLayer.h"

#define RANT_FONT @"Bernard MT Condensed"

typedef enum
{
	EGesture_NONE,
	EGesture_WATER,
	EGesture_FIRE,
} EGesture;



@interface Gesture : NSObject

- (id)initAtStartingPos:(CGPoint)startingPos;
- (void)newTouchAt:(CGPoint)pos;
- (void)close;

- (EGesture)getGesture;

@end




@implementation Gesture

- (id)initAtStartingPos:(CGPoint)startingPos
{
	if (self = [super init])
	{
	}
	return self;
}

- (void)newTouchAt:(CGPoint)pos
{

}

- (void)close
{

}

- (EGesture)getGesture
{
	return EGesture_NONE;
}

@end

@implementation GameGestureLayer
{
	CCMenuItemImage * gestureButton1;
	CCMenuItemImage * gestureButton2;
	CCMenuItemImage * gestureButton3;
}

- (CCMenuItemImage*)makeButtonWithText:(NSString*)text pos:(CGPoint)pos selector:(SEL)selector
{
    [super onEnter];
	self.isTouchEnabled = YES;
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

    gestureButton1 = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
											 selectedImage:@"start-menu-button-pressed.png"
													target:self
												  selector:@selector(gesture1Pressed:)];
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
    CGPoint touchLocation = [touch locationInView:touch.view];
	NSLog(@"First touch is at %f %f" ,touchLocation.x, touchLocation.y);
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
	NSLog(@"Second touch is at %f %f" ,touchLocation.x, touchLocation.y);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
	NSLog(@"3rd touch is at %f %f" ,touchLocation.x, touchLocation.y);
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
