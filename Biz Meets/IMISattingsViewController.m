//
//  IMISattingsViewController.m
//  YO MAP
//
//  Created by imicreation on 21/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMISattingsViewController.h"
#import "IMIAppDelegate.h"
#import "IMIAboutViewController.h"

@interface IMISattingsViewController ()
@property (nonatomic, weak) IMIAppDelegate* appdelegate;
-(void)setshadows:(UITableViewCell*)tableCell;
@end

@implementation IMISattingsViewController

@synthesize sattingsTableView;
@synthesize MapSwitch;
@synthesize gpsSwitch;
@synthesize meetingAlertSwitch;
@synthesize searchAreaTxtfld;
@synthesize mapCell;
@synthesize gpsCell;
@synthesize searchAreaCell;
@synthesize meetingAlertCell;
@synthesize appdelegate;

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
    appdelegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.sattingsTableView addGestureRecognizer:tap];
    
    BOOL results = [appdelegate.sharedSettingmanager getGPSValue];
    if(results)
        [gpsSwitch setOn:YES animated:NO];
    else if(!results)
        [gpsSwitch setOn:NO animated:NO];
    
    results = [appdelegate.sharedSettingmanager getMeetingAlertValue];
    if(results)
        [meetingAlertSwitch setOn:YES animated:NO];
    else if(!results)
        [meetingAlertSwitch setOn:NO animated:NO];
    
    results = [appdelegate.sharedSettingmanager getMapTypeValue];
    if(results)
        [MapSwitch setOn:YES animated:NO];
    else if(!results)
        [MapSwitch setOn:NO animated:NO];

    NSString* area = [appdelegate.sharedSettingmanager getSearchAreaValue];
    if(area)
        self.searchAreaTxtfld.text = area;
    else
        self.searchAreaTxtfld.text = @"50";
    
    UIImage *enableTextureImage = [UIImage imageNamed:@"bg.png"];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:enableTextureImage];
    sattingsTableView.backgroundColor = nil;
    [sattingsTableView setBackgroundView:imgView];
    enableTextureImage = NULL;
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        // Load resources for iOS 7.0
        MapSwitch.tintColor = [UIColor darkGrayColor];
        meetingAlertSwitch.tintColor = [UIColor darkGrayColor];
        gpsSwitch.tintColor = [UIColor darkGrayColor];
    }
    
    UIView *view = [[UIView alloc] init];
    sattingsTableView.tableFooterView = view;
}

-(void)setshadows:(UITableViewCell*)tableCell  {
    NSArray* subviews = [[tableCell contentView] subviews];
    for (id txtlbl in subviews) {
        if([txtlbl isKindOfClass:[UILabel class]])    {
            UILabel* lbl = (UILabel*)txtlbl;
            lbl.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            lbl.shadowOffset = CGSizeMake(1, 1);
            lbl = nil;
        }
    }
    subviews = NULL;
}

-(void) dealloc {
   
    appdelegate = NULL;
}

-(void)viewWillAppear:(BOOL)animated    {
    
}

-(IBAction)MapSwitchVAlueChange:(id)sender  {
    
    [self.searchAreaTxtfld resignFirstResponder];
    
    UISwitch* mapSwitch =(UISwitch*)sender;
    
    BOOL value = [mapSwitch isOn];
    [appdelegate.sharedSettingmanager setMapTypeValue:value];

}

-(IBAction)GPSSwitchValuechange:(id)sender  {
    
    [self.searchAreaTxtfld resignFirstResponder];
    
    UISwitch* GPSSwitch =(UISwitch*)sender;
    
    BOOL value = [GPSSwitch isOn];
    [appdelegate.sharedSettingmanager setGPSValue:value];
}

-(IBAction)MeetingAlertSwitchValuechange:(id)sender  {
    
    [self.searchAreaTxtfld resignFirstResponder];
    UISwitch* lmeetingAlertSwitch =(UISwitch*)sender;
    
    BOOL value = [lmeetingAlertSwitch isOn];

    [appdelegate.sharedSettingmanager setMeetingAlertValue:value];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if([textField.text isEqualToString:@""] || [textField.text integerValue] == 0)
        textField.text = @"50";
    
    [appdelegate.sharedSettingmanager setSearchAreaValue:textField.text];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section   {
    return 75;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section    {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    if(section == 0)    {
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(38, 15, 320, 30)];
        sectionTitle.text = @"App Settings";
        sectionTitle.font = [UIFont fontWithName:@"Helvetica" size:18];
        sectionTitle.textColor = [UIColor colorWithRed:0.1373 green:0.1412 blue:0.1451 alpha:1.0];
//        sectionTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.50];
//        sectionTitle.shadowOffset = CGSizeMake(1, 1);
        sectionTitle.backgroundColor = [UIColor clearColor];
        //headerView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *settingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 17, 25, 25)];
        UIImage *image = [UIImage imageNamed:@"settingIcon.png"];
        settingIcon.image = image;
        
        [headerView addSubview:sectionTitle];
        [headerView addSubview:settingIcon];
        
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            // Load resources for iOS 6.1 or earlier
            [sectionTitle setFrame: CGRectMake(38, 23, 320, 30)];
            [settingIcon setFrame: CGRectMake(5 , 25, 25, 25)];
        }
    }
    else if(section == 1)   {
        UIButton* helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [helpBtn setFrame:CGRectMake(10, 20, 57, 30)];
        [helpBtn setBackgroundColor:[UIColor clearColor]];
        [helpBtn setImage:[UIImage imageNamed:@"about.png"] forState:UIControlStateNormal];
        [helpBtn addTarget:self action:@selector(HelpBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:helpBtn];
    }
    return headerView;
}

-(void) HelpBtnPressed:(id)sender    {
    
    [self performSegueWithIdentifier:@"AboutSague" sender:sender];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(section == 0)
       return 4;
    
    else
        return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)    {
        searchAreaCell.backgroundColor = [UIColor clearColor];;
        return searchAreaCell;
    }
    if(indexPath.section == 0 && indexPath.row == 1)    {
        gpsCell.backgroundColor = [UIColor clearColor];
        return gpsCell;
    }
    if(indexPath.section == 0 && indexPath.row == 2)    {
        meetingAlertCell.backgroundColor = [UIColor clearColor];;
        return meetingAlertCell;
    }
    if(indexPath.section == 0 && indexPath.row == 3)    {
        mapCell.backgroundColor = [UIColor clearColor];
        return mapCell;
    }
    return nil;
}

#pragma mark TableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Change the height if Edit Unknown Contact is the row selected
	return 55;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string    {

    float distance = [[textField.text stringByAppendingString:string] floatValue];
    
    if(distance >10000)   {
        [appdelegate showAlertWithTitle:@"Value Exceed!" withMessage:@"Range shound be under 10000 Km" cancelBtnTitle:@"OK"];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    
    [self.searchAreaTxtfld resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
