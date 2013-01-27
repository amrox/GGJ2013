//
//  GameMonsterHealthBar.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameMonsterHealthBar : CCNode
{
    
}

- (id)initWithGreenBar:(BOOL)green;
- (void)setHealthBarPercentage:(float)percentage animated:(BOOL)animated;

@end
