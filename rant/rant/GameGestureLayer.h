//
//  GameGestureLayer.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


typedef enum
{
	EGesture_NONE,
	EGesture_WATER,		//figure 8
	EGesture_FIRE,		//z with return
	EGesture_AIR,		//square
	EGesture_ATTACK,	//stab
	EGesture_HEAL,		//backwards c
} EGesture;



@interface Gesture : NSObject

@property (nonatomic, strong) NSArray * legAngles;
@property (nonatomic, assign) EGesture gesture;

- (BOOL)matchesLegAngles:(float[])legAngles numLegs:(int)numLegs;

+ (NSArray*)gestureLibrary;

@end


@protocol GestureReceiver <NSObject>

@optional
- (void)gestureRegistered:(Gesture *)gesture;
- (void)gestureChainCompleted:(NSArray *)gestureChain;
@end

@interface GameGestureLayer : CCLayer {
    
}

@end
