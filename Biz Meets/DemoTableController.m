
//
//  DemoTableControllerViewController.m
//  FPPopoverDemo

#import "DemoTableController.h"
#include <QuartzCore/QuartzCore.h>
#import "IMIEditMeetPopoverViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "IMILocalNotifiactionController.h"
#import "IMIAppDelegate.h"
#import "IMIContactModel.h"

@interface DemoTableController ()

@property (nonatomic, weak) IMIAppDelegate* appdelegate;

-(BOOL) deleteRecordWithIndex:(int)row ;
@end

@implementation DemoTableController
@synthesize sdelegate=_sdelegate;
@synthesize navController;
@synthesize delegate;

@synthesize appdelegate;
@synthesize contactModel = _contactModel;

- (void)viewDidLoad
{
    appdelegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appdelegate)
        [appdelegate.sharedContactModelManager registerObserverForAllContacts:self];

    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    UIView *view = [[UIView alloc] init];
    self.tableView.tableFooterView = view;
    [self.tableView setBounces:NO];
    
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        // Load resources for iOS 6.1 or earlier
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.3216 green:0.3490 blue:0.3569 alpha:1.0];
    }
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor blackColor];
    titleView.shadowOffset = CGSizeMake(0.0f, -1.0f);
    titleView.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.00]; // Your color here
    titleView.text = @"Meets";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
}

-(void) dealloc {
    if(appdelegate)
        [appdelegate.sharedContactModelManager removeObserverForAllContacts:self];
    
    appdelegate = NULL;
    _contactModel = NULL;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"keyPath %@", keyPath);
    if ([keyPath isEqual:@"todaysUpcommingMeets"])
    {
        id newValue = [object valueForKeyPath:keyPath];
        NSLog(@"The keyPath %@ changed to %@", keyPath, newValue);
    }
    else if ([keyPath isEqual:@"futureMeetsExcludingTodaysMeets"])
    {
        id newValue = change[NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSLog(@"The keyPath %@ changed from %@ to %@", keyPath, oldValue, newValue);
    }
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated    {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_contactModel.allMeets )
        return [_contactModel.allMeets count];
    
    return 1;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [_contactModel.allMeets count])
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        [self deleteRecordWithIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView endUpdates];
        [tableView reloadData];
        
        [tableView.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate demoTableController:self];
}

-(BOOL) deleteRecordWithIndex:(int)row   {
    NSDictionary* meetInfo = [_contactModel.allMeets objectAtIndex:row];
    BOOL status = [appdelegate.sharedContactModelManager DeleteMeetWithMeetId:[[meetInfo objectForKey:@"MeetId"] longLongValue] :_contactModel];
    
    if(status)  {
        [IMILocalNotifiactionController cancelNotification:[NSString stringWithFormat:@"%@", [meetInfo objectForKey:@"MeetId"]]];
        return YES;
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
  
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 78, self.view.bounds.size.width, 0.5)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:bottomLineView];
    
    cell.textLabel.numberOfLines = 2;
   
    [cell.textLabel setMinimumScaleFactor:0.7];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell setClipsToBounds:YES];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    backView.opaque = YES;
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"texture.png"]];
    
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Arial" size:17]];
    
    if(_contactModel.allMeets && [_contactModel.allMeets count] == 0) {
        cell.textLabel.text = @"No Meet.";
        cell.detailTextLabel.text = @" No Date Fixed";
    }
    else if(_contactModel.allMeets && [_contactModel.allMeets count]>indexPath.row)    {
        
        NSDictionary* meetInfo = [_contactModel.allMeets objectAtIndex:indexPath.row];
        NSTimeInterval interval = [[meetInfo objectForKey:@"TimeIntervalSinceNow"] doubleValue];
        UIImage *enableTextureImage = [UIImage imageNamed:@"texture.png"];
        UIImage *disableTextureImage = [UIImage imageNamed:@"texture.png"];
        if(interval >= 0)   {
          //  backView.backgroundColor = [UIColor colorWithPatternImage:enableTextureImage];
            cell.backgroundView = [[UIImageView alloc] initWithImage:enableTextureImage];
            cell.textLabel.textColor = [UIColor colorWithRed:0.1137 green:0.1176 blue:0.1216 alpha:1.0];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4706 green:0.4784 blue:0.4863 alpha:1.0];
        }
        else    {
            cell.backgroundView = [[UIImageView alloc] initWithImage:disableTextureImage];
            cell.textLabel.textColor = [UIColor colorWithRed:0.6157 green:0.6196 blue:0.6235 alpha:1.0];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.7569 green:0.7686 blue:0.7804 alpha:1.0];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [meetInfo objectForKey:@"Title"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [meetInfo objectForKey:@"Date"]];
    }
    else    {
        cell.textLabel.text = @"No Meet.";
        cell.detailTextLabel.text = @" No Date Fixed";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Change the height if Edit Unknown Contact is the row selected
	return 80;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if(_contactModel.allMeets)   {
        NSDictionary* meetInfo = [_contactModel.allMeets objectAtIndex:indexPath.row];
        if(self.navController)    {
            IMIEditMeetPopoverViewController* vc = [[IMIEditMeetPopoverViewController alloc] initWithNibName:@"IMIEditMeetPopoverViewController" bundle:nil];
            [vc setMeet:meetInfo];
            [vc setContactModel:_contactModel];
            
            [self.navController pushViewController:vc animated:YES];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
