//
//  SaveTwitterViewController.h
//  FaceTracker
//
//  Created by Lsr on 11/21/13.
//
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface SaveTwitterViewController : UIViewController{
    sqlite3 *db;
    
    NSString *twitter_username;
}

@end
