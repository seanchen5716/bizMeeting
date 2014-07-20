//
//  DemoTableControllerViewController.h
//  FPPopoverDemo

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"
#import "IMIContactModel.h"

@class FPViewController;

@protocol DemoTableControllerDelegate;

@interface DemoTableController : UITableViewController  {
    id <DemoTableControllerDelegate> delegate;
    IMIContactModel* contactModel;
    UINavigationController *navController;
}
@property (nonatomic, retain) id <DemoTableControllerDelegate> delegate;
@property(nonatomic, weak) IMIContactModel* contactModel;

@property (nonatomic, retain) UINavigationController *navController;

@property(nonatomic,assign) FPViewController *sdelegate;
@end

@protocol DemoTableControllerDelegate

-(void) demoTableController:(DemoTableController *) controller;

@end

