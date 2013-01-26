//
//  GameMonsterLayer.m
//  rant
//

#import "GameMonsterLayer.h"


@implementation GameMonsterLayer

@synthesize monster;

+ (id)node
{
    id node = [super node];
    
    return node;
}

- (void)onEnter
{
    [super onEnter];
    
    monster = [CCSprite spriteWithFile:@"gameMonster_placeholder.png"];
    [monster setPosition:ccp(200, 160)];
    
    [self addChild:monster];
}

@end
