
//
//  IMIMeetViewController.m
//  YO MAP
//
//  Created by imicreation on 23/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIMeetViewController.h"
#import "DataBase.h"
#include <QuartzCore/QuartzCore.h>
#import "IMILocalNotifiactionController.h"
#import "IMIAppDelegate.h"
#import "IMIContactModel.h"

@interface IMIMeetViewController ()

@property (nonatomic, weak) IMIAppDelegate* appdelegate;
@end

@implementation IMIMeetViewController

@synthesize datePicker;
@synthesize dateTimeBtn;
@synthesize dateTimeLbl;
@synthesize alarmSwitch;
@synthesize notifySwitch;
@synthesize noteTextView;
@synthesize titleTxtFld;
@synthesize scrollView;
@synthesize contactNameLbl;
@synthesize contactCompany;
@synthesize bedgeBtn;
@synthesize appdelegate;
@synthesize contactModel = _contactModel;
@synthesize contactphoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    appdelegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [[bedgeBtn layer] setCornerRadius:12.0f];
    [[bedgeBtn layer] setMasksToBounds:NO];
    
    bedgeBtn.layer.borderWidth = 2;
    
    CGColorRef color = [[UIColor darkGrayColor] CGColor];
    CGColorRetain(color);
    bedgeBtn.layer.borderColor = color;
    CGColorRelease(color);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.scrollView addGestureRecognizer:tap];
    NSDate* date = [NSDate date];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    dateTimeLbl.text= [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    formatter = NULL;
    date = NULL;
    
    dateTimeBtn.tag =0;
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 367, 200, 200)];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    contactNameLbl.font = [UIFont fontWithName:@"Helvetica" size:20];
    //sectionTitle.textColor = [UIColor whiteColor];
    contactNameLbl.backgroundColor = [UIColor clearColor];
    
    [[noteTextView layer] setCornerRadius:10.0f];
    [[noteTextView layer] setMasksToBounds:YES];
    
    noteTextView.layer.borderWidth = 1;
    noteTextView.layer.borderColor = [UIColor colorWithRed:0.7882 green:0.7882 blue:0.7882 alpha:0.8].CGColor;
    
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
    titleView.textColor = [UIColor colorWithRed:0.9216 green:0.7020 blue:0.2353 alpha:1.00]; // Your color here
    titleView.text = @"Meet";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    self.navigationItem.rightBarButtonItem = [self createBarBtnItom:[UIImage imageNamed:@"save.png"] selector:@selector(SaveBtnPressed:)];
    self.navigationItem.leftBarButtonItem = [self createBarBtnItom:[UIImage imageNamed:@"Details.png"]selector:@selector(backBtnPressed:)];
}

-(UIBarButtonItem*)createBarBtnItom:(UIImage*) keyboardAddImage selector:(SEL)selector {
    
    UIButton *toggleKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleKeyboardButton.bounds = CGRectMake( 0, 0, keyboardAddImage.size.width, keyboardAddImage.size.height );
    [toggleKeyboardButton setImage:keyboardAddImage forState:UIControlStateNormal];
    [toggleKeyboardButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toggleKeyboardItem = [[UIBarButtonItem alloc] initWithCustomView:toggleKeyboardButton];
    
    return toggleKeyboardItem;
}

-(IBAction)backBtnPressed:(id)sender    {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dealloc {
    appdelegate = NULL;
    _contactModel = NULL;
    datePicker = NULL;
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    [self.titleTxtFld resignFirstResponder];
    [self.noteTextView resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated    {
    self.contactNameLbl.text  = [appdelegate.sharedContactModelManager getFullName:_contactModel.personRef];
    self.contactCompany.text = [appdelegate.sharedContactModelManager getOrgenizationName:_contactModel.personRef];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        UIImage* img = [self circularScaleNCrop:[appdelegate.sharedContactModelManager getContactImage:_contactModel.personRef] rect:CGRectMake(0, 0, 66, 66)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(img)
                [self.contactphoto setImage:img];
            else
                [self.contactphoto setImage:[UIImage imageNamed:@"Default Photo.png"]];
        });
    });
    int numberOfMeet = (int)[_contactModel.allMeets count];
    
    if(numberOfMeet >0) {
        [bedgeBtn setTitle:[NSString stringWithFormat:@"%i", numberOfMeet] forState:UIControlStateNormal];
        bedgeBtn.hidden = NO;
    }
    else    {
        bedgeBtn.titleLabel.text = @"";
        bedgeBtn.hidden = YES;
    }
    bedgeBtn.hidden = YES;
}

- (UIImage*)circularScaleNCrop:(UIImage*)Rawimage rect:(CGRect) rect {
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Get the width and heights
    CGFloat imageWidth = Rawimage.size.width;
    CGFloat imageHeight = Rawimage.size.height;
    CGFloat rectWidth = rect.size.width;
    CGFloat rectHeight = rect.size.height;
    
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [Rawimage drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)viewDidAppear:(BOOL)animated {
    if(!appdelegate && !_contactModel)
        [appdelegate showAlertWithTitle:@"Error!" withMessage:@"Contact does not exist." cancelBtnTitle:@"OK"];
}
-(void)dateChanged
{
	//scroll.scrollEnabled=FALSE; // iadded
    @autoreleasepool {
        NSDate* today = [NSDate date];
        NSDate* objdate=datePicker.date;
        NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init] ;
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init] ;
        [formatter1 setDateFormat:@"YYYYMMdd"];
        [formatter2 setDateFormat:@"HH:mm"];
        if ([objdate compare:today] == NSOrderedDescending || [objdate compare:today] == NSOrderedSame) {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            [dateTimeLbl setText:[NSString stringWithFormat:@"%@ %@ ", [formatter stringFromDate:objdate], [formatter2 stringFromDate:objdate]]];
        }
        else {
            [datePicker setDate:[NSDate date] animated:YES];
            [appdelegate showAlertWithTitle:@"Invalid date selection" withMessage:@"Please enter future time." cancelBtnTitle:@"OK"];
        }
        formatter1 = NULL;
        formatter2 = NULL;
        today = NULL;
        objdate = NULL;
    }
}

- (void)setViewMovedUp
{
    @autoreleasepool {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        // Make changes to the view's frame inside the animation block. They will be animated instead
        // of taking place immediately.
        CGRect rect = self.datePicker.frame;
        
        // If moving up, not only decrease the origin but increase the height so the view
        // covers the entire screen behind the keyboard.
        rect.origin.y -= 212.0f;
        //rect.size.height -= 100.0f;
        self.datePicker.frame = rect;
        
        [UIView commitAnimations];
    }
}

-(void)moveDown
{
    @autoreleasepool {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        // Make changes to the view's frame inside the animation block. They will be animated instead
        // of taking place immediately.
        [UIView commitAnimations];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect rect = self.datePicker.frame;
            
            rect.origin.y += 212.0f;
            //rect.size.height += 100.0f;
            self.datePicker.frame = rect;
            
        }completion:^(BOOL complition){
            
            [self.datePicker removeFromSuperview];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)SaveBtnPressed:(id)sender    {
    @autoreleasepool {
        [self.titleTxtFld resignFirstResponder];
        [self.noteTextView resignFirstResponder];
        
        if([titleTxtFld.text length] == 0)      {
            [appdelegate showAlertWithTitle:@"Alert!" withMessage:@"Please enter title." cancelBtnTitle:@"OK"];
            [self.titleTxtFld becomeFirstResponder];
            return;
        }
        if([appdelegate.sharedContactModelManager havingMeetWithFutureDate:[NSString stringWithFormat:@"%@",dateTimeLbl.text]]) {
            [appdelegate showAlertWithTitle:@"Alert!" withMessage:@"Already have meeting at this time." cancelBtnTitle:@"OK"];
            return;
        }
        
        NSMutableDictionary* meetInfo= [[NSMutableDictionary alloc] init];
        [meetInfo setValue:[NSString stringWithFormat:@"%d",[_contactModel getRecordId]] forKey:@"PersonId"];
        [meetInfo setValue:titleTxtFld.text forKey:@"Title"];
        [meetInfo setValue:dateTimeLbl.text forKey:@"Date"];
        [meetInfo setValue:[alarmSwitch isOn]?@"YES":@"NO" forKey:@"Alarm"];
        [meetInfo setValue:[notifySwitch isOn]?@"YES":@"NO" forKey:@"Notify"];
        [meetInfo setValue:[noteTextView.text isEqualToString:@"note"]?@"":noteTextView.text forKey:@"Note"];
        
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        // [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        NSDate* date = [dateTimeFormatter dateFromString:dateTimeLbl.text];
        
        long long int meetId = [[DataBase database] getlastmeetId];
        meetId++;
        
        NSString* notifyName = [NSString stringWithFormat:@"Meeting With %@ Date %@", contactNameLbl.text,dateTimeLbl.text ];
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject: [NSString stringWithFormat:@"%lld", meetId] forKey:@"MeetId"];
        [userInfo setObject:contactNameLbl.text forKey:@"ContactName"];
        
        BOOL status = [appdelegate.sharedContactModelManager saveMeet:meetInfo];
        if(status)  {
            if([notifySwitch isOn])
                [IMILocalNotifiactionController createLocalNotifactionName:notifyName date:date userInfo:userInfo isAlarm:[alarmSwitch isOn]];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [appdelegate showAlertWithTitle:@"Error!" withMessage:@"Meet does not saved. Contact to system administrator." cancelBtnTitle:@"OK"];
        dateTimeFormatter = NULL;
        date = NULL;
        notifyName = NULL;
    }
}


-(IBAction)switchValueChange:(id)sender {
    
    if(self.noteTextView.isFirstResponder)
        [self.noteTextView resignFirstResponder];
    if(self.titleTxtFld.isFirstResponder)
        [self.titleTxtFld resignFirstResponder];
}

-(IBAction)dateBtnPressed:(id)sender    {
    @autoreleasepool {
        if(dateTimeBtn.tag == 0)    {
            if([titleTxtFld isFirstResponder])  {
                [titleTxtFld resignFirstResponder];
            }
            NSDate* date = [NSDate date];
            
            [datePicker setMinimumDate:date];
            date = NULL;
            dateTimeBtn.tag = 1;
            [self.view addSubview:datePicker];
            [self setViewMovedUp];
        }
        else if(dateTimeBtn.tag == 1)    {
            dateTimeBtn.tag = 0;
            
            [self moveDown];
        }
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
    pt.y -= 65;
    
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
    pt.y -= 227;
    
    [scrollView setContentOffset:pt animated:YES]; 
}
@end