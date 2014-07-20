//
//  IMIHelpViewController.h
//  YO MAP
//
//  Created by imicreation on 14/11/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IMIHelpViewController : UIViewController<UIScrollViewDelegate> {
    
    BOOL pageControlIsChangingPage;
    BOOL isComeFromSettings;
}
@property (nonatomic, assign) BOOL isComeFromSettings;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl* pageControl;
@property (nonatomic, weak) IBOutlet UIButton* startButton;
@property (nonatomic, weak) IBOutlet UIButton* nextButton;

/* for pageControl */
- (IBAction)changePage:(id)sender;

/* internal */
- (void)setupPage;

-(IBAction)startBtnPressed:(id)sender;
-(IBAction)nextBtnPressed:(id)sender ;

@end
