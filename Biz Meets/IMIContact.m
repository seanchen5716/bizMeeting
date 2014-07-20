//
//  IMIContact.m
//  YO MAP
//
//  Created by imicreation on 01/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIContact.h"

@implementation IMIContact

@synthesize name;
@synthesize personRef;
@synthesize refId;
@synthesize numberOfMeets;
@synthesize havingTodaysMeet;

+(id)personWithName:(NSString*)lname personId:(ABRecordID)lrefId personRecordRef:(ABRecordRef)lpersonRef numberOfMeets:(int)lnumberOfMeets havingTodaysMeet:(BOOL)lhavingTodaysMeet {

    IMIContact* newContact = [[self alloc]init];
    [newContact setName:lname];
    [newContact setRefId:lrefId];
    [newContact setPersonRef:lpersonRef];
    [newContact setNumberOfMeets:lnumberOfMeets];
    [newContact setHavingTodaysMeet:lhavingTodaysMeet];
    
    return newContact;
}

-(void)dealloc  {
    name = NULL;
    if(personRef)
        CFRelease(personRef);
}

@end
