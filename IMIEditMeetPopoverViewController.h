//
//  IMIEditMeetPopoverViewController.h
//  YO MAP
//
//  Created by imicreation on 26/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMIContactModel.h"

@interface IMIEditMeetPopoverViewController : UIViewController  {
    
    NSDictionary* meet;
    
    IMIContactModel* contactModel;
}

@property(nonatomic, retain)  NSDictionary* meet;
@property(nonatomic, weak) IMIContactModel* contactModel;
@property(nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property(nonatomic, retain) IBOutlet UIButton* dateTimeBtn;
@property(nonatomic, retain) IBOutlet UILabel* dateTimeLbl;
@property(nonatomic, retain) IBOutlet UISwitch* alarmSwitch;
@property(nonatomic, retain) IBOutlet  UISwitch* notifySwitch;
@property(nonatomic, retain) IBOutlet UITextView* noteTextView;
@property(nonatomic, retain) IBOutlet UITextField* titleTxtFld;

@property(nonatomic, retain) UIDatePicker* datePicker;
@end
