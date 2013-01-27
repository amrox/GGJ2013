//
//  GameGestureLayer.m
//  rant
//

#import "GameGestureLayer.h"
#import "SimpleAudioEngine.h"

#define RANT_FONT @"Bernard MT Condensed"

#define PI 3.141592653589

typedef enum
{
	EGesture_NONE,
	EGesture_WATER,
	EGesture_FIRE,
} EGesture;


#define DIST_FOR_ACCURATE_ANGLE 60
#define ANGLE_DIFFERENCE_FOR_NEW_LEG (PI/3.0f)
#define MAX_POINTS 10000
#define MAX_LEGS 8

//#define RECORD_GESTURE_ANGLES

float angleBetweenPoints(CGPoint p1, CGPoint p2)
{
	return atan2f(p2.y - p1.y, p2.x - p1.x);
}

float distanceBetweenPoints(CGPoint p1, CGPoint p2)
{
	return sqrtf((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y));
}

float getDifferenceBetweenAngles(float a1, float a2)
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



@interface Gesture : NSObject

@property (nonatomic, strong) NSArray * legAngles;
@property (nonatomic, assign) EGesture gesture;

- (BOOL)matchesLegAngles:(float[])legAngles numLegs:(int)numLegs;

+ (NSArray*)gestureLibrary;

@end

@implementation Gesture

- (BOOL)matchesLegAngles:(float[])legAnglesArray numLegs:(int)numLegs
{
	if (numLegs != [self.legAngles count])
	{
		return NO;
	}
	for (int i = 0; i < numLegs; i++)
	{
		NSNumber * legAngle = [self.legAngles objectAtIndex:i];
		float angleDiff = getDifferenceBetweenAngles([legAngle floatValue], legAnglesArray[i]);
		if (fabsf(angleDiff) > ANGLE_DIFFERENCE_FOR_NEW_LEG)
		{
			return NO;
		}
	}
	return YES;
}

+ (NSArray*)gestureLibrary
{
	static NSMutableArray * sharedLibrary = nil;
	if (!sharedLibrary)
	{
		sharedLibrary = [NSMutableArray array];

		Gesture * fire = [[Gesture alloc] init];
		fire.gesture = EGesture_FIRE;
		fire.legAngles = [NSArray arrayWithObjects:[NSNumber numberWithFloat:PI*0.5f], [NSNumber numberWithFloat:-PI*0.5f], nil];
		[sharedLibrary addObject:fire];

		Gesture * water = [[Gesture alloc] init];
		water.gesture = EGesture_WATER;
		water.legAngles = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:PI], nil];
		[sharedLibrary addObject:water];
	}
	return sharedLibrary;
}

@end


@interface GestureRecognizer : NSObject

- (id)initAtStartingPos:(CGPoint)startingPos;
- (Gesture*)newTouchAt:(CGPoint)pos failed:(BOOL*)failed;

- (NSArray*)getChainedGestures;

@end




@implementation GestureRecognizer
{
	CGPoint points[MAX_POINTS];
	int numPoints;

	float legAngles[MAX_LEGS];
	int numLegs;

	NSMutableArray * chainedGestures;
	BOOL failed;

	float angleToIgnore;
	BOOL ignoringAngle;
}

- (id)initAtStartingPos:(CGPoint)startingPos
{
	if (self = [super init])
	{
		points[0] = startingPos;
		numPoints = 1;

		chainedGestures = [NSMutableArray array];
	}
	return self;
}


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
		float dist = distanceBetweenPoints(currentPoint, lastPoint);
		if (dist > DIST_FOR_ACCURATE_ANGLE)
		{
			float angle = angleBetweenPoints(currentPoint, lastPoint);
			*angleOut = angle;
			return YES;
		}
	}
	return NO;
}

- (Gesture*)newTouchAt:(CGPoint)pos failed:(BOOL*)failedOut
{
	*failedOut = NO;

	if (failed)
	{
		*failedOut = YES;
		return nil;
	}
	
	if (numPoints < MAX_POINTS)
	{
		points[numPoints] = pos;
		numPoints++;

		float currentAngle;
		if ([self getLatestAngle:&currentAngle])
		{
			if (numLegs == 0)
			{
				BOOL addAngle = YES;
				if (ignoringAngle)
				{
					float angleDiff = getDifferenceBetweenAngles(angleToIgnore, currentAngle);
					if (fabsf(angleDiff) < ANGLE_DIFFERENCE_FOR_NEW_LEG)
					{
						addAngle = NO;
					}
				}
				if (addAngle)
				{
					ignoringAngle = NO;
					legAngles[numLegs] = currentAngle;
					numLegs++;
#ifdef RECORD_GESTURE_ANGLES
					NSLog(@"gesture leg angle: %f", currentAngle);
#endif
				}
			}
			else
			{
				float angleDiff = getDifferenceBetweenAngles(legAngles[numLegs-1], currentAngle);
				if (fabsf(angleDiff) > ANGLE_DIFFERENCE_FOR_NEW_LEG)
				{
					if (numLegs >= MAX_LEGS-1)
					{
						failed = YES;
						*failedOut = YES;
						return nil;
					}
					else
					{
						legAngles[numLegs] = currentAngle;
						numLegs++;
#ifdef RECORD_GESTURE_ANGLES
						NSLog(@"gesture leg angle: %f", currentAngle);
#endif
						if ([self checkChainedGesture])
						{
							return [chainedGestures objectAtIndex:[chainedGestures count] - 1];
						}
					}
				}
			}
		}
	}
	return nil;
}

- (BOOL)checkChainedGesture
{
	NSArray * gestureLibrary = [Gesture gestureLibrary];
	for (Gesture * gesture in gestureLibrary)
	{
		if (numLegs > 0 && [gesture matchesLegAngles:legAngles numLegs:numLegs])
		{
			angleToIgnore = legAngles[numLegs-1];
			ignoringAngle = YES;

			[chainedGestures addObject:gesture];
			numLegs = 0;
			return YES;
		}
	}
	return NO;
}

- (NSArray*)getChainedGestures
{
	if (failed || numLegs > 1)
	{
		return nil;
	}

	return chainedGestures;
}

@end

@implementation GameGestureLayer
{
	CCMenuItemImage * gestureButton1;
	CCMenuItemImage * gestureButton2;
	CCMenuItemImage * gestureButton3;
    GestureRecognizer * currentGestureRecognizer;
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
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.2f];
	CGSize windowSize = [[CCDirector sharedDirector] winSize];

	self.isTouchEnabled = YES;
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

    gestureButton1 = [self makeButtonWithText:@"1" pos:ccp(80,windowSize.height - 30) selector:@selector(gesture1Pressed:)];
    gestureButton2 = [self makeButtonWithText:@"2" pos:ccp(80,windowSize.height - 70) selector:@selector(gesture2Pressed:)];
    gestureButton3 = [self makeButtonWithText:@"3" pos:ccp(80,windowSize.height - 110) selector:@selector(gesture3Pressed:)];

	CCMenu *menu = [CCMenu menuWithItems:gestureButton1, gestureButton2, gestureButton3, nil];
    

}



- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
//	NSLog(@"First touch is at %f %f" ,touchLocation.x, touchLocation.y);
    if (currentGestureRecognizer == nil)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"sine440.caf"];
        currentGestureRecognizer = [[GestureRecognizer alloc] initAtStartingPos:touchLocation];
    }
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
//	NSLog(@"Second touch is at %f %f" ,touchLocation.x, touchLocation.y);
    if (currentGestureRecognizer)
    {
		BOOL failed;
        Gesture * newGesture = [currentGestureRecognizer newTouchAt:touchLocation failed:&failed];
		if (failed)
		{
			NSLog(@"failed");
		}
		else if (newGesture)
		{
			NSLog(@"new gesture: %d", newGesture.gesture);
		}
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
//    CGPoint touchLocation = [touch locationInView:touch.view];
//	NSLog(@"3rd touch is at %f %f" ,touchLocation.x, touchLocation.y);
    if (currentGestureRecognizer)
    {
        NSArray * chainedGestures = [currentGestureRecognizer getChainedGestures];
		if (chainedGestures && [chainedGestures count] > 0)
		{
			NSLog(@"got gestures:");
			for (Gesture * gesture in chainedGestures)
			{
				NSLog(@"    gesture: %d", gesture.gesture);
			}
		}
		else
		{
			NSLog(@"No gestures");
		}
        currentGestureRecognizer = nil;
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
