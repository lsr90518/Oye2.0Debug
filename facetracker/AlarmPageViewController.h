//
//  AlarmPageViewController.h
//  FaceAlarmP
//
//  Created by Lsr on 13-8-20.
//  Copyright (c) 2013年 Lsr. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>

@interface AlarmPageViewController : UIViewController{
    
    sqlite3 *db;
    NSString *twitter_username;
    int sendTime;
    
}

@property (strong,nonatomic) NSMutableData *receiveData;

@end
