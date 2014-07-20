
//
//  IMIAppDelegate.m
//  YO MAP
//
//  Created by imicreation on 18/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIAppDelegate.h"
#import "IMIContactModelManager.h"
#import "IMISettingsManager.h"
#import "LoadingView.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "IMISplashViewController.h"
#import "IMIHelpViewController.h"

NSString * ApplicationDidFinishContactsInitialisation = @"ApplicationDidFinishContactsInitialisation";

@interface IMIAppDelegate ()

- (void) checkReachability;
- (void) checkHostReachability;
@end

@implementation IMIAppDelegate
@synthesize sharedContactModelManager;
@synthesize sharedSettingmanager;
@synthesize numberOfCallbacks;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:self];
    [self createEditableCopyOfDatabaseIfNeeded];
    // Override point for customization after application launch.
    // Handle launching from a notification
	UILocalNotification *localNotif =
	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
		//NSLog(@"Recieved Notification %@",localNotif);
	}
    
    [self checkReachability];
    
    sharedContactModelManager = [[IMIContactModelManager alloc] init];
    sharedSettingmanager = [[IMISettingsManager alloc] init];
    
    [self.sharedContactModelManager initManagerOnCompletion:^(BOOL iFlag){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationDidFinishContactsInitialisation object:self];
        });
        //to update the view in main thread
    }];
    
    sleep(4);
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstTime"] == NULL) {
        [[NSUserDefaults standardUserDefaults] setValue:@"Not" forKey:@"firstTime"];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber=[UIApplication sharedApplication].applicationIconBadgeNumber-1;
       
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        IMIHelpViewController* cont = (IMIHelpViewController*)[storyboard instantiateViewControllerWithIdentifier:@"IMISplashViewController"];
        
        self.window.rootViewController = cont;
        [self.window makeKeyAndVisible];
    }
    else    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            // Load resources for iOS 6.1 or earlier
        } else {
            // Load resources for iOS 7 or later
            UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
            tabController.tabBar.tintColor = [UIColor colorWithRed:0.7843 green:0.5490 blue:0.2510 alpha:1.0];
            tabController = NULL;
        }
    }
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
	// Handle the notificaton when the app is running
	//NSLog(@"Recieved Notification %@",notif);
    //DECREASE number of bedge by one
    //cancel the notification and show the alert view.
    [UIApplication sharedApplication].applicationIconBadgeNumber=[UIApplication sharedApplication].applicationIconBadgeNumber-1;

    if([self getMeetingNotifictionValue])   {
        [self showAlertWithTitle:@"Alert !" withMessage:notif.alertBody cancelBtnTitle:@"OK"];
    }
}

-(BOOL)getMeetingNotifictionValue   {
    return [sharedSettingmanager getMeetingAlertValue];;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"Recieved Notification");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Recieved Notification");

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    numberOfCallbacks = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Recieved Notification");
    numberOfCallbacks = 1;
    
    [self.sharedContactModelManager checkForContactSettings];
    
    if(!([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)){
        
        [self showAlertWithTitle:@"Location Service Disabled" withMessage:@"Please enable location service." cancelBtnTitle:@"OK"];
          }
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    	NSLog(@"Recieved Notification");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:kReachabilityChangedNotification
                                                object:nil];

}

- (void)createEditableCopyOfDatabaseIfNeeded
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        @autoreleasepool {
            BOOL success;
            __weak NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError __autoreleasing *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"App.sqlite"];
            success = [fileManager fileExistsAtPath:writableDBPath];
            //NSLog(@"%@",writableDBPath);
            if (success) return;
            // The writable database does not exist, so copy the default to the appropriate location.
            NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"App.sqlite"];
            //NSLog(@"%@",defaultDBPath);
            success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
            
            if (!success)
            {
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // SWITCH TO FOREGROUND
            });
        }
    });
    // First, test for existence.
}

//-(void)initializeDatabase {
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSLog(@"%@",documentsDirectory);
//	
//	NSString *path1 = [documentsDirectory stringByAppendingPathComponent:@"FaultFixes.sqlite"];
//	NSLog(@"%@",path1);
//	
//	if (sqlite3_open([path1 UTF8String], &database) == SQLITE_OK) {
//		NSLog(@"Ok");
//	} else {
//		sqlite3_close(database);
//		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
//	}
//}

#pragma Alert view system for the application
-(void)showAlertWithTitle:(NSString*)title withMessage:(NSString*)message cancelBtnTitle:(NSString*)cancelBtnTitle  {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title?title:@""
                                                        message:message?message:@""
                                                       delegate:self cancelButtonTitle:cancelBtnTitle?cancelBtnTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    alert.delegate = self;
    [alert show];
    
    alert = NULL;
}

-(void)showAlertWithTitle:(NSString*)title withMessage:(NSString*)message cancelBtnTitle:(NSString*)cancelBtnTitle otherBtnTitle:(NSString*)otherBtnTitle delegate:(id)delegate {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title?title:@""
                                                     message:message?message:@""
                                                    delegate:self cancelButtonTitle:cancelBtnTitle?cancelBtnTitle:@"OK"
                                           otherButtonTitles:otherBtnTitle?otherBtnTitle:nil, nil];
   
    alert.tag = 100;// contact notification
    alert.delegate = delegate;
    [alert show];
    
    alert = NULL;
}

-(void)dealloc  {
    hostReachability = NULL;
    wifiReachability = NULL;
}

- (void) checkReachability {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(reviewReachabilityStatusChange)
                                               name:kReachabilityChangedNotification
                                             object:nil];
    
    hostReachability = [Reachability reachabilityWithHostName: @"www.apple.com"];
    
    [hostReachability startNotifier];
    // force a Wifi check right away
}

/*
 * Wrapper method for reachability callbacks
 */
- (void) reviewReachabilityStatusChange {
    [self checkHostReachability];
}

- (void) checkHostReachability {
    NetworkStatus netStatus = [hostReachability currentReachabilityStatus];
    if (NotReachable == netStatus) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Alert"
														message: NSLocalizedString(@"3GPromptString", @"")
													   delegate: nil
											  cancelButtonTitle: @"OK"
											  otherButtonTitles: nil];
        [alert show];
    }
    else    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationDidFinishContactSyncing object:self];
    }
}

@end
