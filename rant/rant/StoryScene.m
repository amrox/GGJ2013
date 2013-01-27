//
//  StoryScene.m
//  rant
//

#import "StoryScene.h"

#import "MainMenuScene.h"

@implementation StoryLayer : CCLayer

- (void)onEnter
{
    
}

@end

@implementation StoryScene
{
    int index;
}

- (id)initWithIndex:(int)_index
{
    if (self = [super init])
    {
        index = _index;
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Story0%d.png", index]];
    [background setPosition:ccp(160, 240)];
    
    [self addChild:background];
    
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:3.0];
}

-(void) makeTransition:(ccTime)dt
{
    index++;
    
    if (index > 6)
    {
         [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccBLACK]];
    }
    else
    {
        StoryScene *scene = [[StoryScene alloc] initWithIndex:index];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK]];
    }
}

@end
