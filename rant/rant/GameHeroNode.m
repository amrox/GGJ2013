//
//  GameHeroNode.m
//  rant
//

#import "GameHeroNode.h"

#define ANIMATION_DELAY 0.25

@implementation GameHeroNode
{
    CCSprite *sprite;
    CCAnimation *idleAAnim;
    CCAnimation *idleBAnim;
    CCAnimation *attackAnim;
    CCAnimation *hitAnim;
}

@synthesize currentHP;
@synthesize currentMP;
@synthesize maxHP;
@synthesize maxMP;

- (id)initWithIndex:(int)index
{
    if (self = [super init])
    {
        index++;
        
        NSAssert((index >= 1 || index <= 4), @"Hero index out of bounds");
        
        // Load spritesheet
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
         [NSString stringWithFormat:@"gameHero%d.plist", index]];
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"gameHero%d.png", index]];
        [self addChild:spriteSheet];
        
        // Anims
        NSMutableArray *animFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"user0%d_attack%d.png", index, i]]];
        }
        
        attackAnim = [CCAnimation animationWithSpriteFrames:animFrames];
        [attackAnim setDelayPerUnit:ANIMATION_DELAY];
        
        [animFrames removeAllObjects];
        for(int i = 1; i <= 3; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"user0%d_hit%d.png", index, i]]];
        }
        
        hitAnim = [CCAnimation animationWithSpriteFrames:animFrames];
        [hitAnim setDelayPerUnit:ANIMATION_DELAY];
        
        [animFrames removeAllObjects];
        for(int i = 1; i <= 2; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"user0%d_idle%dA.png", index, i]]];
        }
        
        idleAAnim = [CCAnimation animationWithSpriteFrames:animFrames];
        [idleAAnim setDelayPerUnit:ANIMATION_DELAY];
        
        [animFrames removeAllObjects];
        for(int i = 1; i <= 2; ++i) {
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"user0%d_idle%dB.png", index, i]]];
        }
        
        idleBAnim = [CCAnimation animationWithSpriteFrames:animFrames];
        [idleBAnim setDelayPerUnit:ANIMATION_DELAY];
        
        // Init
        sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"user0%d_idle1A.png", index]];
        [spriteSheet addChild:sprite];
        
        [sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:idleAAnim]]];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    currentHP = 100.0;
    currentMP = 100.0;
    maxHP = 100.0;
    maxMP = 100.0;
}

@end