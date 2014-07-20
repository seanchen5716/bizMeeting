//
//  PKGCell.m
//  KEsselShyam
//
//  Created by KULDEEP TYAGI on 24/01/13.
//
//

#import "PKGCell.h"
#import <QuartzCore/QuartzCore.h>

#define COLUMN_WIDTH 200
#define TEXT_SIZE 15
#define TEXT_FONT_NAME @"Arial"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface PKGCell ()
@property (nonatomic,retain) UIButton* bedge;
@property (nonatomic,retain) UILabel* nameLbl;
@property (nonatomic,retain) UILabel* detailsLbl;
@property (nonatomic, retain) UIImageView* PinView;
@property (nonatomic, retain) UIImageView* badgeImgView;

@end

@implementation PKGCell
@synthesize detailsLbl, nameLbl, PinView, bedge, badgeImgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        UIImageView *av = [[UIImageView alloc] initWithFrame:self.frame];
//        av.backgroundColor = [UIColor clearColor];
//        av.opaque = NO;
//        av.image = [UIImage imageNamed:@"ContactCellBg.png"];
//        self.backgroundView = av;
        //self.backgroundColor = [UIColor whiteColor];
        
        nameLbl = [[UILabel alloc] initWithFrame: CGRectMake(42, 10, 2, 25)];
        [nameLbl setNumberOfLines:1];
        [nameLbl setTextColor:[UIColor blackColor]];
        [nameLbl setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [nameLbl setBackgroundColor:[UIColor clearColor]];
        [nameLbl setFont:[UIFont boldSystemFontOfSize:18]];
        nameLbl.adjustsFontSizeToFitWidth = NO;
        nameLbl.textAlignment =  NSTextAlignmentLeft;
      //  [nameLbl setText:@"Business Meet"];
        [nameLbl setLineBreakMode:NSLineBreakByTruncatingTail];
        //[self setshadows:nameLbl];
        [self.contentView addSubview:nameLbl];

        badgeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(32, 4, 22, 22)];
        [badgeImgView setImage:[UIImage imageNamed:@"greenBadge.png"]];
        [badgeImgView setBackgroundColor:[UIColor clearColor]];
        [badgeImgView setContentMode:UIViewContentModeCenter];
        [self.contentView addSubview:badgeImgView];

        bedge = [UIButton buttonWithType:UIButtonTypeCustom];
        [bedge setFrame:CGRectMake(32, 4, 22, 22)];
        [bedge setBackgroundColor:[UIColor clearColor]];
        [[bedge layer] setMasksToBounds:NO];
        [bedge.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [bedge.titleLabel setMinimumScaleFactor:0];
        [self.contentView bringSubviewToFront:bedge];
        [self.contentView addSubview:bedge];
        
        detailsLbl = [[UILabel alloc] initWithFrame: CGRectMake(42, 15 , 250, 50)];
        [detailsLbl setNumberOfLines:2];
        [detailsLbl setTextColor:[UIColor colorWithRed:0.3400 green:0.3400 blue:0.3400 alpha:1.0]];
        [detailsLbl setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [detailsLbl setBackgroundColor:[UIColor clearColor]];
        [detailsLbl setFont:[UIFont systemFontOfSize:14]];
        detailsLbl.adjustsFontSizeToFitWidth = NO;
        detailsLbl.textAlignment =  NSTextAlignmentLeft;
       // [detailsLbl setText:@"Kuldeep"];
        [self.contentView addSubview:detailsLbl];

        PinView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 60)];
        [PinView setImage:[UIImage imageNamed:@"greenf.png"]];
        [PinView setBackgroundColor:[UIColor clearColor]];
        [PinView setContentMode:UIViewContentModeCenter];
        [self.contentView addSubview:PinView];
    }
	return self;
}

-(void)setshadows:(UILabel*)lbl  {
    lbl.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    lbl.shadowOffset = CGSizeMake(1, 1);
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

#pragma mark Local mathods
-(void)initializeTableCellName:(NSString*)name Detail:(NSString*)details image:(UIImage*)pinImage bedgeText:(NSString*)bedgeText badgeImage:(UIImage*)img{
    
    int count = [name length];
    int width = count*11;
    if ([name length] > 24) {
        width = 250;
    }
    CGSize fontSize = CGSizeMake(width, 10);
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        // code here for iOS 5.0,6.0 and so on
        fontSize = [name sizeWithFont:[UIFont systemFontOfSize:20]];
    }
    else {
        // code here for iOS 7.0
        fontSize = [name sizeWithAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:20]}];
    }
    
    if(fontSize.width >245)
        fontSize.width = 238;
    
    [nameLbl setFrame:CGRectMake(42, 10,fontSize.width , 25)];
    [bedge setFrame:CGRectMake(fontSize.width +40, 5, 25, 25)];
    [badgeImgView setFrame:CGRectMake(fontSize.width +40, 4, 25, 25)];
    [badgeImgView setImage:img];
    
    [nameLbl setText:name];
    [detailsLbl setText:details];
    [PinView setImage:pinImage];
    
    if([bedgeText isEqualToString:@"NO"])   {
        bedge.hidden = YES;
        badgeImgView.hidden = YES;
        return;
    }
    badgeImgView.hidden = NO;
    bedge.hidden = NO;
    [bedge setTitle:bedgeText forState:UIControlStateNormal];
}
@end