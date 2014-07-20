//
//  IMIAboutViewController.h
//  YO MAP
//
//  Created by imicreation on 22/11/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMIAboutViewController : UIViewController


@property(nonatomic, retain) IBOutlet UIToolbar* toolBar;
@property(nonatomic, retain) IBOutlet UIImageView* bgImgView;
@property(nonatomic, retain) IBOutlet UIButton* titleBtn;
-(IBAction) backBtnPressed:(id)sender;
-(IBAction)openWeb:(id)sender;
@end
