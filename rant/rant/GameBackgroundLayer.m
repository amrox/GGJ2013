//
//  GameBackgroundLayer.m
//  rant


#import "GameBackgroundLayer.h"


@implementation GameBackgroundLayer

- (void)onEnter
{
    CCSprite *background = [CCSprite spriteWithFile:@"gameBackground_placeholder.png"];
    [background setPosition:ccp(160, 240)];
    
    [self addChild:background];
}

@end
