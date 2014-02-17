//
//  AppDelegate.m
//  FaceTracker
//
//  Created by Robin Summerhill on 9/22/11.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "AppDelegate.h"
#import "HomepageViewController.h"
#import "FaceAlarmViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

#import "DemoVideoCaptureViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

#define DBNAME    @"oye.sqlite"
#define NAME      @"name"
#define TABLENAME @"PERSONINFO"

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    application.applicationIconBadgeNumber = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    homepageViewController = [[HomepageViewController alloc]init];
    homepageViewController.title = @"Open Your Eye";
    self.confirm_time=@"5";
    
    self.path = [[NSBundle mainBundle] pathForResource:@"music1" ofType:@"mp3"];
    
    self.alarm_status = @"0";
    
    self.song_name = @"music1";
    
    self.open = @"no";
    //
    
    //twitter text setting
    self.twitterText = @"I'm still sleeping, who can wake me up!! Thank you! #OyE";
    //twitter　スイッチ設定
    self.twitterSwitch = @"off";
    
    
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:self.path]error:nil];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    
    //Create a database
    if([self createAndOpenDatabase]){
        NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS person (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)";
        [self execSql:sqlCreateTable];
        NSLog(@"database created");
        
    }
    
    
    //[self.window addSubview:homepageViewController.view];
    [self.window setRootViewController:homepageViewController];
    //[self.window addSubview:homepageViewController.view];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.alarm_status = @"0";
    self.open = @"no";
    [self.thread cancel];
    [self.check_timer invalidate];
    NSLog(@"willResign");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if(![self.player isPlaying]){
        
    } else {
        
        DemoVideoCaptureViewController *demoViewCaptureViewController = [[DemoVideoCaptureViewController alloc]init];
        [self.window setRootViewController:demoViewCaptureViewController];
        [self.window makeKeyAndVisible];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DemoVideoCaptureViewController *demoVideoCaptureViewController = [[DemoVideoCaptureViewController alloc]init];
    //self.twitterSwitch = @"off";
    [self.window setRootViewController:demoVideoCaptureViewController];
    //[self.viewController presentViewController:demoVideoCaptureViewController animated:NO completion:nil];
    [self.window makeKeyAndVisible];
//    NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
//    [noti addObserver:self selector:@selector(dismiss) name:@"back" object:nil];
}

- (NSString *) getCurrentTime{
    NSDate *current_date = [NSDate date];
    
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    
    [f setDateFormat:@"HH : mm"];
    NSString *cTime = [f stringFromDate:current_date];
    
    NSString *initailText = [NSString stringWithFormat:@"%@",cTime];
    
    return initailText;
}

-(BOOL) createAndOpenDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"oye.sqlite"];
    NSLog(@"%@",database_path);
    
    if (sqlite3_open([database_path UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        return NO;
    } else {
        return YES;
    }
}

-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"fail to operate!");
    }
}

-(void) insertData{
    NSString *username = @"lsr";
    NSString *sql1 = [NSString stringWithFormat:
                      @"INSERT INTO '%@' ('%@') VALUES ('%@')",
                      TABLENAME, NAME,  username];
    
    [self execSql:sql1];
}

- (void)getData {
    
    NSString *sqlQuery = @"SELECT * FROM personinfo ";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *name = (char*)sqlite3_column_text(statement, 1);
            NSString *nsNameStr = [[NSString alloc]initWithUTF8String:name];
            
            NSLog(@"name:%@",nsNameStr);
        }
    }
    sqlite3_close(database);
}

@end
