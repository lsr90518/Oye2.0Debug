//
//  TwitterPageViewController.m
//  FaceTracker
//
//  Created by Lsr on 13-8-26.
//
//

#import "TwitterPageViewController.h"
#import "HomepageViewController.h"
#import "RingTonePageViewController.h"
#import "AppDelegate.h"
#import "TwitterCheckViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Social/Social.h>
#import "JSONKit.h"
#import <sqlite3.h>

#define TABLENAME @"PERSONINFO";
#define NAME @"name";

@interface TwitterPageViewController ()
//@property (retain, nonatomic) UITextView *Text;
@property (retain, nonatomic) IBOutlet UITextView *Text;
@property (retain, nonatomic) IBOutlet UIImageView *upArrow;
@property (retain, nonatomic) IBOutlet UIImageView *switchPicture;

@end

@implementation TwitterPageViewController

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
    
    [self.Text setFrame:CGRectMake(20, 20, 280, self.view.frame.size.height*0.2)];
    
    
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.Text.text = delegate.twitterText;
    
    if([delegate.twitterSwitch isEqual:@"on"]){
        [self turnToOff];
    }
    
    [self.Text resignFirstResponder];
    
    //off 認識
    UISwipeGestureRecognizer* recognizerLeft;
    recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnToOff)];
    
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:recognizerLeft];
    
    //on 認識
    UISwipeGestureRecognizer* recognizerDown;
    recognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnToOn)];
    
    recognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:recognizerDown];
    
    [UIView setAnimationDuration:2.0];
    self.upArrow.alpha = 0.0;
    [UIView commitAnimations];
    [UIView setAnimationDuration:0.5];
    
    
    
//    CGRect rect = CGRectMake(10, 20, 200, 100);
//    self.Text = [[UITextView alloc]initWithFrame:rect];
    self.Text.alpha = 1.0;
//    [self.view addSubview:self.Text];
}

- (BOOL)userHasAccessToTwitter
{
//    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    //查数据库，没有表建立新表，有表查用户名，没有用户名跳转页面。
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"oye.sqlite"];
    
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
    } else {
    }
    
    NSString *sqlQuery = @"SELECT * FROM person WHERE id=1";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            char *name = (char*)sqlite3_column_text(statement, 1);
            NSString *nsNameStr = [[NSString alloc]initWithUTF8String:name];
            
            twitter_username = nsNameStr;
            sqlite3_close(db);
            sqlite3_finalize(statement);
        } else {
        }
    }
    sqlite3_close(db);
    
}

- (IBAction)keyboardCancel:(id)sender {
    [self.Text resignFirstResponder];
    
}

- (void)turnToOff{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self letterToggle:@"off"];
                         
                     }
                     completion:^(BOOL finished){
                         self.Text.alpha = 1.0;
                         self.Text.frame = CGRectMake(20, 20, 280, self.view.frame.size.height*0.2);
                     }];
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    delegate.twitterSwitch = @"off";
}

-(void) turnToOn{
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    if (![self userHasAccessToTwitter]) {
        
//        TWTweetComposeViewController *t = [[TWTweetComposeViewController alloc]init];
//        [t setInitialText:@"アカウントの設定をしてください。"];
//        [self presentViewController:t animated:YES completion:nil];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.Text.alpha = 0.0;
                             self.Text.frame = CGRectMake(20, 100, 280, self.view.frame.size.height*0.2);
                         }
                         completion:^(BOOL finished){
                             [self letterToggle:@"on"];
                         }];
        
        
        AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
        delegate.twitterSwitch = @"on";
        delegate.twitterText = self.Text.text;
        
        //测试服务器
        NSString *urlStr = [NSString stringWithFormat:@"http://ll.is.tokushima-u.ac.jp/OpenYourEyes/UseTwitter?screenname=%@",twitter_username];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        //第二步，通过URL创建网络请求
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
        
        //第三步，连接服务器
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        
        
        NSData* jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *result = [jsonData objectFromJSONData];
        NSString *message = [result valueForKey:@"message"];
        if([message  isEqual: @"yes"]){
            
            delegate.twitterSwitch = @"on";
            delegate.twitterText = self.Text.text;
            
        } else {
        //
        delegate.twitterText = self.Text.text;
            
        TwitterCheckViewController *twitterCheckViewController = [[TwitterCheckViewController alloc]init];
        twitterCheckViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:twitterCheckViewController animated:YES completion:nil];
        }
    } else {
    
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.Text.alpha = 0.0;
                             self.Text.frame = CGRectMake(20, 100, 280, self.view.frame.size.height*0.2);
                         }
                         completion:^(BOOL finished){
                             [self letterToggle:@"on"];
                         }];
        
        
        AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
        delegate.twitterSwitch = @"on";
        delegate.twitterText = self.Text.text;
    }
    
}

- (IBAction)backToHome:(id)sender {
    HomepageViewController *h = [[HomepageViewController alloc]init];
    h.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:h animated:YES completion:nil];
}

- (IBAction)backToRing:(id)sender {
    
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    [self letterToggle:delegate.twitterSwitch];
    
    RingTonePageViewController *r = [[RingTonePageViewController alloc]init];
    r.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:r animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)letterToggle:(NSString *)switchName{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
    switchName = [NSString stringWithFormat:@"%@.png",switchName];
    UIImage *uiimg = [UIImage imageNamed:switchName];
    [self.switchPicture setImage:uiimg];
//    [UIView commitAnimations];
}

- (void)dealloc {
    [_Text release];
    [_upArrow release];
    [_switchPicture release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setText:nil];
    [self setUpArrow:nil];
    [self setSwitchPicture:nil];
    [super viewDidUnload];
}
@end
