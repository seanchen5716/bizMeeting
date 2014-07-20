//
//  IMIContact.h
//  YO MAP
//
//  Created by imicreation on 01/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface IMIContact : NSObject    {
    
    NSString *name;
    ABRecordID refId;
    ABRecordRef personRef;
    int numberOfMeets;
    BOOL havingTodaysMeet;// having todays date
    
    
}
@property (assign) BOOL havingTodaysMeet;
@property (assign) int numberOfMeets;
@property (assign) ABRecordID refId;
@property (nonatomic, copy) NSString *name;
@property (assign) ABRecordRef personRef;

+(id)personWithName:(NSString*)lname personId:(ABRecordID)lrefId personRecordRef:(ABRecordRef)lpersonRef numberOfMeets:(int)lnumberOfMeets havingTodaysMeet:(BOOL)lhavingTodaysMeet;

@end
