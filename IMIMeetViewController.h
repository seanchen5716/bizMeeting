//
//  IMIMeetViewController.h
//  YO MAP
//
//  Created by imicreation on 23/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMIContactModel.h"

@interface IMIMeetViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>  {
    
    UIDatePicker* datePicker;
    IMIContactModel* contactModel;
}

@property(nonatomic, weak) IMIContactModel* contactModel;

@property(nonatomic, weak) IBOutlet UILabel* contactNameLbl;
@property(nonatomic, weak) IBOutlet UILabel* contactCompany;
@property(nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property(nonatomic, retain) UIDatePicker* datePicker;
@property(nonatomic, weak) IBOutlet UIButton* dateTimeBtn;
@property(nonatomic, weak) IBOutlet UILabel* dateTimeLbl;
@property(nonatomic, weak) IBOutlet UISwitch* alarmSwitch;
@property(nonatomic, weak) IBOutlet  UISwitch* notifySwitch;
@property(nonatomic, weak) IBOutlet UITextView* noteTextView;
@property(nonatomic, weak) IBOutlet UITextField* titleTxtFld;
@property(nonatomic, weak) IBOutlet UIButton* bedgeBtn;
@property(nonatomic, weak) IBOutlet UIImageView* contactphoto;

-(IBAction)dateBtnPressed:(id)sender;

@end
