//
//  GameMonsterNode.h
//  rant
//
//  Created by Tedo Salim on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameMonsterNode : CCNode {
    
}

@property (nonatomic) float currentHP;
@property (nonatomic) float maxHP;

- (id)initWithIndex:(int)index;

- (void)loopIdle;
- (void)loopAttack3Anim;
- (void)playHitAnim;
- (void)playAttack1Anim;
- (void)playAttack2Anim;
- (void)playAttack3Anim;

@end
