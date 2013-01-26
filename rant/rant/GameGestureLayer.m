//
//  GameGestureLayer.m
//  rant
//

#import "GameGestureLayer.h"

#define RANT_FONT @"Bernard MT Condensed"

#define PI 3.141592653589

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



#define MAX_POINTS 10000
#define MAX_LEGS 100

@implementation Gesture
{
	CGPoint points[MAX_POINTS];
	int numPoints;

	float legAngles[MAX_LEGS];
	int numLegs;
}

- (id)initAtStartingPos:(CGPoint)startingPos
{
	if (self = [super init])
	{
		points[0] = startingPos;
		numPoints = 1;
	}
	return self;
}

- (float)angleBetweenPoint:(CGPoint)p1 and:(CGPoint)p2
{
	return atan2f(p2.y - p1.y, p2.x - p1.x);
}

- (float)distanceBetweenPoint:(CGPoint)p1 and:(CGPoint)p2
{
	return sqrtf((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y));
}

- (float)getDifferenceBetweenAngle:(float)a1 and:(float)a2
{
	float diff = a2 - a1;
	while (diff > PI)
	{
		diff -= PI*2.0f;
	}
	while (diff < -PI)
	{
		diff += PI*2.0f;
	}
	return diff;
}

#define DIST_FOR_ACCURATE_ANGLE 60
#define ANGLE_DIFFERENCE_FOR_NEW_LEG (PI/3.0f)

- (BOOL)getLatestAngle:(float*)angleOut
{
	if (numPoints < 2)
	{
		return NO;
	}

	CGPoint lastPoint = points[numPoints-1];
	for (int i = numPoints - 2; i >= 0; i--)
	{
		CGPoint currentPoint = points[i];
		float dist = [self distanceBetweenPoint:currentPoint and:lastPoint];
		if (dist > DIST_FOR_ACCURATE_ANGLE)
		{
			float angle = [self angleBetweenPoint:currentPoint and:lastPoint];
			*angleOut = angle;
			return YES;
		}
	}
	return NO;
}

- (void)newTouchAt:(CGPoint)pos
{
	if (numPoints < MAX_POINTS)
	{
		points[numPoints] = pos;
		numPoints++;

		float currentAngle;
		if ([self getLatestAngle:&currentAngle])
		{
			if (numLegs == 0)
			{
				legAngles[numLegs] = currentAngle;
				numLegs++;
			}
			else
			{
				float angleDiff = [self getDifferenceBetweenAngle:legAngles[numLegs-1] and:currentAngle];
				if (fabsf(angleDiff) > ANGLE_DIFFERENCE_FOR_NEW_LEG)
				{
					legAngles[numLegs] = currentAngle;
					numLegs++;
				}
			}
		}
	}
}

- (void)close
{

}

- (EGesture)getGesture
{
	for (int i = 0; i < numLegs; i++)
	{
		NSLog(@"leg: %f", legAngles[i]);
	}

	return EGesture_NONE;
}

@end

@implementation GameGestureLayer
{
	CCMenuItemImage * gestureButton1;
	CCMenuItemImage * gestureButton2;
	CCMenuItemImage * gestureButton3;
    Gesture * currentGesture;
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
    CGPoint touchLocation = [touch locationInView:touch.view];
//	NSLog(@"First touch is at %f %f" ,touchLocation.x, touchLocation.y);
    if (currentGesture == nil)
    {
        currentGesture = [[Gesture alloc] initAtStartingPos:touchLocation];
    }
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
//	NSLog(@"Second touch is at %f %f" ,touchLocation.x, touchLocation.y);
    if (currentGesture)
    {
        [currentGesture newTouchAt:touchLocation];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
//    CGPoint touchLocation = [touch locationInView:touch.view];
//	NSLog(@"3rd touch is at %f %f" ,touchLocation.x, touchLocation.y);
    if (currentGesture)
    {
        [currentGesture getGesture];
        currentGesture = nil;
    }
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
