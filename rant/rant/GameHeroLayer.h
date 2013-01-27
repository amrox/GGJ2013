//
//  GameHeroLayer.h
//  rant
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameHeroNode;

@interface GameHeroLayer : CCLayer {
    
}

@property (nonatomic, strong) GameHeroNode *hero;

@end
