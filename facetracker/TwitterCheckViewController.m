//
//  TwitterCheckViewController.m
//  FaceTracker
//
//  Created by Lsr on 11/19/13.
//
//

#import "TwitterCheckViewController.h"
#import "SaveTwitterViewController.h"
#import "TwitterPageViewController.h"

@interface TwitterCheckViewController ()
@property (retain, nonatomic) IBOutlet UITextField *twitter_username;
@property (strong, nonatomic) NSString *username;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TwitterCheckViewController

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
    
    NSURL *url = [NSURL URLWithString:@"http://ll.is.tokushima-u.ac.jp/OpenYourEyes/AuthTwitterClock"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)inputOver:(id)sender {
    [self.twitter_username resignFirstResponder];
}
- (IBAction)AuthTwitter:(id)sender {
    self.username = self.twitter_username.text;
    
    
    
}



- (IBAction)SaveTwitter:(id)sender {
    
    SaveTwitterViewController *stv = [[SaveTwitterViewController alloc]init];
    stv.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:stv animated:YES completion:nil];
    
}
- (IBAction)BackToTwitter:(id)sender {
    
    TwitterPageViewController *tpv = [[TwitterPageViewController alloc]init];
    tpv.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tpv animated:YES completion:nil];
}

- (void)dealloc {
    [_twitter_username release];
    [_webView release];
    [super dealloc];
}
@end
