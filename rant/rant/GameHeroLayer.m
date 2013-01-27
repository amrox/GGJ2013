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
    
    hero = [[GameHeroNode alloc] initWithIndex:arc4random() % 4];
    [hero setPosition:ccp(100, 81)];
    
    [self addChild:hero];
}

@end
