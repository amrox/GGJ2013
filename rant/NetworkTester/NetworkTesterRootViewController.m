//
//  NetworkTesterRootViewController.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "NetworkTesterRootViewController.h"
#import "NetworkEngine.h"
#import "GameEngine.h"

@interface NetworkTesterRootViewController ()

@property (strong) NSTimer *timer;

@property (strong) GameEngine *gameEngine;
@end

@implementation NetworkTesterRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.gameEngine = [[GameEngine alloc] init];
        self.gameEngine.delegate = self;
        self.gameEngine.networkEngine = [NetworkEngine sharedNetworkEngine];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(refresh) userInfo:nil repeats:YES];
        [self refresh];
        
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

- (void)dealloc
{
    [self.timer invalidate];
}

- (void) refresh
{
    NetworkEngine *engine = [NetworkEngine sharedNetworkEngine];
    
    int const totalPlayers = [engine isMatchReady] ? [engine.match.playerIDs count] + 1 : 0;
    
    self.button4.hidden = totalPlayers < 4;
    self.button3.hidden = totalPlayers < 3;

    self.button2.hidden = totalPlayers < 2;
    self.button1.hidden = totalPlayers < 2;
    
    self.beginButton.hidden = totalPlayers < 2;
    
    self.attackButton.hidden = ![engine isGameStarted];
}

- (IBAction)match:(id)sender
{
    NetworkEngine *engine = [NetworkEngine sharedNetworkEngine];
    [engine findMatch];
    
    [self.activityThing startAnimating];
}

- (IBAction)begin:(id)sender
{
    NetworkEngine *engine = [NetworkEngine sharedNetworkEngine];
    [engine begin];
    
    [self.activityThing stopAnimating];

}

- (IBAction)attack:(id)sender
{
    GameEvent event;
    event.type = GameEventTypeAttack;
    event.value = 55;
    [self.gameEngine sendEventAsClient:&event];
}


- (void)clientReceivedEvent:(GameEvent *)event withState:(GameState *)state
{
    NSLog(@"received event!");
    NSLog(@"  source : %d", event->source);
    NSLog(@"  type   : %d", event->type);
    NSLog(@"  value  : %d", event->value);

}



@end
