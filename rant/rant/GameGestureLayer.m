//
//  GameGestureLayer.m
//  rant
//

#import "GameGestureLayer.h"

#define RANT_FONT @"Bernard MT Condensed"


@implementation GameGestureLayer
{
	CCMenuItemImage * gestureButton1;
}

-(void)onEnter
{
    [super onEnter];
	self.isTouchEnabled = YES;
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

    gestureButton1 = [CCMenuItemImage itemWithNormalImage:@"start-menu-button.png"
											 selectedImage:@"start-menu-button-pressed.png"
													target:self
												  selector:@selector(gesture1Pressed:)];

    CGPoint savedPoint = ccp([gestureButton1 boundingBox].size.width * 0.5f,
                             [gestureButton1 boundingBox].size.height * 0.5f);

    [gestureButton1 setPosition:ccp(0,-100)];
    CCLabelTTF * label = [CCLabelTTF labelWithString:@"" fontName:RANT_FONT fontSize:26];
    [gestureButton1 addChild:label];
    [gestureButton1 setPosition:savedPoint];

	CCMenu *menu = [CCMenu menuWithItems:gestureButton1, nil];
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

@end
