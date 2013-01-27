//
//  GameMonsterLayer.m
//  rant
//

#import "GameMonsterLayer.h"
#import "GameMonsterNode.h"

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
    
    monster = [[GameMonsterNode alloc] initWithIndex:0];
    [monster setPosition:ccp(190, 280)];
    
    [self addChild:monster];
}

@end
