//
//  NetworkTesterRootViewController.h
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import <UIKit/UIKit.h>

@interface NetworkTesterRootViewController : UIViewController

- (IBAction)match:(id)sender;

- (IBAction)begin:(id)sender;

@property (strong) IBOutlet UIButton *button1;
@property (strong) IBOutlet UIButton *button2;
@property (strong) IBOutlet UIButton *button3;
@property (strong) IBOutlet UIButton *button4;

@property (strong) IBOutlet UIButton *beginButton;

@property (strong) IBOutlet UIActivityIndicatorView *activityThing;


@end
