 //
//  IMIViewController.m
//  YO MAP
//
//  Created by imicreation on 18/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIViewController.h"
#import "IMIDetailViewController.h"
#import "PKGCell.h"
#import "IMIAppDelegate.h"
#import "IMIContactModel.h"

@interface IMIViewController ()
@property (nonatomic, retain) NSMutableArray *_filteredcontactModelDataSource;
@property (weak, nonatomic) NSMutableArray * _contactModelDataSource;
@property (nonatomic, retain) NSMutableArray* _todayMeetContactModelDataSource;
@property (nonatomic, weak) NSMutableArray * _contactModelDataSourceReferences;

@property (nonatomic, weak) IMIAppDelegate* appdelegate;

- (void)RefreshView:(NSNotification *)notification;
-(void)reloadContactTableView:(NSNotification *)notification;
-(void) fillTodaysMeetContactModelDatasource;
@end

@implementation IMIViewController
@synthesize contactTableView;

@synthesize _contactModelDataSource;
@synthesize _filteredcontactModelDataSource;
@synthesize _todayMeetContactModelDataSource;
@synthesize _contactModelDataSourceReferences;
@synthesize contactSearchBar;
@synthesize todaysMeetsBtn;
@synthesize appdelegate;

- (void)viewDidLoad
{
    appdelegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appdelegate) {
        [appdelegate.sharedContactModelManager registerObserverForAllContacts:self];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshView:)
                                                 name:ApplicationDidFinishContactSyncing
                                               object:nil];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    todaysMeetsBtn.tag = 500;// not Pressed
    contactSearchBar.delegate = self;
    [contactSearchBar setShowsScopeBar:NO];
    [contactSearchBar sizeToFit];
    
    // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + contactSearchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
    
    [appdelegate.sharedContactModelManager sortdataSourcewithoutTodaysMeetFirst];
    @synchronized(self) {
        _contactModelDataSource = appdelegate.sharedContactModelManager.contactModelArray;
    }
    _contactModelDataSourceReferences = _contactModelDataSource;
    
    _todayMeetContactModelDataSource = [[NSMutableArray alloc] init];
    [self fillTodaysMeetContactModelDatasource];
    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
//    [tempImageView setFrame:self.tableView.frame];
    
//    self.contactTableView.backgroundView = tempImageView;
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor blackColor];
    titleView.shadowOffset = CGSizeMake(0.0f, -1.0f);
    titleView.textColor = [UIColor colorWithRed:0.9216 green:0.7020 blue:0.2353 alpha:1.00]; // Your color here
    titleView.text = @"Contacts";
    self.navigationItem.titleView = titleView
    ;
    [titleView sizeToFit];
    
    UIView *view = [[UIView alloc] init];
    self.contactTableView.tableFooterView = view;
}

-(void) fillTodaysMeetContactModelDatasource    {
    if(_todayMeetContactModelDataSource)    {
        [_todayMeetContactModelDataSource removeAllObjects];
    }
    
    if(_todayMeetContactModelDataSource)    {
        @synchronized(self) {
            for (__weak IMIContactModel* lconatcModel in  appdelegate.sharedContactModelManager.contactModelArray) {
                if(lconatcModel.todaysUpcommingMeets > 0)
                    [_todayMeetContactModelDataSource addObject:lconatcModel];
                
                lconatcModel = NULL;
            }
        }
    }
}

-(void) dealloc {
    if(appdelegate)
        [appdelegate.sharedContactModelManager removeObserverForAllContacts:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    appdelegate = NULL;
    _contactModelDataSource = NULL;
    _filteredcontactModelDataSource = NULL;
    _todayMeetContactModelDataSource = NULL;
    contactSearchBar = NULL;
    _contactModelDataSourceReferences = NULL;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"todaysUpcommingMeets"])
    {
    }
    else if ([keyPath isEqual:@"futureMeetsExcludingTodaysMeets"])
    {
//        id newValue = change[NSKeyValueChangeNewKey];
//        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//        NSLog(@"The keyPath %@ changed from %@ to %@", keyPath, oldValue, newValue);
    }
    
    if(todaysMeetsBtn.tag == 501)   {
        [appdelegate.sharedContactModelManager sortdataSourcewithTodaysMeetFirst];
    }
    else    {
        [appdelegate.sharedContactModelManager sortdataSourcewithoutTodaysMeetFirst];        
    }
    [self fillTodaysMeetContactModelDatasource];
    [self.contactTableView reloadData];
}

-(IBAction)todaysMeetsBtnPressed:(id)sender {
    // temp code
//   IMIAppDelegate* appdelegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
//   IMIContactModel* contact = [appdelegate.sharedContactModelManager.contactModelArray objectAtIndex:1];
//   contact.todaysUpcommingMeets = 2;
//   contact.futureMeetsExcludingTodaysMeets = 4;
    ///////////////
    
    if(todaysMeetsBtn.tag == 500)   {
        todaysMeetsBtn.tag = 501;
        [todaysMeetsBtn setImage:[UIImage imageNamed:@"Today'sMeetBarIconSelect.png"] forState:UIControlStateNormal];
         _contactModelDataSourceReferences = _todayMeetContactModelDataSource;
    }
    else if(todaysMeetsBtn.tag == 501)  {
        _contactModelDataSourceReferences = _contactModelDataSource;
        todaysMeetsBtn.tag = 500;
        [todaysMeetsBtn setImage:[UIImage imageNamed:@"Today'sMeetBarIcon.png"] forState:UIControlStateNormal];
    }
    [self.contactTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated    {
    @synchronized(self) {
        self._filteredcontactModelDataSource = [NSMutableArray arrayWithCapacity:[_contactModelDataSource count]];
    }
    
    if(todaysMeetsBtn.tag == 500)   {
        _contactModelDataSourceReferences = _contactModelDataSource;
    }
    else if(todaysMeetsBtn.tag == 501)  {
        _contactModelDataSourceReferences = _todayMeetContactModelDataSource;
    }
        // reload the table view
    
    //[self]
    self.searchDisplayController.searchBar.hidden = NO;
    [self.searchDisplayController setActive:NO animated:NO];
    self.searchDisplayController.searchResultsTableView.hidden=NO;
    [self.contactTableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated  {
    self._filteredcontactModelDataSource = NULL;
}


-(void)viewDidAppear:(BOOL)animated {
}

#pragma mark IMIContactModelManager Notification Handler
- (void)RefreshView:(NSNotification *)notification {
    
    @autoreleasepool {
        [self performSelector:@selector(reloadContactTableView:)
                   withObject:notification
                   afterDelay:0.0f];
    }
}

-(void)reloadContactTableView:(NSNotification *)notification   {
    [self.contactTableView reloadData];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)   {
        
        if([self._filteredcontactModelDataSource count] <= 0)
            return 1;
        
        return [self._filteredcontactModelDataSource count];
    }
    else    {
        if([self._contactModelDataSourceReferences count] <= 0)
            return 1;
        
        return [self._contactModelDataSourceReferences count];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *CellIdentifier = @"Cel";
    PKGCell *aCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (aCell == nil)   {
		// Make the Display Picker and Create New Contact rows look like buttons
        
        aCell = [[PKGCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //        aCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
	aCell.tag = indexPath.row;

    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        if([self._filteredcontactModelDataSource count] <= 0)   {
            [aCell initializeTableCellName:@"No Contact..." Detail:@"" image:nil bedgeText:@"NO" badgeImage:NULL];
            [aCell setUserInteractionEnabled:NO];
            [aCell setAccessoryType:UITableViewCellAccessoryNone];
            return aCell;
        }
    }
	else
	{
        if([self._contactModelDataSourceReferences count] <= 0)   {
            [aCell initializeTableCellName:@"No Contact..." Detail:@"" image:nil bedgeText:@"NO" badgeImage:NULL];
             [aCell setUserInteractionEnabled:NO];
            [aCell setAccessoryType:UITableViewCellAccessoryNone];
            return aCell;
        }
    }
    
    __weak IMIContactModel* contactModel = NULL;
    [aCell setUserInteractionEnabled:YES];
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        contactModel = [_filteredcontactModelDataSource objectAtIndex:indexPath.row];
    }
	else
	{
        @synchronized(self) {
             contactModel = [_contactModelDataSourceReferences objectAtIndex:indexPath.row];
        }
    }
    int numberofMeets = [contactModel.allMeets count];
    int allfutureMeetsCount = contactModel.todaysUpcommingMeets + contactModel.futureMeetsExcludingTodaysMeets;
    
    if(numberofMeets > 0) {
        if(allfutureMeetsCount > 0) {
            
            if(contactModel.todaysUpcommingMeets > 0)
                [aCell initializeTableCellName:[appdelegate.sharedContactModelManager getFullName:contactModel.personRef] Detail:@"Business Meet" image:[UIImage imageNamed:@"greenf.png"]bedgeText:[NSString stringWithFormat:@"%d", allfutureMeetsCount] badgeImage:[UIImage imageNamed:@"greenBadge.png"]];
            else
                [aCell initializeTableCellName:[appdelegate.sharedContactModelManager getFullName:contactModel.personRef] Detail:@"Business Meet" image:[UIImage imageNamed:@"redf.png"]bedgeText:[NSString stringWithFormat:@"%d", allfutureMeetsCount] badgeImage:[UIImage imageNamed:@"redBadge.png"]];
        }
        else
            [aCell initializeTableCellName:[appdelegate.sharedContactModelManager getFullName:contactModel.personRef] Detail:@"Business Meet" image:[UIImage imageNamed:@"grayf.png"]bedgeText:[NSString stringWithFormat:@"%d", numberofMeets] badgeImage:[UIImage imageNamed:@"grayBadge.png"]];
    }
    else    {
        [aCell initializeTableCellName:[appdelegate.sharedContactModelManager getFullName:contactModel.personRef] Detail:@"Business Meet" image:[UIImage imageNamed:@"bluef.png"]bedgeText:@"NO" badgeImage:NULL];
    }
    contactModel = NULL;
    [aCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	return aCell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"Detail"]) {
        IMIDetailViewController *vc = [segue destinationViewController];
        IMIContactModel* contact = NULL;
        
        if(sender == self.searchDisplayController.searchResultsTableView || self.searchDisplayController.active) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            contact = (IMIContactModel*)[_filteredcontactModelDataSource objectAtIndex:[indexPath row]];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            @synchronized(self) {
                 contact =(IMIContactModel*)[_contactModelDataSourceReferences objectAtIndex:[indexPath row]];
            }
        }
        
        [vc setContactModel:contact];
        [vc setIsComeFromMap:NO];
        self.searchDisplayController.searchResultsTableView.hidden=YES;
        [self.contactSearchBar resignFirstResponder];
        contact = NULL;
        vc = NULL;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [self performSegueWithIdentifier:@"Detail" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark TableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
	// Change the height if Edit Unknown Contact is the row selected
	return 60;
}


#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *namePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
        IMIContactModel* contact = (IMIContactModel*)obj;
        
        NSString* name = [appdelegate.sharedContactModelManager getFullName:contact.personRef];
        return (!([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location == NSNotFound));
    }];
    
	// Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
	[self._filteredcontactModelDataSource removeAllObjects];
    
	// Filter the array using NSPredicate
    @synchronized(self) {
        NSArray *tempArray = [_contactModelDataSourceReferences filteredArrayUsingPredicate:namePredicate];
        
        if([scope isEqualToString:@"Meets"]) {
            // Further filter the array with the scope
            NSPredicate *scopePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
                IMIContactModel* contact = (IMIContactModel*)obj;
                return ([contact.allMeets count] > 0);
            }];
            tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
        }
        [_filteredcontactModelDataSource setArray:tempArray];
        tempArray = NULL;
    }
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString   {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Search Button
- (IBAction)goToSearch:(id)sender   {
    // If you're worried that your users might not catch on to the fact that a search bar is available if they scroll to reveal it, a search icon will help them
    // Note that if you didn't hide your search bar, you should probably not include this, as it would be redundant
    //[self.searchDisplayController setActive:YES animated:YES];
    //
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    [contactSearchBar becomeFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar   {
//    [contactSearchBar setShowsScopeBar:NO];
//    [contactSearchBar sizeToFit];
   // self.searchDisplayController.searchResultsTableView.hidden=YES;
    [self.contactSearchBar resignFirstResponder];
    
    // Hide the search bar until user scrolls up
//    CGRect newBounds = [[self tableView] bounds];
//    newBounds.origin.y = newBounds.origin.y + contactSearchBar.bounds.size.height;
//    [[self tableView] setBounds:newBounds];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar    {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar   {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end