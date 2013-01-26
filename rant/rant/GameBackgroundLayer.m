//
//  GameBackgroundLayer.m
//  rant


#import "GameBackgroundLayer.h"


#define CLOUD_Y 400
#define CLOUD_START_X 400
#define CLOUD_END_X -100

@implementation GameBackgroundLayer

@synthesize cloud;

- (void)onEnter
{
    [super onEnter];
    
    CCSprite *background1 = [CCSprite spriteWithFile:@"gameBackground1.png"];
    [background1 setPosition:ccp(160, 240)];
    
    cloud = [CCSprite spriteWithFile:@"gameBackgroundCloud.png"];
    [cloud setPosition:ccp(160, 440)];
    
    CCSprite *background2 = [CCSprite spriteWithFile:@"gameBackground2.png"];
    [background2 setPosition:ccp(160, 240)];
    
    [self addChild:background1];
    [self addChild:cloud];
    [self addChild:background2];
    
    [cloud runAction:[CCSequence actions:[CCMoveTo actionWithDuration:4.0 position:ccp(CLOUD_END_X, CLOUD_Y)], [CCCallFunc actionWithTarget:self selector:@selector(cloudLoop)], nil]];
}

- (void)cloudLoop
{
    int cloudY = CLOUD_Y + (arc4random() % 80) - 40;
    
    [cloud setPosition:ccp(CLOUD_START_X, cloudY)];
    [cloud runAction:[CCSequence actions:[CCMoveTo actionWithDuration:8.0 position:ccp(CLOUD_END_X, cloudY)], [CCCallFunc actionWithTarget:self selector:@selector(cloudLoop)], nil]];
}

@end
