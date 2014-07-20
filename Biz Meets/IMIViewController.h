//
//  IMIViewController.h
//  YO MAP
//
//  Created by imicreation on 18/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMIContactModelManager.h"

@interface IMIViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>{
    
    __weak IBOutlet UITableView* contactTableView;
    __weak IBOutlet UIButton* todaysMeetsBtn;
    
}
@property(nonatomic, weak) IBOutlet UIButton* todaysMeetsBtn;
@property(nonatomic, weak) IBOutlet UITableView* contactTableView;
@property IBOutlet UISearchBar *contactSearchBar;

- (IBAction)goToSearch:(id)sender;
-(IBAction)todaysMeetsBtnPressed:(id)sender;
@end
