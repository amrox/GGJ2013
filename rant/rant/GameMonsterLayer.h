//
//  GameMonsterLayer.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameMonsterNode;

@interface GameMonsterLayer : CCLayer {
    
}

@property (nonatomic, strong) GameMonsterNode *monster;

@end
