//
//  SaveTwitterViewController.m
//  FaceTracker
//
//  Created by Lsr on 11/21/13.
//
//

#import "SaveTwitterViewController.h"
#import "TwitterPageViewController.h"
#import "HomepageViewController.h"

#define DBNAME    @"oye.sqlite"
#define NAME      @"name"
#define TABLENAME @"person"

@interface SaveTwitterViewController ()
@property (retain, nonatomic) IBOutlet UITextField *username;

@end

@implementation SaveTwitterViewController

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
    
    [self.username resignFirstResponder];
}
- (IBAction)inputOver:(id)sender {
    
    [self.username resignFirstResponder];
    twitter_username = self.username.text;
    //SaveToDatabase
    
    if([self createAndOpenDatabase]){
        NSLog(@"database OK");
    } else {
        NSLog(@"save error");
    }
    
    //
    
    HomepageViewController *homepage = [[HomepageViewController alloc]init];
    homepage.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:homepage animated:YES completion:nil];
    
}
- (IBAction)BackTwitter:(id)sender {
    
    TwitterPageViewController *tpv = [[TwitterPageViewController alloc]init];
    tpv.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:tpv animated:YES completion:nil];
}

-(BOOL) createAndOpenDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"oye.sqlite"];
    
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"fail to open");
        return NO;
    } else {
        //after open database select data
        NSString *sqlQuery = @"SELECT * FROM person WHERE id=1";
        sqlite3_stmt * statement;
        
        if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if(sqlite3_step(statement) == SQLITE_ROW) {
                //update database
                
                NSString *sql = [NSString stringWithFormat:@"UPDATE '%@' set '%@'='%@' WHERE id=1",TABLENAME,NAME,self.username.text];
                
                [self execSql:sql];
                
                return YES;
            } else {
                //insert database
                
                NSLog(@"insert into database");
                
                NSString *sql1 = [NSString stringWithFormat:
                                  @"INSERT INTO person(id, name) VALUES(1,'%@')",
                                   self.username.text];
                
                [self execSql:sql1];
                
                return YES;
            }
        } else {
            NSLog(@"select error");
            return NO;
        }
    }
}

-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"fail to operate!@%s",err);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_username release];
    [super dealloc];
}
@end
