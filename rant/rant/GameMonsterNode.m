//
//  GameMonsterNode.m
//  rant
//
//  Created by Tedo Salim on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameMonsterNode.h"


@implementation GameMonsterNode

@synthesize currentHP;
@synthesize maxHP;

- (void)onEnter
{
    [super onEnter];
    
    currentHP = 100.0;
    maxHP = 100.0;
}

@end
