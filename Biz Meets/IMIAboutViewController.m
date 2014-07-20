//
//  IMIAboutViewController.m
//  YO MAP
//
//  Created by imicreation on 22/11/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIAboutViewController.h"
#import "IMIHelpViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SCREEN_SIZE_IPHONE_CLASSIC 3.5
#define SCREEN_SIZE_IPHONE_TALL 4.0
#define SCREEN_SIZE_IPAD_CLASSIC 9.7

@interface IMIAboutViewController ()

@end

@implementation IMIAboutViewController
@synthesize toolBar;
@synthesize bgImgView;
@synthesize titleBtn;

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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    titleBtn.layer.shadowColor = [UIColor blackColor].CGColor;
//    titleBtn.layer.shadowOffset = CGSizeMake(0.0f, -0.5f);
//    titleBtn.layer.shadowOpacity = 1.0f;
//    titleBtn.layer.masksToBounds = NO;
    titleBtn.titleLabel.shadowColor = [UIColor blackColor];
    titleBtn.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.5f);
    titleBtn.layer.masksToBounds = NO;
    titleBtn.titleLabel.layer.masksToBounds = NO;
    //titleBtn.layer.shadowOpacity = 1.0f;
  //  titleBtn.titleLabel.layer.shadowOpacity = 1.0f;
	// Do any additional setup after loading the view.
}

-(IBAction)openWeb:(id)sender   {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appsstreet.com"]];
}

-(IBAction)sendMail:(id)sender  {
    /* create mail subject */
    NSString *subject = [NSString stringWithFormat:@"Mail"];
    
    /* define email address */
    NSString *mail = [NSString stringWithFormat:@"info@appsstreet.com"];

    /* create the URL */
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    /* load the URL */
    [[UIApplication sharedApplication] openURL:url];
}

-(void)viewWillAppear:(BOOL)animated    {
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        // Load resources for iOS 6.1 or earlier
        self.toolBar.barTintColor = [UIColor colorWithRed:0.2784 green:0.3020 blue:0.3020 alpha:1.0];
        [self.toolBar setFrame:CGRectMake(0, 19, 320, 44)];
    }
    else    {
        [self.toolBar setFrame:CGRectMake(0, 0, 320, 44)];
    }
    if([self screenPhysicalSize] == SCREEN_SIZE_IPHONE_TALL)    {
        // Load resources for iOS 6.1 or earlier
        [bgImgView setImage:[UIImage imageNamed:@"AboutBg-528h.png"]];
    } else {
        // Load resources for iOS 7 or later
         [bgImgView setImage:[UIImage imageNamed:@"AboutBg.png"]];
    }
}

- (CGFloat)screenPhysicalSize
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height < 500)
            return SCREEN_SIZE_IPHONE_CLASSIC;  // iPhone 4S / 4th Gen iPod Touch or earlier
        else
            return SCREEN_SIZE_IPHONE_TALL;  // iPhone 5
    }
    else
    {
        return SCREEN_SIZE_IPAD_CLASSIC; // iPad
    }
}

-(IBAction) backBtnPressed:(id)sender   {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SettingHelp"]) {
        IMIHelpViewController *vc = [segue destinationViewController];
        vc.isComeFromSettings = YES;
        vc = NULL;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
