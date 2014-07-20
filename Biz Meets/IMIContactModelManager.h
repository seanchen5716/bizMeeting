//
//  IMIContactModelManager.h
//  YO MAP
//
//  Created by imicreation on 09/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "IMIContactModel.h"
#import "IMIContactModelManager.h"

typedef void (^BooleanClosure)(BOOL iFlag);
extern NSString * ApplicationDidFinishContactSyncing;

@protocol IMIContactModelManagerDelegate;	

@interface IMIContactModelManager : NSObject    {
    id <IMIContactModelManagerDelegate, UIAlertViewDelegate> modelDelegate;
    
    NSMutableArray* contactModelArray;
    NSMutableArray* registeredController;
}
@property(nonatomic, retain)  NSMutableArray* registeredController;
@property(nonatomic, retain)  NSMutableArray* contactModelArray;
@property (nonatomic, retain) id <IMIContactModelManagerDelegate> modelDelegate;

- (void)initManagerOnCompletion:(BooleanClosure)iCompletion ;

-(void)registerObserverForAllContacts:(UIViewController*)controller;
-(void)removeObserverForAllContacts:(UIViewController*)controller;

-(void)sortdataSourcewithTodaysMeetFirst;
-(void)sortdataSourcewithoutTodaysMeetFirst;

-(NSString*)getFullName:(ABRecordRef) person;
-(NSString*)getOrgenizationName:(ABRecordRef) person;
-(NSString*)getMobileName:(ABRecordRef) person;
-(NSString*)getEmail:(ABRecordRef) person;
-(NSMutableDictionary*)getAddress:(ABRecordRef) person;
-(NSMutableString*)getAddressString:(ABRecordRef) person;
-(UIImage*)getContactImage:(ABRecordRef) person;

-(BOOL) saveMeet:(NSMutableDictionary*)meetInfo;
- (BOOL) updateRecordWithMeetInfo:(NSDictionary*)meetInfo;
-(BOOL)DeleteMeetWithMeetId:(long long int)meetId :(IMIContactModel*)contact ;
-(BOOL) havingMeetWithFutureDate:(NSString*) date  ;

-(void)checkForContactSettings;
@end

@protocol IMIContactModelManagerDelegate 

-(void) IMIContactModelManager:(IMIContactModelManager *) manager refreshView:(BOOL)status;

@end