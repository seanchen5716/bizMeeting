//
//  IMIDetailViewController.m
//  YO MAP
//
//  Created by imicreation on 20/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIDetailViewController.h"
#import "IMIMeetViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FPPopoverController.h"
#import "DemoTableController.h"
#import "IMIAppDelegate.h"
#import "IMIContactModel.h"
#include <math.h>

@interface IMIDetailViewController ()
@property(nonatomic, retain)FPPopoverController *popover;

@property (nonatomic, weak) IMIAppDelegate* appdelegate;
@property (nonatomic, retain) NSMutableString *feedbackMsg;
@property (nonatomic, retain) MFMailComposeViewController *mailPicker;
@property (nonatomic, retain) MFMessageComposeViewController *messagePicker;

-(void)addPopover;
-(void) setBadge;
-(void)updateViewWithModelValue ;
- (void)RefreshView:(NSNotification *)notification;
-(void)refreshControllerView:(NSNotification *)notification;
-(void)setshadows:(UILabel*)lbl;
@end

@implementation IMIDetailViewController

@synthesize contactName;
@synthesize contactCompany;
@synthesize contactMobile;
@synthesize contactEmail;
@synthesize addressTxtView;
@synthesize contactphoto;
@synthesize bedgeBtn;
@synthesize navController;
@synthesize popover;
@synthesize isComeFromMap;
@synthesize appdelegate;
@synthesize contactModel = _contactModel;
@synthesize feedbackMsg;
@synthesize mailPicker;
@synthesize messagePicker;
@synthesize bedgeBtnBkndView;

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
    
    if(appdelegate) {
        [appdelegate.sharedContactModelManager registerObserverForAllContacts:self];
    }
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshView:)
                                                 name:ApplicationDidFinishContactSyncing
                                               object:nil];
    
    contactName.font = [UIFont fontWithName:@"Helvetica" size:20];
    //sectionTitle.textColor = [UIColor whiteColor];
    contactName.backgroundColor = [UIColor clearColor];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor blackColor];
    titleView.shadowOffset = CGSizeMake(0.0f, -1.0f);
    titleView.textColor = [UIColor colorWithRed:0.9216 green:0.7020 blue:0.2353 alpha:1.00]; // Your color here
    titleView.text = @"Details";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
//    self.navigationItem.backBarButtonItem.tintColor = [UIColor redColor];
//    self.navigationController.navigationItem.backBarButtonItem.tintColor =[UIColor redColor];
    
 
    if(isComeFromMap)
        self.navigationItem.leftBarButtonItem = [self createBarBtnItom:[UIImage imageNamed:@"mapBarIcon.png"]selector:@selector(backBtnPressed:)];
    else
        self.navigationItem.leftBarButtonItem = [self createBarBtnItom:[UIImage imageNamed:@"contacts.png"]selector:@selector(backBtnPressed:)];
    
	// Do any additional setup after loading the view.
}

-(UIBarButtonItem*)createBarBtnItom:(UIImage*) keyboardAddImage selector:(SEL)selector {
    
    UIButton *toggleKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleKeyboardButton.bounds = CGRectMake( 0, 0, keyboardAddImage.size.width, keyboardAddImage.size.height );
    [toggleKeyboardButton setImage:keyboardAddImage forState:UIControlStateNormal];
    [toggleKeyboardButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toggleKeyboardItem = [[UIBarButtonItem alloc] initWithCustomView:toggleKeyboardButton];
    
    return toggleKeyboardItem;
}


-(void)setshadows:(UILabel*)lbl  {
    lbl.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    lbl.shadowOffset = CGSizeMake(1, 1);
}

-(void) dealloc {
    if(appdelegate)
        [appdelegate.sharedContactModelManager removeObserverForAllContacts:self];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    appdelegate = NULL;
    _contactModel = NULL;
    
    feedbackMsg = NULL;
    mailPicker = NULL;
    messagePicker = NULL;
    popover = NULL;
    bedgeBtn = NULL;
    bedgeBtnBkndView = NULL;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"keyPath %@", keyPath);
    if ([keyPath isEqual:@"todaysUpcommingMeets"])
    {
        id newValue = [object valueForKeyPath:keyPath];
         id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
         NSLog(@"The keyPath %@ changed from %@ to %@", keyPath, oldValue, newValue);
        IMIContactModel* obj = (IMIContactModel*)object;
       
        if([[appdelegate.sharedContactModelManager getFullName:obj.personRef] isEqualToString:@"kuldeep tyagi"])
             NSLog(@"The keyPath %@ changed to %@", keyPath, newValue);
    }
    else if ([keyPath isEqual:@"futureMeetsExcludingTodaysMeets"])
    {
        id newValue = change[NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSLog(@"The keyPath %@ changed from %@ to %@", keyPath, oldValue, newValue);
    }
    
    [self setBadge];
}

-(void)viewDidAppear:(BOOL)animated {
    
    if(bedgeBtn.hidden == NO && isComeFromMap)  {
        [self addPopover];
        isComeFromMap = NO;
    }
}

-(IBAction)backBtnPressed:(id)sender    {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setBadge    {
    if(_contactModel)  {
        int numberOfMeet = [_contactModel.allMeets count];
        if(numberOfMeet >0) {
            [bedgeBtn setTitle:[NSString stringWithFormat:@"%i", numberOfMeet] forState:UIControlStateNormal];
            
            if(_contactModel.todaysUpcommingMeets > 0)   {
                [bedgeBtnBkndView setImage:[UIImage imageNamed:@"greenBadge.png"]];
            }
            else if(_contactModel.todaysUpcommingMeets <= 0 && _contactModel.futureMeetsExcludingTodaysMeets > 0) {
                 [bedgeBtnBkndView setImage:[UIImage imageNamed:@"redBadge.png"]];
            }
            else if(_contactModel.todaysUpcommingMeets <= 0 && _contactModel.futureMeetsExcludingTodaysMeets <= 0 && numberOfMeet >0) {
                 [bedgeBtnBkndView setImage:[UIImage imageNamed:@"grayBadge.png"]];
            }
            bedgeBtn.hidden = NO;
            bedgeBtnBkndView.hidden = NO;
        }
        else    {
            if(popover)
                [popover dismissPopoverAnimated:YES completion:^(void){
                    popover = NULL;
                }];
            
            bedgeBtn.titleLabel.text = @"";
            bedgeBtn.hidden = YES;
            bedgeBtnBkndView.hidden = YES;
        }
    }
}

-(void) viewWillAppear:(BOOL)animated   {
    self.navigationController.navigationBarHidden = NO;
    [self updateViewWithModelValue];
}

-(void)updateViewWithModelValue {
    
    if(_contactModel)  {
        
        [self setBadge];
        
        self.contactName.text = [appdelegate.sharedContactModelManager getFullName:_contactModel.personRef];
        self.contactCompany.text = [appdelegate.sharedContactModelManager getOrgenizationName:_contactModel.personRef];
        self.contactMobile.text = [appdelegate.sharedContactModelManager getMobileName:_contactModel.personRef];
        [self.contactEmail setText:[appdelegate.sharedContactModelManager getEmail:_contactModel.personRef]];
        
        NSMutableDictionary* addressDict = (NSMutableDictionary*)[appdelegate.sharedContactModelManager getAddress:_contactModel.personRef];
        NSArray* keys = [addressDict allKeys];
        if([keys count] <= 0)
            [self.addressTxtView setText:@"Not Available..."];
        else    {
            NSMutableString* addressString =[[NSMutableString alloc] init];
            
            if([keys containsObject:@"Street"])
                [addressString appendString:[NSString stringWithFormat:@"%@",(NSString*)[addressDict objectForKey:@"Street"]]];
            if([keys containsObject:@"City"])
                [addressString appendFormat:@"\n%@", [NSString stringWithFormat:@"%@",(NSString*)[addressDict objectForKey:@"City"]]];
            if([keys containsObject:@"State"])
                [addressString appendFormat:@"\n%@", [NSString stringWithFormat:@"%@",(NSString*)[addressDict objectForKey:@"State"]]];
            if([keys containsObject:@"Country"])
                [addressString appendFormat:@"\n%@", [NSString stringWithFormat:@"%@",(NSString*)[addressDict objectForKey:@"Country"]]];
            if([keys containsObject:@"ZIP"])
                [addressString appendFormat:@" %@", [NSString stringWithFormat:@"%@",(NSString*)[addressDict objectForKey:@"ZIP"]]];
            addressTxtView.text = addressString;
            addressString = NULL;
        }
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
             UIImage* img = [self circularScaleNCrop:[appdelegate.sharedContactModelManager getContactImage:_contactModel.personRef] rect:CGRectMake(0, 0, 66, 66)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(img)
                    [self.contactphoto setImage:img];
                else
                    [self.contactphoto setImage:[UIImage imageNamed:@"Default Photo.png"]];
            });
        });

        addressDict = NULL;
        keys = NULL;
    }
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize withOriginalImage:(UIImage *)origin {
    
    UIImage *sourceImage = origin;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    return newImage ;
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


#pragma mark IMIContactModelManager Notification Handler 

- (void)RefreshView:(NSNotification *)notification {
    [self performSelector:@selector(refreshControllerView:)
               withObject:notification
               afterDelay:0.0f];
}

-(void)refreshControllerView:(NSNotification *)notification   {
    if(_contactModel)
        [self updateViewWithModelValue];
    else    {
        if(mailPicker)  {
            UIViewController* controller = [self presentedViewController];
            if(controller &&[controller isEqual:mailPicker])    {
                [mailPicker dismissViewControllerAnimated:YES completion:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
        if(messagePicker)  {
            UIViewController* controller = [self presentedViewController];
            if(controller &&[controller isEqual:messagePicker])    {
                [messagePicker dismissViewControllerAnimated:YES completion:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
        if(popover)
            [popover dismissPopoverAnimated:YES completion:^(void){
                popover = NULL;
                [self.navigationController popViewControllerAnimated:YES];
            }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)demoTableController:(DemoTableController *)controller    {
    if(_contactModel)  {
        int numberOfMeet = [_contactModel.allMeets count];
        if(numberOfMeet >0) {
            [bedgeBtn setTitle:[NSString stringWithFormat:@"%i", numberOfMeet] forState:UIControlStateNormal];
            
            if(_contactModel.todaysUpcommingMeets > 0)   {
                [bedgeBtnBkndView setImage:[UIImage imageNamed:@"greenBadge.png"]];
            }
            else if(_contactModel.todaysUpcommingMeets <= 0 && _contactModel.futureMeetsExcludingTodaysMeets > 0) {
                [bedgeBtnBkndView setImage:[UIImage imageNamed:@"redBadge.png"]];
            }
            else if(_contactModel.todaysUpcommingMeets <= 0 && _contactModel.futureMeetsExcludingTodaysMeets <= 0 && numberOfMeet >0) {
                 [bedgeBtnBkndView setImage:[UIImage imageNamed:@"grayBadge.png"]];
            }
            bedgeBtn.hidden = NO;
            bedgeBtnBkndView.hidden = NO;
        }
        else    {
            bedgeBtn.titleLabel.text = @"";
            bedgeBtn.hidden = YES;
            bedgeBtnBkndView.hidden = YES;
            if(popover)
                [popover dismissPopoverAnimated:YES completion:^(void){
                    popover = NULL;
                }];
        }
    }
}

-(void)addPopover   {
    navController = [[UINavigationController alloc] init];
    //navController.navigationBarHidden = YES;
    [navController.navigationBar setBarStyle:UIBarStyleDefault];
    navController.navigationBar.opaque = YES;
    navController.navigationBar.translucent = NO;
    [navController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.2980 green:0.3255 blue:0.3333 alpha:1.0]];
    [navController.navigationBar setTintColor:[UIColor colorWithRed:0.2980 green:0.3255 blue:0.3333 alpha:1.0]];
    
    //the controller we want to present as a popover
    DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
    controller.delegate = self;
    controller.navController = navController;
    [controller setContactModel:_contactModel];
    
    [navController pushViewController:controller animated:NO];
    
    popover = [[FPPopoverController alloc] initWithViewController:navController];
    //popover.arrowDirection = FPPopoverArrowDirectionAny;
    popover.tint = FPPopoverLightGrayTint;
    popover.border = NO;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)    {
        popover.contentSize = CGSizeMake(300, 500);
    }
    popover.contentSize = CGSizeMake(323, 325);
    popover.alpha = 1.0;
    
    popover.arrowDirection = FPPopoverArrowDirectionAny;
    
    //sender is the UIButton view
    [popover presentPopoverFromView:self.contactphoto];
}

-(IBAction)popover:(id)sender
{
    [self addPopover];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"Meet"])   {
        // Get reference to the destination view controller
        IMIMeetViewController *vc = [segue destinationViewController];
        [vc setContactModel:_contactModel];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mathods for sending message and mail

-(IBAction)mailBtnPressed:(id)sender    {
    
    if(self.feedbackMsg)
        self.feedbackMsg = NULL;
    
    self.feedbackMsg = [[NSMutableString alloc] init];
    
    [self showMailPicker];
}
-(IBAction)messageBtnPressed:(id)sender {
    if(self.feedbackMsg)
        self.feedbackMsg = NULL;
    
    self.feedbackMsg = [[NSMutableString alloc] init];
    [self showSMSPicker];

}

#pragma mark - Rotation

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
// -------------------------------------------------------------------------------
//	shouldAutorotateToInterfaceOrientation:
//  Disable rotation on iOS 5.x and earlier.  Note, for iOS 6.0 and later all you
//  need is "UISupportedInterfaceOrientations" defined in your Info.plist
// -------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#endif

#pragma mark - Actions

// -------------------------------------------------------------------------------
//	showMailPicker:
//  IBAction for the Compose Mail button.
// -------------------------------------------------------------------------------
- (void)showMailPicker  {
    // You must check that the current device can send email messages before you
    // attempt to create an instance of MFMailComposeViewController.  If the
    // device can not send email messages,
    // [[MFMailComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMailComposeViewController canSendMail])
        // The device can send email.
    {
        [self displayMailComposerSheet];
    }
    else
        // The device can not send email.
    {
        [self.feedbackMsg setString:@"Device not configured to send mail."];
        [appdelegate showAlertWithTitle:@"Alert!" withMessage:feedbackMsg cancelBtnTitle:@"OK"];
    }
}

// -------------------------------------------------------------------------------
//	showSMSPicker:
//  IBAction for the Compose SMS button.
// -------------------------------------------------------------------------------
- (void)showSMSPicker
{
    // You must check that the current device can send SMS messages before you
    // attempt to create an instance of MFMessageComposeViewController.  If the
    // device can not send SMS messages,
    // [[MFMessageComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMessageComposeViewController canSendText])
        // The device can send email.
    {
        [self displaySMSComposerSheet];
    }
    else
        // The device can not send email.
    {
        [self.feedbackMsg setString:@"Device not configured to send SMS."];
        [appdelegate showAlertWithTitle:@"Alert!" withMessage:feedbackMsg cancelBtnTitle:@"OK"];
    }
}

#pragma mark - Compose Mail/SMS

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet
{
    if(mailPicker)  {
        mailPicker = NULL;
    }
    mailPicker = [[MFMailComposeViewController alloc] init];
	mailPicker.mailComposeDelegate = self;
    
    mailPicker.navigationBar.barStyle = UIBarStyleDefault;
    mailPicker.navigationBar.translucent = NO;
    mailPicker.navigationBar.opaque = YES;
    mailPicker.navigationBar.tintColor = [UIColor colorWithRed:0.3216 green:0.3490 blue:0.3569 alpha:1.0];
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        // Load resources for iOS 6.1 or earlier
        mailPicker.navigationBar.barTintColor = [UIColor colorWithRed:0.3216 green:0.3490 blue:0.3569 alpha:1.0];
        [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:[UIColor redColor]];
    }
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.9216 green:0.7020 blue:0.2353 alpha:1.00], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, 0, UITextAttributeTextShadowOffset, nil];
    [[UINavigationBar appearance] setTitleTextAttributes: textTitleOptions];
    
	[mailPicker setSubject:@"New Mail"];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:[appdelegate.sharedContactModelManager getEmail:_contactModel.personRef]];
	
	[mailPicker setToRecipients:toRecipients];
	
	// Attach an image to the email
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
//	NSData *myData = [NSData dataWithContentsOfFile:path];
//	[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
	
	// Fill out the email body text
	//NSString *emailBody = @"";
	//[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:mailPicker animated:YES completion:NULL];
    
}

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an SMS composition interface inside the application.
// -------------------------------------------------------------------------------
- (void)displaySMSComposerSheet
{
    if(messagePicker)  {
        messagePicker = NULL;
    }

	messagePicker = [[MFMessageComposeViewController alloc] init];
	messagePicker.messageComposeDelegate = self;
	messagePicker.navigationBar.barStyle = UIBarStyleDefault;
    messagePicker.navigationBar.translucent = NO;
    messagePicker.navigationBar.opaque = YES;
    messagePicker.navigationBar.tintColor = [UIColor colorWithRed:0.3216 green:0.3490 blue:0.3569 alpha:1.0];
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        // Load resources for iOS 6.1 or earlier
        messagePicker.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.3216 green:0.3490 blue:0.3569 alpha:1.0];
    }
    
    // You can specify one or more preconfigured recipients.  The user has
    // the option to remove or add recipients from the message composer view
    // controller.
     
    NSArray *toRecipients = [NSArray arrayWithObject:[appdelegate.sharedContactModelManager getMobileName:_contactModel.personRef]];
     messagePicker.recipients = toRecipients; 
    
    // You can specify the initial message text that will appear in the message
    // composer view controller.
    //picker.body = @"Hello from California!";
    
	[self presentViewController:messagePicker animated:YES completion:NULL];
}


#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
            [self.feedbackMsg setString: @"Mail sending canceled"];
			break;
		case MFMailComposeResultSaved:
            [self.feedbackMsg setString:@"Mail saved"];
			break;
		case MFMailComposeResultSent:
            [self.feedbackMsg setString:@"Mail sent"];
			break;
		case MFMailComposeResultFailed:
            [self.feedbackMsg setString:@"Mail sending failed"];
			break;
		default:
            [self.feedbackMsg setString:@"Mail not sent"];
			break;
	}
    
    if(mailPicker)  {
        [self dismissViewControllerAnimated:YES completion:^(void)  {
            [appdelegate showAlertWithTitle:@"Alert!" withMessage:feedbackMsg cancelBtnTitle:@"OK"];
        }];
    }
}

// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
            [self.feedbackMsg setString:@"SMS sending canceled"];
			break;
		case MessageComposeResultSent:
            [self.feedbackMsg setString:@"SMS sent"];
			break;
		case MessageComposeResultFailed:
            [self.feedbackMsg setString:@"SMS sending failed"];
			break;
		default:
            [self.feedbackMsg setString:@"SMS not sent"];
			break;
	}
    
    if(messagePicker)  {
        [self dismissViewControllerAnimated:YES completion:^(void)  {
            [appdelegate showAlertWithTitle:@"Alert!" withMessage:feedbackMsg cancelBtnTitle:@"OK"];
        }];
    }
}
@end
