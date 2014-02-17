//
//  TwitterPageViewController.h
//  FaceTracker
//
//  Created by Lsr on 13-8-26.
//
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface TwitterPageViewController : UIViewController{
    sqlite3 *db;
    NSString *twitter_username;
}


@end
