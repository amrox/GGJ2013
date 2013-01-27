//
//  GameHeroNode.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameHeroNode : CCNode {
    
}

@property (nonatomic) float currentHP;
@property (nonatomic) float currentMP;
@property (nonatomic) float maxHP;
@property (nonatomic) float maxMP;

- (id)initWithIndex:(int)index;

- (void)playAttackAnim;

@end
