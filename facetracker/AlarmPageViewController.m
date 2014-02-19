//
//  AlarmPageViewController.m
//  FaceAlarmP
//
//  Created by Lsr on 13-8-20.
//  Copyright (c) 2013年 Lsr. All rights reserved.
//

#import "AlarmPageViewController.h"
#import "FaceAlarmViewController.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Social/Social.h>


@interface AlarmPageViewController ()
@property (strong, nonatomic) IBOutlet UILabel *wake_timeS;
@property (strong, nonatomic) IBOutlet UILabel *current_time;
@property (retain, nonatomic) UIImageView *Switch;
@property (retain, nonatomic) NSString *rope_range;
@property (retain,nonatomic) NSString *tweet;
@property (retain,nonatomic) UIImage *image;
@property (retain,nonatomic)AppDelegate *delegate;


@end

@implementation AlarmPageViewController

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
    self.delegate = [[UIApplication sharedApplication]delegate];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"HH"];
    //get wake_time
    
    self.wake_timeS.text = self.delegate.wake_time_text;
    //get current time
    NSDate *current_timeT = [NSDate date];
    NSString* current_hour = [formatter stringFromDate:current_timeT];
    int int_current_hour = [current_hour intValue];
    
    [formatter setDateFormat:@"mm"];
    NSString *current_min = [formatter stringFromDate:current_timeT];
    int int_current_min = [current_min intValue];
    
    [formatter setDateFormat:@"ss"];
    NSString *current_sec = [formatter stringFromDate:current_timeT];
    int int_current_sec =[current_sec intValue];
    
    //set time transform
    int int_hour = [self.delegate.wake_hour intValue];
    int int_min = [self.delegate.wake_min intValue];
    
    int wake_seconds_hour = int_hour * 3600;
    int wake_seconds_min = int_min * 60;
    int wake_seconds = wake_seconds_hour + wake_seconds_min;
    
    //current time transform
    int current_seconds_hour = int_current_hour * 3600;
    int current_seconds_min = int_current_min * 60;
    int current_seconds = current_seconds_hour + current_seconds_min;
    current_seconds = current_seconds + int_current_sec;
    
    
    //interval calculate
    int interval = wake_seconds - current_seconds;
    NSLog(@"%d",interval);
    //明日
    if(interval < 0.0){
        interval = 86400.0 + interval;
    } 
    
    self.delegate.send_time = [NSString stringWithFormat:@"%d",interval];
    
    //start local notification
    
    NSString *song_nameT = [self.delegate.song_name stringByAppendingString:@".mp3"];
    
    self.delegate.notify = [[UILocalNotification alloc] init];
//    notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    self.delegate.notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    self.delegate.notify.soundName = song_nameT;
    self.delegate.notify.applicationIconBadgeNumber = 1;
    self.delegate.notify.alertBody = @"Open Your Eyes!";
    self.delegate.notify.alertAction =@"Open Your Eyes!";
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //一回マナーする
    [[UIApplication sharedApplication] scheduleLocalNotification:self.delegate.notify];
    
    
    
    
    //スイッチ設置する
    self.Switch = [[UIImageView alloc]initWithFrame:CGRectMake(280, -50, 12, 100.0)];
    UIImage *switchT = [UIImage imageNamed:@"switch.png"];
    [self.Switch setImage:switchT];
    [self.view addSubview:self.Switch];
    
    if(![self.delegate.twitterSwitch  isEqual: @"off"]){
        [self sendTime];
    }
    
}


- (void)sendTime{
    
    if(![twitter_username isEqual:@""]){
        NSString *body = [NSString stringWithFormat:@"time=%@&twitterClock=%@&confirm_time=%@&song_name=%@&twitterText=%@&screenname=%@",self.delegate.send_time,self.delegate.twitterSwitch,self.delegate.confirm_time,self.delegate.song_name,self.delegate.twitterText,self.delegate.twitter_name];
        
        //第一步，创建url
        NSURL *url = [NSURL URLWithString:@"http://ll.is.tokushima-u.ac.jp/OpenYourEyes/SetClock"];
        
        //第二步，创建请求
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];
        NSString *str = @"type=focus-c";
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        //第三步，连接服务器
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
    
}

//接收到服务器回应的时候调用此方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    self.receiveData = [NSMutableData data];
}
//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiveStr);
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

- (void)cancel {
    [[UIApplication sharedApplication] cancelLocalNotification:self.delegate.notify];
    self.delegate = [[UIApplication sharedApplication]delegate];
    self.delegate.twitterSwitch=@"off";
    
    //测试服务器
    NSString *urlStr = [NSString stringWithFormat:@"http://ll.is.tokushima-u.ac.jp/OpenYourEyes/changeClock?screenname=%@",self.delegate.twitter_name];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //第二步，通过URL创建网络请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
    
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
    HomepageViewController *homepageViewController = [[HomepageViewController alloc]init];
    
    homepageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:homepageViewController animated:YES completion:nil];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    
    //地域分別
    if(pt.x > 250 && pt.y<110 && [self.rope_range isEqual:@"1"]){
        self.rope_range = @"1";
        [self dragRope:pt.x :pt.y];
    } else {
        self.rope_range = @"0";
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    //    printf("point = %lf,%lf\n", pt.x, pt.y);
    
    if(pt.x > 250 && pt.y<110){
        self.rope_range = @"1";
        [self dragRope:pt.x :pt.y];
    } else {
        self.rope_range = @"0";
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self ropeAnimation];
    
}

-(void) alarmBegin{
    
    [self ropeAnimation];
    
    
    AlarmPageViewController *alarmPageViewController = [[AlarmPageViewController alloc] init];
    
    alarmPageViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:alarmPageViewController animated:YES];
}


-(void) dragRope:(float)ropex :(float)ropey {
    
    if(ropey < 70){
        
        [self.Switch removeFromSuperview];
        
        self.Switch = [[UIImageView alloc]initWithFrame:CGRectMake(280, ropey-70, 12, 100.0)];
        UIImage *switchT = [UIImage imageNamed:@"switch.png"];
        [self.Switch setImage:switchT];
        [self.view addSubview:self.Switch];
    } else if(ropey >= 70){
        [self cancel];
        
    }
}

-(void) ropeAnimation {
    //设置动画效果
    CGContextRef context = UIGraphicsGetCurrentContext();
    //开始播放动画
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    //imageView最终的宽度为desktop.size.width
    [self.Switch setFrame:CGRectMake(280, -50, 12.0, 100.0)];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
