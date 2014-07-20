//
//  IMIHelpViewController.m
//  YO MAP
//
//  Created by imicreation on 14/11/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIHelpViewController.h"

#define numberofPages 5;

#define SCREEN_SIZE_IPHONE_CLASSIC 3.5
#define SCREEN_SIZE_IPHONE_TALL 4.0
#define SCREEN_SIZE_IPAD_CLASSIC 9.7

@interface IMIHelpViewController ()
@end

@implementation IMIHelpViewController
@synthesize scrollView;
@synthesize pageControl;
@synthesize startButton;
@synthesize nextButton;
@synthesize isComeFromSettings;

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
}

-(void)viewWillAppear:(BOOL)animated    {
    [pageControl addObserver:self forKeyPath:@"currentPage" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    nextButton.tag = 0;  // next button
    
    if(isComeFromSettings)  {
        [startButton setImage:[UIImage imageNamed:@"Helpexit.png"] forState:UIControlStateNormal];
    }
    else    {
       [startButton setImage:[UIImage imageNamed:@"Helpskip.png"] forState:UIControlStateNormal];
    }
}

-(void)dealloc  {
     [pageControl removeObserver:self forKeyPath:@"currentPage"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"currentPage"])
    {
        id newValue = change[NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        
        if([newValue integerValue] == (6-1) && [oldValue integerValue] == (6-2) && newValue != oldValue)    {
            [nextButton setImage:[UIImage imageNamed:@"Helpdone.png"] forState:UIControlStateNormal];
            nextButton.tag = 1;
        }
        else if((!([newValue integerValue] == (6-1))) && newValue != oldValue)   {
              [nextButton setImage:[UIImage imageNamed:@"Helpnext.png"] forState:UIControlStateNormal];
             nextButton.tag = 0;
        }
    }
}

-(IBAction)startBtnPressed:(id)sender   {
    
    if(isComeFromSettings)  {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else    {
        [self performSegueWithIdentifier:@"StartSague" sender:sender];
    }
}

-(IBAction)nextBtnPressed:(id)sender    {
    
    if(nextButton.tag == 1) {
        if(isComeFromSettings)  {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else    {
            [self performSegueWithIdentifier:@"StartSague" sender:sender];
        }
    }
    
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * (pageControl.currentPage + 1);
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
    pageControl.currentPage++;
    
}

-(void) viewDidAppear:(BOOL)animated    {
    [self setupPage];
}

#pragma mark -
#pragma mark The Guts
- (void)setupPage
{
	scrollView.delegate = self;
    
	[self.scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
    
	NSUInteger nimages = 0;
	CGFloat cx = 0;
	for (; ; nimages++) {
		NSString *imageName;
        
        if([self screenPhysicalSize] == SCREEN_SIZE_IPHONE_TALL)    {
            // Load resources for iOS 6.1 or earlier
            imageName = [NSString stringWithFormat:@"imageTall%d.png", (int)(nimages + 1)];
        } else {
            // Load resources for iOS 7 or later
            imageName = [NSString stringWithFormat:@"image%d.png", (int)(nimages + 1)];
        }
		UIImage *image = [UIImage imageNamed:imageName];
		if (image == nil) {
			break;
		}
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		
		CGRect rect = imageView.frame;
		rect.size.height = image.size.height;
		rect.size.width = image.size.width;
		rect.origin.x = ((scrollView.frame.size.width - image.size.width) / 2) + cx;
		rect.origin.y = ((scrollView.frame.size.height - image.size.height) / 2);
        
		imageView.frame = rect;
        
		[scrollView addSubview:imageView];
		cx += scrollView.frame.size.width;
	}
	self.pageControl.numberOfPages = nimages;
	[scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
    [scrollView setScrollEnabled:YES];
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

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
//    if (pageControlIsChangingPage) {
//        return;
//    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    //pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)changePage:(id)sender
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
   // pageControlIsChangingPage = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
