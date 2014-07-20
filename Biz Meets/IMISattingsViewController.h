//
//  IMISattingsViewController.h
//  YO MAP
//
//  Created by imicreation on 21/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMISattingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
}

@property(nonatomic, weak) IBOutlet UITableViewCell* mapCell;
@property(nonatomic, weak) IBOutlet UITableViewCell* gpsCell;
@property(nonatomic, weak) IBOutlet UITableViewCell* searchAreaCell;
@property(nonatomic, weak) IBOutlet UITableViewCell* meetingAlertCell;
@property(nonatomic, weak) IBOutlet UISwitch* MapSwitch;
@property(nonatomic, weak) IBOutlet UISwitch* gpsSwitch;
@property(nonatomic, weak) IBOutlet UISwitch* meetingAlertSwitch;
@property(nonatomic, weak) IBOutlet UITableView* sattingsTableView;
@property(nonatomic, weak) IBOutlet UITextField* searchAreaTxtfld;

-(IBAction)GPSSwitchValuechange:(id)sender;
@end
