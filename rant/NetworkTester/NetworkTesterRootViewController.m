//
//  NetworkTesterRootViewController.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "NetworkTesterRootViewController.h"
#import "GameEngine.h"

@interface NetworkTesterRootViewController ()

@end

@implementation NetworkTesterRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)go:(id)sender
{
    GameEngine *engine = [GameEngine sharedGameEngine];
    
    
    [engine findProgrammaticMatch:sender];
    
    
}

@end
