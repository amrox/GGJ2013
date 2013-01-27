//
//  GameHeroNode.m
//  rant
//

#import "GameHeroNode.h"


@implementation GameHeroNode

@synthesize currentHP;
@synthesize currentMP;
@synthesize maxHP;
@synthesize maxMP;

- (void)onEnter
{
    [super onEnter];
    
    currentHP = 100.0;
    currentMP = 100.0;
    maxHP = 100.0;
    maxMP = 100.0;
}

@end
