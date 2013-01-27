//
//  GameMonsterHealthBar.m
//  rant
//

#import "GameMonsterHealthBar.h"


@implementation GameMonsterHealthBar
{
    CCSprite *barFill;
}

- (id)init
{
    if (self = [super init])
    {
        CCSprite *barBack = [CCSprite spriteWithFile:@"gameHPBarBack.png"];
        
        barFill = [CCSprite spriteWithFile:@"gameHPBarFill.png"];
        [barFill setPosition:ccp(0, 0)];
        
        [self addChild:barBack];
        [self addChild:barFill];
        
        [self setHealthBarPercentage:1.0 animated:NO];
    }
    
    return self;
}

- (void)setHealthBarPercentage:(float)percentage animated:(BOOL)animated
{
    static float width = 250.0;
    
    [barFill setScaleX:percentage];
    
    [barFill setPosition:ccp(-width*(1.0-percentage)/2, 0)];
    
    // TODO
    if (animated)
    {
        
    }
    else
    {
        
    }
}

@end
