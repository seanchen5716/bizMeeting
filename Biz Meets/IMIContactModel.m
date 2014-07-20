//
//  IMIContactModel.m
//  YO MAP
//
//  Created by imicreation on 08/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIContactModel.h"
#import "DataBase.h"

@interface IMIContactModel ()

@property(nonatomic, retain) NSMutableArray* timerArray;

-(NSMutableArray*)getallMeets;
-(NSMutableArray*)getFutureMeetsDate:(NSMutableArray*) datesArray;
-(NSMutableArray*)getMeetsDate;

@end

@implementation IMIContactModel
@synthesize allMeets; // allmeets base object
@synthesize personRef; // person reference
@synthesize futureMeetDates; // contains all future meets currently not in use
@synthesize todaysUpcommingMeets; // number of todays upcomming meetings
@synthesize futureMeetsExcludingTodaysMeets; // number of future meets excluding todays
@synthesize allMeetDates; // all meets dates
@synthesize timerArray; // heving all timers that update the variables on fire date.

-(void)dealloc  {
    if(personRef)
        CFRelease(personRef);
    allMeetDates = NULL;
    allMeets = NULL;
    futureMeetDates = NULL;
    timerArray = NULL;
}

+(id)contactWithPersonRecordRef:(ABRecordRef)lpersonRef {
    IMIContactModel* newContact = [[IMIContactModel alloc] init];
    CFRetain(lpersonRef);
    [newContact setPersonRef:lpersonRef];
    
    
    newContact.allMeetDates = [[NSMutableArray alloc] init];
    newContact.allMeets = [[NSMutableArray alloc] init];
    newContact.timerArray = [[NSMutableArray alloc] init];
    
    [newContact setAllMeets:[newContact getallMeets]];
    [newContact setAllMeetDates:[newContact getMeetsDate]];
    [newContact setTimerArray:[newContact createTimersForFutureDates]];
    [newContact setFutureMeetDates: [newContact getFutureMeetsDate:newContact.allMeetDates]];
    
    [newContact setTodaysUpcommingMeets:[newContact todaysUpcommingMeetings:newContact.allMeetDates]];
    [newContact setFutureMeetsExcludingTodaysMeets:[newContact futureMeetsExcludingTodays:newContact.allMeetDates]];
    CFRelease(lpersonRef);
    return newContact;
}

-(void)deleteContact    {
    
    if(self.timerArray) {
        for(NSTimer* timer in self.timerArray)
            [timer invalidate];
        
        [self.timerArray removeAllObjects];
    }
    self.timerArray = NULL;

    if(self.allMeetDates)
        [self.allMeetDates removeAllObjects];
    self.allMeetDates = NULL;
    
    if(self.allMeets)
        [self.allMeets removeAllObjects];
    self.allMeets = NULL;
}

-(void)refreshContact    {
    if(self.allMeetDates)
        [self.allMeetDates removeAllObjects];
    else
        self.allMeetDates = [[NSMutableArray alloc] init];
   
    if(self.allMeets)
        [self.allMeets removeAllObjects];
    else
        self.allMeets = [[NSMutableArray alloc] init];

    if(self.timerArray) {
       
        for(NSTimer* timer in self.timerArray)
            [timer invalidate];
        
        [self.timerArray removeAllObjects];
    }
    else
        self.timerArray = [[NSMutableArray alloc] init];
    
    [self setAllMeets:[self getallMeets]];
    [self setAllMeetDates:[self getMeetsDate]];
    [self setTimerArray:[self createTimersForFutureDates]];
    [self setFutureMeetDates: [self getFutureMeetsDate:self.allMeetDates]];
    [self setTodaysUpcommingMeets:[self todaysUpcommingMeetings:self.allMeetDates]];
    [self setFutureMeetsExcludingTodaysMeets:[self futureMeetsExcludingTodays:self.allMeetDates]];
}

-(NSMutableArray*)createTimersForFutureDates    {
    
    // invalidate all timers before create new one
    
   NSMutableArray* ltimerArray = [[NSMutableArray alloc] init];       
    
    for(NSString*date in self.allMeetDates)   {
        
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        NSDate* latestDate = [dateTimeFormatter dateFromString:date];
        if([latestDate compare: [NSDate date]] == NSOrderedDescending ||[latestDate compare: [NSDate date]] == NSOrderedSame)   {
            
            NSTimer* timer = [[NSTimer alloc] initWithFireDate:latestDate interval:0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            [ltimerArray addObject:timer];
            timer = NULL;
        }
    }
    return ltimerArray;
}

- (void)timerFireMethod:(NSTimer*)theTimer  {
    // 1. invalidate the timer 2. remove it from timer array 3. refresh futureMeetDates todaysUpcommingMeets futureMeetsExcludingTodaysMeets
    
    [theTimer invalidate];
    if([timerArray containsObject:theTimer])
        [timerArray removeObject: theTimer];
    
    [self setTodaysUpcommingMeets:[self todaysUpcommingMeetings:self.allMeetDates]];
    [self setFutureMeetsExcludingTodaysMeets:[self futureMeetsExcludingTodays:self.allMeetDates]];
    [self sortMeets:self.allMeets];
    
    [self setFutureMeetDates: [self getFutureMeetsDate:self.allMeetDates]];
}

-(NSMutableArray*)getallMeets   {
    NSMutableArray* meetArray =(NSMutableArray*) [[DataBase database] readMeetsInfoforContactId:[self getRecordId]];
    [self sortMeets:meetArray];
    
    return meetArray;
}

-(NSMutableArray*)getallMeetIds {
    
    NSMutableArray* meetIds = [[NSMutableArray alloc] init];
    
    for(NSDictionary* meet in allMeets) {
        [meetIds addObject:[meet objectForKey:@"MeetId"]];
    }
    
    return meetIds;
}

- (ABRecordID)getRecordId    {
    if(self.personRef)
        return ABRecordGetRecordID(self.personRef);
    
    return -1;
}

-(NSMutableArray*)getMeetsDate    {
    
    NSMutableArray* allDates = [[NSMutableArray alloc]init];
    
    for (NSMutableDictionary* meet in self.allMeets) {
        
        [allDates addObject:[NSString stringWithFormat:@"%@",[meet objectForKey:@"Date"]]];
    }
    return allDates;
}

-(NSMutableArray*)getFutureMeetsDate:(NSMutableArray*) datesArray    {
    NSMutableArray* allFutureDates = [[NSMutableArray alloc]init];
    
    if([datesArray count]<=0)
        return allFutureDates;
    else    {
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        
        NSDate* latestDate = NULL;
        
        for(int counter = 0; counter < [datesArray count]; counter++)   {
            
            latestDate = [dateTimeFormatter dateFromString:(NSString*)[datesArray objectAtIndex:counter]];
            
            if([latestDate compare: [NSDate date]] == NSOrderedDescending )
                [allFutureDates addObject:[NSString stringWithFormat:@"%@",[dateTimeFormatter stringFromDate:latestDate]]];
        }
        return allFutureDates;
    }
    return allFutureDates;
}

-(long long int)todaysUpcommingMeetings:(NSMutableArray*) datesArray {
    
    long long int ltodaysUpcommingMeets = 0;
    
    if([datesArray count]<=0)
        return ltodaysUpcommingMeets;
    else    {
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        
        NSDate* latestDate = NULL;
        NSString* currentDate = [dateFormatter stringFromDate:[NSDate date]];
        
        for(int counter = 0; counter < [datesArray count]; counter++)   {
            
            latestDate = [dateTimeFormatter dateFromString:(NSString*)[datesArray objectAtIndex:counter]];
            
            NSString* datestr = [dateFormatter stringFromDate:latestDate];
            
            if([datestr isEqualToString:currentDate])   {
                
                if([latestDate compare: [NSDate date]] == NSOrderedDescending )
                    ltodaysUpcommingMeets++;
            }
        }
        return ltodaysUpcommingMeets;
    }
    return ltodaysUpcommingMeets;
}

-(long long int)futureMeetsExcludingTodays:(NSMutableArray*)datesArray  {
    
    long long int futureMeets = 0;
    
    if([datesArray count] <=0)
        return futureMeets;
    else    {
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        
        NSDate* latestDate = NULL;
        NSString* currentDate = [dateFormatter stringFromDate:[NSDate date]];
        
        for(int counter = 0; counter < [datesArray count]; counter++)   {
                        
            latestDate = [dateTimeFormatter dateFromString:(NSString*)[datesArray objectAtIndex:counter]];
            
            NSString* datestr = [dateFormatter stringFromDate:latestDate];
            
            if([latestDate compare: [NSDate date]] == NSOrderedDescending)   {
                
                  if(![datestr isEqualToString:currentDate])
                      futureMeets++;
            }
        }
        return futureMeets;
    }
    return futureMeets;
}


-(void)sortMeets:(NSMutableArray*)meets  {
    
    NSMutableArray* upcommingMeetsArray = [[NSMutableArray alloc] init];
    NSMutableArray* pastMeetsArray = [[NSMutableArray alloc] init];
    
    for(int counter = 0; counter< [meets count]; counter++) {
        NSMutableDictionary* meetInfo = [meets objectAtIndex:counter];
        NSString* meetDate = [NSString stringWithFormat:@"%@", [meetInfo objectForKey:@"Date"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        
        NSDate* meetScheduleDate = [dateFormatter dateFromString:meetDate];
        NSTimeInterval interval =  [meetScheduleDate timeIntervalSinceNow];
        [meetInfo setObject: [NSString stringWithFormat:@"%f",interval ] forKey:@"TimeIntervalSinceNow"];
        
        if(interval >=0)
            [upcommingMeetsArray addObject:meetInfo];
        else if(interval < 0)
            [pastMeetsArray addObject:meetInfo];
    }
    
    NSArray *localUpcommingSortedArray = [upcommingMeetsArray sortedArrayUsingComparator:^(id meet1, id meet2){
        
        if ([meet1 isKindOfClass:[NSMutableDictionary class]] && [meet2 isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *s1 = meet1;
            NSMutableDictionary *s2 = meet2;
            
            NSTimeInterval interval1 = [[s1 objectForKey:@"TimeIntervalSinceNow"] doubleValue];
            NSTimeInterval interval2 = [[s2 objectForKey:@"TimeIntervalSinceNow"] doubleValue];
            
            if(interval1 >= interval2)
                return (NSComparisonResult)NSOrderedDescending;
            else if(interval1 < interval2)
                return (NSComparisonResult)NSOrderedAscending;
        }
        
        // TODO: default is the same?
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSArray *localPastSortedArray = [pastMeetsArray sortedArrayUsingComparator:^(id meet1, id meet2){
        
        if ([meet1 isKindOfClass:[NSMutableDictionary class]] && [meet2 isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *s1 = meet1;
            NSMutableDictionary *s2 = meet2;
            
            NSTimeInterval interval1 = [[s1 objectForKey:@"TimeIntervalSinceNow"] doubleValue];
            NSTimeInterval interval2 = [[s2 objectForKey:@"TimeIntervalSinceNow"] doubleValue];
            
            if(interval1 >= interval2)
                return (NSComparisonResult)NSOrderedAscending;
            else if(interval1 < interval2)
                return (NSComparisonResult)NSOrderedDescending;
        }
        
        // TODO: default is the same?
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    [meets removeAllObjects];
    [meets addObjectsFromArray:localUpcommingSortedArray];
    [meets addObjectsFromArray:localPastSortedArray];
}
@end
