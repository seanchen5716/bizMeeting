//
//  IMISplashViewController.m
//  YO MAP
//
//  Created by imicreation on 14/11/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMISplashViewController.h"
#import "IMIHelpViewController.h"

#define SCREEN_SIZE_IPHONE_CLASSIC 3.5
#define SCREEN_SIZE_IPHONE_TALL 4.0
#define SCREEN_SIZE_IPAD_CLASSIC 9.7

@interface IMISplashViewController ()

@end

@implementation IMISplashViewController
@synthesize imgView;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([self screenPhysicalSize] == SCREEN_SIZE_IPHONE_TALL)    {
        
        [imgView setImage:[UIImage imageNamed:@"Default-568h.png"]];
    }
    else    {
        [imgView setImage:[UIImage imageNamed:@"Default.png"]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"Help"]) {
        IMIHelpViewController *vc = [segue destinationViewController];
        vc.isComeFromSettings = NO;
        vc = NULL;
    }
}

@end
