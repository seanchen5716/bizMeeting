//
//  IMIContactModel.h
//  YO MAP
//
//  Created by imicreation on 08/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface IMIContactModel : NSObject   {
    
    ABRecordRef personRef;
    NSMutableArray* allMeets;
    NSMutableArray* futureMeetDates;
    long long int todaysUpcommingMeets;
    long long int futureMeetsExcludingTodaysMeets;
}

@property (atomic, assign) long long int futureMeetsExcludingTodaysMeets;
@property (atomic, assign) long long int todaysUpcommingMeets;
@property (atomic, assign) ABRecordRef personRef;
@property (atomic, retain) NSMutableArray* allMeets;
@property (atomic, retain) NSMutableArray* allMeetDates;
@property (atomic, retain) NSMutableArray* futureMeetDates;


+(id)contactWithPersonRecordRef:(ABRecordRef)lpersonRef;

-(ABRecordID)getRecordId;
-(void)deleteContact;
-(void)refreshContact;
-(NSMutableArray*)getallMeetIds;


@end