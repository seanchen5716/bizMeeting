//
//  IMIDetailViewController.h
//  YO MAP
//
//  Created by imicreation on 20/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoTableController.h"
#import "IMIContactModel.h"
#import <MessageUI/MessageUI.h>
#import "IMIContactModelManager.h"

@interface IMIDetailViewController : UIViewController <DemoTableControllerDelegate, MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>   {
    __weak IMIContactModel* contactModel;
    UINavigationController *navController;
    BOOL isComeFromMap;
}

@property(nonatomic, assign) BOOL isComeFromMap;
@property(nonatomic, weak) IMIContactModel* contactModel;

@property (nonatomic, retain) UINavigationController *navController;

@property(nonatomic, weak) IBOutlet UILabel* contactName;
@property(nonatomic, weak) IBOutlet UILabel* contactCompany;
@property(nonatomic, weak) IBOutlet UILabel* contactMobile;
@property(nonatomic, weak) IBOutlet UILabel* contactEmail;

@property(nonatomic, weak) IBOutlet UITextView* addressTxtView;

@property(nonatomic, weak) IBOutlet UIImageView* bedgeBtnBkndView;
@property(nonatomic, weak) IBOutlet UIImageView* contactphoto;
@property(nonatomic, weak) IBOutlet UIButton* bedgeBtn;

-(IBAction)mailBtnPressed:(id)sender;
-(IBAction)messageBtnPressed:(id)sender;

@end
