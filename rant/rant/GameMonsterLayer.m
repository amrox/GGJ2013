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
    
    monster = [CCSprite spriteWithFile:@"gameMonster1.png"];
    [monster setPosition:ccp(190, 260)];
    
    [self addChild:monster];
}

@end
