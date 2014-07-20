//
//  DataBase.h
//  MeetingWave
//
//  Created by Akshay Yarazarvi on 9/12/10.
//  Copyright 2010 Intelegencia Pvt. Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<sqlite3.h>


@interface DataBase : NSObject {
	sqlite3 *_database;
}

+ (DataBase*)database;

-(sqlite3_stmt *)runReadQuery:(const char *)query;
-(int)getNumberofMeetWithPersonId:(long long int)personId;
-(NSDictionary*)readMeetInfoForMeetId:(long long int)meetId;
-(NSMutableArray*) readAllMeetDatesWithContactId:(long long int) personId;
- (BOOL) havingMeetWithFutureDate:(NSString*) date;
-(NSMutableArray*) readAllMeetDatesFromCurrentTimeWithContactId:(long long int) personId;
-(NSArray*) readMeetsFortime:(NSString*)time;
-(NSArray*)readMeetsInfoforContactId:(long long int)personId;
-(long long) getlastmeetId;
-(BOOL) saveMeet:(NSMutableDictionary*)meetInfo;
- (BOOL)insert_entry:(NSMutableDictionary *)record;
- (BOOL) updateRecordWithMeetInfo:(NSDictionary*)meetInfo;
-(BOOL)DeleteMeetWithMeetId:(long long int)meetId;
-(BOOL)DeleteAllMeetsWithPersonId:(long long int)personId;

@end
