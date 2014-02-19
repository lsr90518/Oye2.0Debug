//
//  SharePageViewController.m
//  FaceAlarmP
//
//  Created by Lsr on 13-8-20.
//  Copyright (c) 2013年 Lsr. All rights reserved.
//

#import "SharePageViewController.h"
#import "HomepageViewController.h"
#import "AppDelegate.h"
#import <Twitter/TWTweetComposeViewController.h>
#import <Twitter/Twitter.h>

#import "AppDelegate.h"

@interface SharePageViewController ()

@property (retain,nonatomic)AppDelegate *delegate;

@end

@implementation SharePageViewController

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
    
    
    self.delegate = [[UIApplication sharedApplication]delegate];
    
    if([self.delegate.twitterSwitch isEqualToString:@"on"]){
        //测试服务器
        NSString *urlStr = [NSString stringWithFormat:@"http://ll.is.tokushima-u.ac.jp/OpenYourEyes/changeClock?screenname=%@",self.delegate.twitter_name];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        //第二步，通过URL创建网络请求
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
        
        //第三步，连接服务器
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
}
- (IBAction)openTwitter:(id)sender {
    
    TWTweetComposeViewController *twt = [[TWTweetComposeViewController alloc]init];
    
    
    NSString *initailText = [NSString stringWithFormat:@"おきたよ！#OyE"];
    
    [twt setInitialText:initailText];
    [self presentViewController:twt animated:YES completion:nil];
    
    
}
- (IBAction)BackToHomepage:(id)sender {
    
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    
    [delegate.check_timer invalidate];
    
    HomepageViewController *homepageViewController = [[HomepageViewController alloc]init];
    
    homepageViewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
//
//    [self presentModalViewController:homepageViewController animated:YES];
//    
    
    [delegate.window setRootViewController:homepageViewController];
    [delegate.window makeKeyAndVisible];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
