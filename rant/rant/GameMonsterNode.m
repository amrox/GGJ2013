//
//  GameMonsterNode.m
//  rant
//
//  Created by Tedo Salim on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameMonsterNode.h"

#define ANIMATION_DELAY 0.35

@implementation GameMonsterNode
{
    CCSprite * sprite;
    CCAnimation *attack1Anim;
    CCAnimation *attack2Anim;
    CCAnimation *attack3Anim;
    CCAnimation *idleAnim;
}

@synthesize currentHP;
@synthesize maxHP;

- (id)initWithIndex:(int)index
{
    if (self = [super init])
    {
        index++;
        
        NSAssert((index >= 1 || index <= 1), @"Monster index out of bounds");
        
        // Load spritesheet
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
         [NSString stringWithFormat:@"gameMonster%d.plist", index]];
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"gameMonster%d.png", index]];
        [self addChild:spriteSheet];
        
        // Anims
        NSMutableArray *animFrames = [NSMutableArray array];
        for(int i = 1; i <= 6; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"HeartBear_Attack1_0%d.png", i]]];
        }
        
        attack1Anim = [CCAnimation animationWithSpriteFrames:animFrames];
        [attack1Anim setDelayPerUnit:ANIMATION_DELAY];
        
        [animFrames removeAllObjects];
        for(int i = 1; i <= 5; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"HeartBear_Attack2_0%d.png", i]]];
        }
        
        attack2Anim = [CCAnimation animationWithSpriteFrames:animFrames];
        [attack2Anim setDelayPerUnit:ANIMATION_DELAY];
        
        [animFrames removeAllObjects];
        for(int i = 1; i <= 4; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"HeartBear_Attack3_0%d.png", i]]];
        }
        
        attack3Anim = [CCAnimation animationWithSpriteFrames:animFrames];
        [attack3Anim setDelayPerUnit:ANIMATION_DELAY];
        
        [animFrames removeAllObjects];
        for(int i = 1; i <= 2; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"HeartBear_Idle0%d.png", i]]];
        }
        
        idleAnim = [CCAnimation animationWithSpriteFrames:animFrames];
        [idleAnim setDelayPerUnit:ANIMATION_DELAY];
        
        // Init
        sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"HeartBear_Idle01.png"]];
        [spriteSheet addChild:sprite];
        
        [sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:idleAnim]]];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    currentHP = 100.0;
    maxHP = 100.0;
}

@end
