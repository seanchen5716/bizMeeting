    //
//  IMIContactModelManager.m
//  YO MAP
//
//  Created by imicreation on 09/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIContactModelManager.h"
#import "IMIContactModel.h"
#import <AddressBookUI/AddressBookUI.h>
#import "DataBase.h"
#import "IMIAppDelegate.h"
#import "LoadingView.h"

typedef BOOL (^SignalClosure)(IMIContactModel *iData);

NSString *ApplicationDidFinishContactSyncing = @"ApplicationDidFinishContactSyncing";

@interface  IMIContactModelManager  ()

@property(nonatomic, assign) ABAddressBookRef addressBookRef;
-(void)getCABAccessOnCompletion:(BooleanClosure)iCompletion;
@end

@implementation IMIContactModelManager
@synthesize modelDelegate;
@synthesize contactModelArray;
@synthesize registeredController;
@synthesize addressBookRef;

- (void)initManagerOnCompletion:(BooleanClosure)iCompletion {
    
    if(self) {
        self.contactModelArray = [[NSMutableArray alloc] init];
        self.registeredController = [[NSMutableArray alloc] init];
        
        addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookChanged, (__bridge void *) self);

        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                
                [self getCABAccessOnCompletion:^(BOOL iFlag){
                    iCompletion(iFlag);
                }];
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self getCABAccessOnCompletion:^(BOOL iFlag){
                iCompletion(iFlag);
            }];
        }
        else    {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
            __weak IMIAppDelegate* delegate =(IMIAppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate showAlertWithTitle:@"Alert!" withMessage:@"Change contact privacy setting in settings app" cancelBtnTitle:@"OK" otherBtnTitle:nil delegate:self];
        }
    }
}
 
-(void)checkForContactSettings  {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
    }
    else    {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        __weak IMIAppDelegate* delegate =(IMIAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate showAlertWithTitle:@"Alert!" withMessage:@"Change contact privacy setting in settings app" cancelBtnTitle:@"OK" otherBtnTitle:nil delegate:self];
    }
}

-(void)registerObserverForAllContacts:(UIViewController*)controller   {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            for(IMIContactModel* contact in self.contactModelArray)    {
                if(!self.registeredController)
                    self.registeredController = [[NSMutableArray alloc] init];
                
                [self.registeredController addObject:controller];
                
                [contact addObserver:controller forKeyPath:@"todaysUpcommingMeets" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
                [contact addObserver:controller forKeyPath:@"futureMeetsExcludingTodaysMeets" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
            }
        }
    });
}

-(void)removeObserverForAllContacts:(UIViewController*)controller   {
    @synchronized(self) {
        for(IMIContactModel* contact in self.contactModelArray)    {
            [contact removeObserver:controller forKeyPath:@"todaysUpcommingMeets"];
            [contact removeObserver:controller forKeyPath:@"futureMeetsExcludingTodaysMeets"];
        }
    }

    if([self.registeredController containsObject:controller])
        [self.registeredController removeObject:controller];
}

-(void)dealloc  {
    if(addressBookRef)
        CFRelease(addressBookRef);
}

-(void)newContactModel:(ABRecordRef) contactRef OnCompletion:(SignalClosure)iCompletion{
    CFRetain(contactRef);
    IMIContactModel* __block contact = NULL;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        // Some asynchronous work
         contact = [IMIContactModel contactWithPersonRecordRef:contactRef];
    });
    
    // Do some other work while the tasks execute.
    
    // When you cannot make any more forward progress,
    // wait on the group to block the current thread.
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    CFRelease(contactRef);
    iCompletion(contact);
    contact = NULL;
}

-(void)fillContactModelArray:(CFArrayRef) contactArray OnCompletion:(BooleanClosure)iCompletion  {

    CFRetain(contactArray);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        int numberofContact = (int)CFArrayGetCount(contactArray);
        for (int count = 0; count < numberofContact; count++) {
            ABRecordRef person = CFArrayGetValueAtIndex(contactArray, count);
            CFRetain(person);
            [self newContactModel:person OnCompletion:^BOOL(IMIContactModel *iData) {
                @synchronized(self) {
                    [self.contactModelArray addObject:iData];
                }
                CFRelease(person);
                return YES;
            }];
        }
    });
    
    // Do some other work while the tasks execute.
    // When you cannot make any more forward progress,
    // wait on the group to block the current thread.
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    CFRelease(contactArray);
    iCompletion(YES);
}

-(void)getCABAccessOnCompletion:(BooleanClosure)iCompletion  {
    
    if(!addressBookRef) {
        addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookChanged, (__bridge void *) self);
    }
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            CFArrayRef _array = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            [self fillContactModelArray:_array OnCompletion:^(BOOL iFlag){
                CFRelease(_array);
                iCompletion(iFlag);
            }];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        CFArrayRef _array = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        [self fillContactModelArray:_array OnCompletion:^(BOOL iFlag){
            CFRelease(_array);
            iCompletion(iFlag);
        }];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    
    IMIAppDelegate* delegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(delegate.numberOfCallbacks == 1) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[cont addProgressView];
            UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
            LoadingView * loadingView = [LoadingView loadingViewInView:mainWindow];
            
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [loadingView removeView];
            });
        }); 

        delegate.numberOfCallbacks++;
        
        IMIContactModelManager* cont = (__bridge  IMIContactModelManager*)context;
        NSLog(@"in MyAddressBook External Change Callback");
        
        addressBook =  ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFArrayRef peopleRefs = ABAddressBookCopyArrayOfAllPeopleInSource(addressBook, kABSourceTypeLocal);
        
        CFIndex count = CFArrayGetCount(peopleRefs);
        NSMutableArray* newContactArray = [[NSMutableArray alloc] init];
        NSMutableArray* contactsTobeDeleted = [[NSMutableArray alloc] init];
        
        @synchronized(cont) {
            for(int counter = 0; counter< [cont.contactModelArray count]; counter++)  {
                IMIContactModel* model = [cont.contactModelArray objectAtIndex:counter];
                ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, [model getRecordId]);
                
                if(ref) {
                    model.personRef = ref;
                    model = NULL;
                }
                if(!ref)    {
                    [contactsTobeDeleted addObject:@(counter)];
                }
                model = NULL;
            }
        }
        
        // update the contact and check for deleted record
        
        // delete the contact
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
        
        @synchronized(cont) {
            for(int i =0; i<[contactsTobeDeleted count]; i++)   {
                // delete all the meetings and then delete this contact from array
                // delete all meetings associated with it
                IMIContactModel* model = [cont.contactModelArray objectAtIndex:[[contactsTobeDeleted objectAtIndex:i] integerValue]];
                
                NSMutableArray* meetIds = [model getallMeetIds];
                
                for (int j=0; j<[meetIds count]; j++) {
                    
                    BOOL status = [cont DeleteMeetWithMeetId:[[meetIds objectAtIndex:j] integerValue] :model];
                    
                    if(!status) {
                        __weak IMIAppDelegate* delegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
                        NSString* msg = [NSString stringWithFormat:@"Could not delete meets for record to be delete name %@ and id: %d", [cont getFullName:model.personRef], [model getRecordId]];
                        [delegate showAlertWithTitle:@"Error!" withMessage:msg cancelBtnTitle:@"OK"];
                        break;
                    }
                }
                [indexes addIndex:[[contactsTobeDeleted objectAtIndex:i] integerValue]];
            }
        }
        
        @synchronized(cont) {
            [cont.contactModelArray removeObjectsAtIndexes:indexes];
        }
        
        // check and insert new records
        for(CFIndex i=0; i < count; i++)    {
            ABRecordRef ref = CFArrayGetValueAtIndex(peopleRefs, i);
            ABRecordID id_ = ABRecordGetRecordID(ref);
           // NSLog(@"ref: %li = name: %@ and id: %d mobile no: %@",i, [cont getFullName:ref], id_, [cont getMobileName:ref]);
            BOOL isAlreadyExist = NO;
            
            @synchronized(cont) {
                for(int counter = 0; counter < [cont.contactModelArray count];counter++ )    {
                    IMIContactModel* model = [cont.contactModelArray objectAtIndex:counter];
                    // NSLog(@"ref: %i = name: %@ and id: %d",counter, [cont getFullName:model.personRef], [model getRecordId]);
                    ABRecordID existId =  [model getRecordId];
                    if(id_ == existId)  {
                        isAlreadyExist = YES;
                        break;
                    }
                }
            }
            
            if(!isAlreadyExist) {
                [cont newContactModel:ref OnCompletion:^BOOL(IMIContactModel *iData) {
                    @synchronized(cont) {
                        [cont.contactModelArray addObject:iData];
                    }
                    return YES;
                }];
            }
        }
        
        @synchronized(cont) {
            [cont.contactModelArray addObjectsFromArray:newContactArray];
        }
        
        [newContactArray removeAllObjects];
        newContactArray = NULL;
        
        CFRelease(peopleRefs);
        //[cont.modelDelegate IMIContactModelManager:cont refreshView:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationDidFinishContactSyncing object:cont];
    }
    delegate = NULL;
}


-(IMIContactModel*)recordReferenceWithRecordID:(ABRecordID)recordId  {
    
    @synchronized(self) {
        for (IMIContactModel* contact in self.contactModelArray)    {
            if(contact.personRef)
                if(ABRecordGetRecordID(contact.personRef) == recordId)
                    return contact;
        }
    }
    return NULL;
}

// Database update mathods

-(BOOL) saveMeet:(NSMutableDictionary*)meetInfo {
    
    BOOL status = [[DataBase database] saveMeet:meetInfo];
    
    if(status)  {
        IMIContactModel* contact = [self recordReferenceWithRecordID:(int)[[meetInfo objectForKey:@"PersonId"] integerValue]];
        [contact refreshContact];
        return YES;
    }
    return NO;
}

- (BOOL) updateRecordWithMeetInfo:(NSDictionary*)meetInfo   {
    
    BOOL status = [[DataBase database] updateRecordWithMeetInfo:meetInfo];
    if(status)  {
        IMIContactModel* contact = [self recordReferenceWithRecordID:(int)[[meetInfo objectForKey:@"PersonId"] integerValue]];
        [contact refreshContact];
        return YES;
    }
    return NO;
}

-(BOOL)DeleteMeetWithMeetId:(long long int)meetId :(IMIContactModel*)contact  {
    
    BOOL status = [[DataBase database] DeleteMeetWithMeetId:meetId];
    if(status)  {
        if(contact)
            [contact refreshContact];
        
        return YES;
    }
    return NO;
}

-(BOOL) havingMeetWithFutureDate:(NSString*) date   {
    BOOL status = [[DataBase database] havingMeetWithFutureDate:date];
    return status;
}

#pragma Mathods to sort the contact model array
-(void)sortdataSourcewithTodaysMeetFirst {
    
    @synchronized(self) {
        NSPredicate *todaysMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            int futuremeets1 =(int)contact.todaysUpcommingMeets;
            return (futuremeets1 > 0);
        }];
        NSArray *todaysMeetArray = [self.contactModelArray filteredArrayUsingPredicate:todaysMeetsPredicate];
        
        
        NSPredicate *futureMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            int futuremeets1 = (int)contact.futureMeetsExcludingTodaysMeets;
            return (futuremeets1 > 0 && contact.todaysUpcommingMeets <= 0);
        }];
        NSArray *futureMeetArray = [self.contactModelArray filteredArrayUsingPredicate:futureMeetsPredicate];
        
        NSPredicate *allPastMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            int futuremeets = (int)contact.futureMeetsExcludingTodaysMeets + (int)contact.todaysUpcommingMeets;
            return ([contact.allMeets count] > 0 && futuremeets <= 0);
        }];
        NSArray *pastMeetArray = [self.contactModelArray filteredArrayUsingPredicate:allPastMeetsPredicate];
        
        NSPredicate *noMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            return ([contact.allMeets count] <= 0);
        }];
        NSArray *noMeetArray = [self.contactModelArray filteredArrayUsingPredicate:noMeetsPredicate];
        
        NSArray *localTodaysMeetArray = [todaysMeetArray sortedArrayUsingComparator:^(id contact1, id contact2){
            
            if ([contact1 isKindOfClass:[IMIContactModel class]] && [contact2 isKindOfClass:[IMIContactModel class]]) {
                IMIContactModel *c1 = contact1;
                IMIContactModel *c2 = contact2;
                int futuremeets1 = (int)c1.todaysUpcommingMeets;
                int futuremeets2 = (int)c2.todaysUpcommingMeets;
                if(futuremeets1 > futuremeets2)
                    return (NSComparisonResult)NSOrderedDescending;
                else if(futuremeets1 < futuremeets2)
                    return (NSComparisonResult)NSOrderedAscending;
            }
            // TODO: default is the same?
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSArray *localFutureMeetArray = [futureMeetArray sortedArrayUsingComparator:^(id contact1, id contact2){
            
            if ([contact1 isKindOfClass:[IMIContactModel class]] && [contact2 isKindOfClass:[IMIContactModel class]]) {
                IMIContactModel *c1 = contact1;
                IMIContactModel *c2 = contact2;
                int futuremeets1 = (int)c1.futureMeetsExcludingTodaysMeets;
                int futuremeets2 = (int)c2.futureMeetsExcludingTodaysMeets;
                if(futuremeets1 > futuremeets2)
                    return (NSComparisonResult)NSOrderedDescending;
                else if(futuremeets1 < futuremeets2)
                    return (NSComparisonResult)NSOrderedAscending;
            }
            // TODO: default is the same?
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSArray *localPastMeetArray = [pastMeetArray sortedArrayUsingComparator:^(id contact1, id contact2){
            
            if ([contact1 isKindOfClass:[IMIContactModel class]] && [contact2 isKindOfClass:[IMIContactModel class]]) {
                IMIContactModel *c1 = contact1;
                IMIContactModel *c2 = contact2;
                int pastmeets1 = (int)[c1.allMeets count];
                int pastmeets2 = (int)[c2.allMeets count];;
                
                
                if(pastmeets1 > pastmeets2)
                    return (NSComparisonResult)NSOrderedDescending;
                else if(pastmeets1 < pastmeets2)
                    return (NSComparisonResult)NSOrderedAscending;
            }
            // TODO: default is the same?
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [self.contactModelArray removeAllObjects];
        [self.contactModelArray addObjectsFromArray:localTodaysMeetArray];
        [self.contactModelArray addObjectsFromArray:localFutureMeetArray];
        [self.contactModelArray addObjectsFromArray:localPastMeetArray];
        [self.contactModelArray addObjectsFromArray:noMeetArray];
        
        todaysMeetsPredicate = NULL;
        todaysMeetArray = NULL;
        futureMeetsPredicate = NULL;
        futureMeetArray = NULL;
        allPastMeetsPredicate = NULL;
        pastMeetArray = NULL;
        noMeetsPredicate = NULL;
        noMeetArray = NULL;
        localFutureMeetArray = NULL;
        localPastMeetArray = NULL;
    }
}

-(void)sortdataSourcewithoutTodaysMeetFirst {
    
    @synchronized(self) {
        NSPredicate *futureMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            int futuremeets1 = (int)contact.futureMeetsExcludingTodaysMeets + (int)contact.todaysUpcommingMeets;
            return (futuremeets1 > 0);
        }];
        NSArray *futureMeetArray = [self.contactModelArray filteredArrayUsingPredicate:futureMeetsPredicate];
        
        NSPredicate *allPastMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            int futuremeets = (int)contact.futureMeetsExcludingTodaysMeets + (int)contact.todaysUpcommingMeets;
            return ([contact.allMeets count] > 0 && futuremeets <= 0);
        }];
        NSArray *pastMeetArray = [self.contactModelArray filteredArrayUsingPredicate:allPastMeetsPredicate];
        
        NSPredicate *noMeetsPredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind){
            IMIContactModel* contact = (IMIContactModel*)obj;
            return ([contact.allMeets count] <= 0);
        }];
        NSArray *noMeetArray = [self.contactModelArray filteredArrayUsingPredicate:noMeetsPredicate];
        
        NSArray *localFutureMeetArray = [futureMeetArray sortedArrayUsingComparator:^(id contact1, id contact2){
            
            if ([contact1 isKindOfClass:[IMIContactModel class]] && [contact2 isKindOfClass:[IMIContactModel class]]) {
                IMIContactModel *c1 = contact1;
                IMIContactModel *c2 = contact2;
                int futuremeets1 = (int)c1.futureMeetsExcludingTodaysMeets + (int)c1.todaysUpcommingMeets;
                int futuremeets2 = (int)c2.futureMeetsExcludingTodaysMeets + (int)c2.todaysUpcommingMeets;
                if(futuremeets1 > futuremeets2)
                    return (NSComparisonResult)NSOrderedDescending;
                else if(futuremeets1 < futuremeets2)
                    return (NSComparisonResult)NSOrderedAscending;
            }
            // TODO: default is the same?
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSArray *localPastMeetArray = [pastMeetArray sortedArrayUsingComparator:^(id contact1, id contact2){
            
            if ([contact1 isKindOfClass:[IMIContactModel class]] && [contact2 isKindOfClass:[IMIContactModel class]]) {
                IMIContactModel *c1 = contact1;
                IMIContactModel *c2 = contact2;
                int pastmeets1 = (int)[c1.allMeets count];
                int pastmeets2 = (int)[c2.allMeets count];;
                
                
                if(pastmeets1 > pastmeets2)
                    return (NSComparisonResult)NSOrderedDescending;
                else if(pastmeets1 < pastmeets2)
                    return (NSComparisonResult)NSOrderedAscending;
            }
            // TODO: default is the same?
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [self.contactModelArray removeAllObjects];
        [self.contactModelArray addObjectsFromArray:localFutureMeetArray];
        [self.contactModelArray addObjectsFromArray:localPastMeetArray];
        [self.contactModelArray addObjectsFromArray:noMeetArray];
        
        futureMeetsPredicate = NULL;
        futureMeetArray = NULL;
        allPastMeetsPredicate = NULL;
        pastMeetArray = NULL;
        noMeetsPredicate = NULL;
        noMeetArray = NULL;
        localFutureMeetArray = NULL;
        localPastMeetArray = NULL;
    }
    
}

#pragma Getting the information from CAB

-(NSString*)getFullName:(ABRecordRef) person    {
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString* name =[[NSString alloc] initWithFormat:@"%@ %@",firstName?firstName:@"", lastName?lastName:@""];
    
    firstName = NULL;
    lastName = NULL;
    
    return name;
}

-(NSString*)getOrgenizationName:(ABRecordRef) person    {
    NSString* orgName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    return orgName;
}

-(NSString*)getMobileName:(ABRecordRef) person    {
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString* string = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phones, 0);
    CFRelease(phones);
    
    if(string)
        return string;
    else
        return @"Not Available...";
}

-(NSString*)getEmail:(ABRecordRef) person   {
    NSString* email = NULL;
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
        email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, j);
        if(email)   {
            break;
        }
    }
    CFRelease(emails);
    
    if(email)
        return email;
    else
       return @"Not Available...";
}

-(NSMutableDictionary*)getAddress:(ABRecordRef) person  {

    NSMutableDictionary* addressDict = [[NSMutableDictionary alloc] init];
    CFTypeRef adressesReference = ABRecordCopyValue((ABRecordRef)person, kABPersonAddressProperty);
    
    CFIndex mvCount = ABMultiValueGetCount(adressesReference);
    if (mvCount > 0) {
        for (int j=0; j < mvCount; j++) {
            NSDictionary *values = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(adressesReference, j);
            NSEnumerator *enumerator = [values keyEnumerator];
            id innerKey;
            
            while ((innerKey = [enumerator nextObject])) {
                /* code that uses the returned key */
                NSString *value = (NSString *)[values objectForKey: innerKey];
                CFStringRef innerKeyLabel = ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)innerKey);
                
                NSString* sKey = (__bridge_transfer NSString*)innerKeyLabel;
                
                if([sKey isEqualToString: @"Street"]) {
                    [addressDict setObject:value forKey:@"Street"];
                }
                else if([sKey isEqualToString: @"City"]) {
                     [addressDict setObject:value forKey:@"City"]; 
                }
                else if([sKey isEqualToString: @"State"]) {
                    [addressDict setObject:value forKey:@"State"];  
                }
                else  if([sKey isEqualToString: @"Country"]) {
                    [addressDict setObject:value forKey:@"Country"];
                }
                else if([sKey isEqualToString: @"ZIP"]) {
                    [addressDict setObject:value forKey:@"ZIP"];  
                }
                value = NULL;
                sKey = NULL;
            }
            
            values = NULL;
            enumerator = NULL;
            innerKey = NULL;
        }
    }
    CFRelease(adressesReference);
    return addressDict;
}

-(NSMutableString*)getAddressString:(ABRecordRef) person    {
    
    NSMutableDictionary* addressDict = [self getAddress:person];
    NSMutableString* addressString = [[NSMutableString alloc] initWithFormat:@""];
    int mvCount = (int)[addressDict count];
    if (mvCount > 0)    {
        NSArray* keys = [addressDict allKeys];
        
        if([keys containsObject:@"Street"])  {
            [addressString appendString:[NSString stringWithFormat:@"%@", (NSString *)[addressDict objectForKey: @"Street"]]];
        }
        if([keys containsObject:@"City"])  {
            [addressString appendString:[NSString stringWithFormat:@" %@", (NSString *)[addressDict objectForKey: @"City"]]];
        }
        if([keys containsObject:@"State"])  {
            [addressString appendString:[NSString stringWithFormat:@" %@", (NSString *)[addressDict objectForKey: @"State"]]];
        }
        if([keys containsObject:@"ZIP"])  {
            [addressString appendString:[NSString stringWithFormat:@" %@", (NSString *)[addressDict objectForKey: @"ZIP"]]];
        }
        if([keys containsObject:@"Country"])  {
            [addressString appendString:[NSString stringWithFormat:@" %@", (NSString *)[addressDict objectForKey: @"Country"]]];
        }
        keys = NULL;
    }
    else    {
        [addressString appendFormat:@"Not Valid"];
    }
    addressDict = NULL;
    return addressString;
}

-(UIImage*)getContactImage:(ABRecordRef) person  {
    if(person)  {
        NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(person);
        UIImage  *img = [UIImage imageWithData:imgData];
        imgData = NULL;
        
        if(img)
            return img;
        else
            return [UIImage imageNamed:@"Default Photo.png"];
    }
    return NULL;
}
@end