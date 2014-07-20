//
//  IMIEditMeetPopoverViewController.m
//  YO MAP
//
//  Created by imicreation on 26/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIEditMeetPopoverViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "IMILocalNotifiactionController.h"
#import "IMIAppDelegate.h"

@interface IMIEditMeetPopoverViewController ()

@property (nonatomic, weak) IMIAppDelegate* appdelegate;
@end

@implementation IMIEditMeetPopoverViewController
@synthesize meet;
@synthesize datePicker;
@synthesize dateTimeBtn;
@synthesize dateTimeLbl;
@synthesize alarmSwitch;
@synthesize notifySwitch;
@synthesize noteTextView;
@synthesize titleTxtFld;
@synthesize scrollView;
@synthesize appdelegate;
@synthesize contactModel = _contactModel;

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
    
    self.title = @"Meet";
    
    self.navigationItem.rightBarButtonItem = [self createBarBtnItom:[UIImage imageNamed:@"saveBarBtnIcon.png"] selector:@selector(SaveBtnPressed:)];
    self.navigationItem.leftBarButtonItem = [self createBarBtnItom:[UIImage imageNamed:@"meetBarBtnIcon.png"]selector:@selector(backBtnPressed:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.scrollView addGestureRecognizer:tap];
  
    dateTimeBtn.tag =0;
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-10, 293, 200, 200)];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [datePicker setMinimumDate:[NSDate date]];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[noteTextView layer] setCornerRadius:3.0f];
    [[noteTextView layer] setMasksToBounds:YES];
    
    noteTextView.layer.borderWidth = 1;
    noteTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        // Load resources for iOS 7.0
        alarmSwitch.tintColor = [UIColor darkGrayColor];
        notifySwitch.tintColor = [UIColor darkGrayColor];
    }
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor blackColor];
    titleView.shadowOffset = CGSizeMake(0.0f, -1.0f);
    titleView.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.00]; // Your color here
    titleView.text = @"Meet";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
}

-(UIBarButtonItem*)createBarBtnItom:(UIImage*) keyboardAddImage selector:(SEL)selector {
 
    UIButton *toggleKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleKeyboardButton.bounds = CGRectMake( 0, 0, keyboardAddImage.size.width, keyboardAddImage.size.height );
    [toggleKeyboardButton setImage:keyboardAddImage forState:UIControlStateNormal];
    [toggleKeyboardButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toggleKeyboardItem = [[UIBarButtonItem alloc] initWithCustomView:toggleKeyboardButton];
  
    return toggleKeyboardItem;
}

-(void) dealloc {
    appdelegate = NULL;
    _contactModel = NULL;
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    
    [self.titleTxtFld resignFirstResponder];
    [self.noteTextView resignFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated    {
    
    if(meet)    {
        titleTxtFld.text = [NSString stringWithFormat:@"%@", [meet objectForKey:@"Title"]];
        dateTimeLbl.text = [NSString stringWithFormat:@"%@", [meet objectForKey:@"Date"]];
        
        NSString* localString = [NSString stringWithFormat:@"%@", [meet objectForKey:@"Note"]];
        
        if(!localString || [localString isEqualToString:@""])
            noteTextView.text = @"note";
        else
            noteTextView.text = localString;
        
        localString = [NSString stringWithFormat:@"%@", [meet objectForKey:@"Alarm"]];
        [alarmSwitch setOn:[localString isEqualToString:@"YES"]?YES:NO animated:YES];
        
        localString = [NSString stringWithFormat:@"%@", [meet objectForKey:@"Notify"]];
        [notifySwitch setOn:[localString isEqualToString:@"YES"]?YES:NO animated:YES];        
    }
}

-(void)dateChanged
{
	//scroll.scrollEnabled=FALSE; // iadded
	
	NSDate* today = [NSDate date];
    NSDate* objdate=datePicker.date;
	NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init] ;
	NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init] ;
	[formatter1 setDateFormat:@"YYYYMMdd"];
	[formatter2 setDateFormat:@"HH:mm"];
    if ([objdate compare:today] == NSOrderedDescending || [objdate compare:today] == NSOrderedSame) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        dateTimeLbl.text= [NSString stringWithFormat:@"%@ %@ ", [formatter stringFromDate:objdate], [formatter2 stringFromDate:objdate]];
	}
	else {
        [datePicker setDate:[NSDate date] animated:YES];
        [appdelegate showAlertWithTitle:@"Invalid date selection" withMessage:@"Please enter future time." cancelBtnTitle:@"OK"];
	}
}

- (void)setViewMovedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    // Make changes to the view's frame inside the animation block. They will be animated instead
    // of taking place immediately.
    CGRect rect = self.datePicker.frame;
    
    // If moving up, not only decrease the origin but increase the height so the view
    // covers the entire screen behind the keyboard.
    rect.origin.y -= 260.0f;
    //rect.size.height -= 100.0f;
    self.datePicker.frame = rect;
    
    [UIView commitAnimations];
}

-(void)moveDown
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    // Make changes to the view's frame inside the animation block. They will be animated instead
    // of taking place immediately.
    
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{

        CGRect rect = self.datePicker.frame;
        rect.origin.y += 260.0f;
        //rect.size.height += 100.0f;
        self.datePicker.frame = rect;
    }completion:^(BOOL complition){
        [self.datePicker removeFromSuperview];
    }];
}

-(IBAction)backBtnPressed:(id)sender    {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)SaveBtnPressed:(id)sender    {
    
    [self.titleTxtFld resignFirstResponder];
    [self.noteTextView resignFirstResponder];
    
    if([titleTxtFld.text length] == 0)      {
        [appdelegate showAlertWithTitle:@"Alert!" withMessage:@"Please Enert Title." cancelBtnTitle:@"OK"];
        [self.titleTxtFld becomeFirstResponder];
        return;
    }
    if([appdelegate.sharedContactModelManager havingMeetWithFutureDate:[NSString stringWithFormat:@"%@",dateTimeLbl.text]]) {
        [appdelegate showAlertWithTitle:@"Alert!" withMessage:@"Already have meeting at this time." cancelBtnTitle:@"OK"];
        return;
    }
    
    NSMutableDictionary* meetInfo= [[NSMutableDictionary alloc] init];
    
    [meetInfo setValue:[meet objectForKey:@"MeetId"] forKey:@"MeetId"];
    [meetInfo setValue:titleTxtFld.text forKey:@"Title"];
    [meetInfo setValue:dateTimeLbl.text forKey:@"Date"];
    [meetInfo setValue:[alarmSwitch isOn]?@"YES":@"NO" forKey:@"Alarm"];
    [meetInfo setValue:[notifySwitch isOn]?@"YES":@"NO" forKey:@"Notify"];
    [meetInfo setValue:[noteTextView.text isEqualToString:@"note"]?@"":noteTextView.text forKey:@"Note"];
    [meetInfo setValue:[NSString stringWithFormat:@"%d",[_contactModel getRecordId]] forKey:@"PersonId"];
    
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    // [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSDate* date = [dateTimeFormatter dateFromString:dateTimeLbl.text];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject: [meet objectForKey:@"MeetId"] forKey:@"MeetId"];
    
    
    NSString* notifyName = NULL;
    NSString* contactNameStr = [appdelegate.sharedContactModelManager getFullName:_contactModel.personRef];
    
    [userInfo setObject:contactNameStr?contactNameStr:@"" forKey:@"ContactName"];
    
    notifyName =[NSString stringWithFormat:@"Meeting With %@ Date %@",contactNameStr?contactNameStr:@"" ,dateTimeLbl.text ];
    
    BOOL status =  [appdelegate.sharedContactModelManager updateRecordWithMeetInfo:meetInfo];

    if(status)  {
        
        [IMILocalNotifiactionController cancelNotification:[NSString stringWithFormat:@"%@", [meet objectForKey:@"MeetId"]]];
        
        if([notifySwitch isOn])
            [IMILocalNotifiactionController createLocalNotifactionName:notifyName date:date userInfo:userInfo isAlarm:[alarmSwitch isOn]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self showAlertWithTitle:@"Error!" withMessage:@"Meet does not saved. Contact to system administrator."];
    
  //  [self vibrate];
}

- (void)vibrate {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}


-(void)showAlertWithTitle:(NSString*)title withMessage:(NSString*)message   {
    
    UIAlertView * chkAlert = [[UIAlertView alloc] initWithTitle:title?title:@""
                                                        message:message?message:@""
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    [chkAlert show];
}

-(IBAction)switchValueChange:(id)sender {
    
    if(self.noteTextView.isFirstResponder)
        [self.noteTextView resignFirstResponder];
    if(self.titleTxtFld.isFirstResponder)
        [self.titleTxtFld resignFirstResponder];
}

-(IBAction)dateBtnPressed:(id)sender    {
    
    if(dateTimeBtn.tag == 0)    {
        if([titleTxtFld isFirstResponder])  {
            [titleTxtFld resignFirstResponder];
        }
        [datePicker setMinimumDate:[NSDate date]];
        dateTimeBtn.tag = 1;
        [self.view addSubview:datePicker];
        [self setViewMovedUp];
    }
    else if(dateTimeBtn.tag == 1)    {
        dateTimeBtn.tag = 0;
        
        [self moveDown];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField    {
    
    if(dateTimeBtn.tag == 1)    {
        
        dateTimeBtn.tag = 0;
        [self moveDown];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView   {
    
    if([textView.text isEqualToString:@"note"])
        textView.text = @"";
    
    if(dateTimeBtn.tag == 1)    {
        
        dateTimeBtn.tag = 0;
        [self moveDown];
    }
    
    CGPoint pt;
    CGRect rc = [noteTextView bounds];
    rc = [noteTextView convertRect:rc toView:scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 50;
    
    [scrollView setContentOffset:pt animated:YES];
}

-(void) textViewDidEndEditing:(UITextView *)textView    {
    
    self.noteTextView.text = [self.noteTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([self.noteTextView.text length] == 0)    {
        self.noteTextView.text = @"note";
    }

    CGPoint pt;
    CGRect rc = [noteTextView bounds];
    rc = [noteTextView convertRect:rc toView:scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 120;
    
    [scrollView setContentOffset:pt animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
