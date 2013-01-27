//
//  NetworkTesterRootViewController.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <UIKit/UIKit.h>

#import "GameEngine.h"

@interface NetworkTesterRootViewController : UIViewController <GameEngineDelegate>

- (IBAction)match:(id)sender;

- (IBAction)begin:(id)sender;

@property (strong) IBOutlet UIButton *button1;
@property (strong) IBOutlet UIButton *button2;
@property (strong) IBOutlet UIButton *button3;
@property (strong) IBOutlet UIButton *button4;

@property (strong) IBOutlet UIButton *beginButton;

@property (strong) IBOutlet UIButton *attackButton;

@property (strong) IBOutlet UIActivityIndicatorView *activityThing;

- (IBAction)attack:(id)sender;

@end
