//
//  GameHeroLayer.m
//  rant
//

#import "GameHeroLayer.h"
#import "GameHeroNode.h"


@implementation GameHeroLayer

@synthesize hero;

- (void)onEnter
{
    [super onEnter];
    
    hero = [CCSprite spriteWithFile:@"gameHero_placeholder.png"];
    [hero setPosition:ccp(100, 94)];
    
    [self addChild:hero];
}

@end
