//
//  IMIAppDelegate.h
//  YO MAP
//
//  Created by imicreation on 18/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMIContactModelManager.h"
#import "IMISettingsManager.h"

extern NSString * ApplicationDidFinishContactsInitialisation;

@class Reachability;

@interface IMIAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    IMIContactModelManager* sharedContactModelManager;
    IMISettingsManager* sharedSettingmanager;
    int numberOfCallbacks; // this variable always ensures that only one time contact data model refreshafter changes in database.
    
@private
    Reachability* hostReachability;
    Reachability* wifiReachability;
}
@property (nonatomic, assign)  int numberOfCallbacks;
@property (strong, nonatomic) IMISettingsManager* sharedSettingmanager;
@property (strong, nonatomic) IMIContactModelManager* sharedContactModelManager;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UIImageView *splashView;

-(void)createEditableCopyOfDatabaseIfNeeded;

-(void)showAlertWithTitle:(NSString*)title withMessage:(NSString*)message cancelBtnTitle:(NSString*)cancelBtnTitle;
-(void)showAlertWithTitle:(NSString*)title withMessage:(NSString*)message cancelBtnTitle:(NSString*)cancelBtnTitle otherBtnTitle:(NSString*)otherBtnTitle delegate:(id)delegate;

- (void) checkReachability;
- (void) reviewReachabilityStatusChange;
@end




