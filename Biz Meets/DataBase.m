
//
//  DataBase.m
//  MeetingWave
//
//  Created by Akshay Yarazarvi on 9/12/10.
//  Copyright 2010 Intelegencia Pvt. Ltd.. All rights reserved.
//

#import "DataBase.h"


@implementation DataBase

static DataBase *_database;

+ (DataBase*)database {
    if (_database == nil) {
        _database = [[DataBase alloc] init];
    }
    return _database;
}


- (id)init {
    if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"App.sqlite"];
        
        if (sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        
        paths = NULL;
        path = NULL;
        documentsDirectory = NULL;
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
    
    if(_database)
        sqlite3_free(_database);
}

-(sqlite3_stmt *)runReadQuery:(const char *)query
{
    @autoreleasepool {
        
        const char *sqlStatement1 = query;
        
        sqlite3_stmt *compiledStatement1 = nil;
        
        if (sqlite3_prepare_v2(_database, sqlStatement1, -1, &compiledStatement1, NULL) == SQLITE_OK)
        {
            return compiledStatement1;
        }
        
        query = NULL;
        sqlStatement1 = NULL;
        
        return NULL;
    }
}

-(int)getNumberofMeetWithPersonId:(long long int)personId {
    
    @try
	{
        @autoreleasepool {
            int number ;
            
            NSString* query = [[NSString alloc] initWithFormat:@"select count(*) from Meet where PersonId = %lld;",personId];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                //			genId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
                number = sqlite3_column_int(stmt, 0);
            }
            
            queryString = NULL;
            query = NULL;
            stmt = NULL;
            
            return number;
            sqlite3_finalize(stmt);
        }
    }
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
}

-(NSDictionary*)readMeetInfoForMeetId:(long long int)meetId {
    @try
	{
        @autoreleasepool {
            NSString* query = [[NSString alloc] initWithFormat:@"select MeetId, PersonId, Title, Alarm, Notify, Date, Note from Meet where MeetId = %lld;",meetId];
            
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            NSMutableDictionary *meet;
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                meet = [[NSMutableDictionary alloc] init];
                
                [meet setValue:[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 0)] forKey:@"MeetId"];
                [meet setValue:[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 1)] forKey:@"PersonId"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] forKey:@"Title"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] forKey:@"Alarm"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] forKey:@"Notify"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] forKey:@"Date"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] forKey:@"Note"];
            }
            sqlite3_finalize(stmt);
            
            queryString = NULL;
            stmt = NULL;
            
            return meet;
        }
	}
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
}

-(NSMutableArray*) readAllMeetDatesWithContactId:(long long int) personId  {
    @try
	{
        @autoreleasepool {
            NSMutableArray* allDates = [[NSMutableArray alloc] init];
            NSString* query = [[NSString alloc] initWithFormat:@"select DISTINCT Date from Meet where PersonId = %lld;",personId];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                [allDates addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)]];
            }
            
            sqlite3_finalize(stmt);
            queryString = NULL;
            stmt = NULL;
            
            return allDates;
            
        }
	}
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
}
- (BOOL) havingMeetWithFutureDate:(NSString*) date    {
    @try
	{
        @autoreleasepool {
            int number = 0;
            NSString* query = [[NSString alloc] initWithFormat:@"select count(*) from Meet where Date = \'%@\';",date];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            
            stmt = [self runReadQuery:queryString];
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                number = sqlite3_column_int(stmt, 0);
            }
            
            sqlite3_finalize(stmt);
            queryString = NULL;
            stmt = NULL;
            
            if(number == 0)
                return NO;
            else
                return YES;
            
            return NO;
        }
	}
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
}

-(NSMutableArray*) readAllMeetDatesFromCurrentTimeWithContactId:(long long int) personId  {
    @try
	{
        @autoreleasepool {
            NSMutableArray* allDates = [[NSMutableArray alloc] init];
            NSString* query = [[NSString alloc] initWithFormat:@"select DISTINCT Date from Meet where PersonId = %lld;",personId];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            
            NSDate* date = NULL;
            NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
            [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                date = [dateTimeFormatter dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)]];
                
                if([date compare:[NSDate date]] ==  NSOrderedDescending || [date compare:[NSDate date]] == NSOrderedSame)
                    [allDates addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)]];
            }
            
            sqlite3_finalize(stmt);
            queryString = NULL;
            stmt = NULL;
            
            return allDates;
        }
	}
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
    
}


-(NSArray*) readMeetsFortime:(NSString*)time    {
    @try
	{
        @autoreleasepool {
            NSMutableArray* allMeets = [[NSMutableArray alloc] init];
            NSString* query = [[NSString alloc] initWithFormat:@"select DISTINCT MeetId, PersonId, Title, Alarm, Notify, Date, Note from Meet where Date LIKE '%%%@%%';",time];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            NSMutableDictionary *meet;
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                meet = [[NSMutableDictionary alloc] init];
                
                [meet setValue:[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 0)] forKey:@"MeetId"];
                [meet setValue:[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 1)] forKey:@"PersonId"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] forKey:@"Title"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] forKey:@"Alarm"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] forKey:@"Notify"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] forKey:@"Date"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] forKey:@"Note"];
                
                [allMeets addObject:meet];
            }
            
            sqlite3_finalize(stmt);
            queryString = NULL;
            stmt = NULL;

            return allMeets;
        }
	}
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
}

-(NSArray*)readMeetsInfoforContactId:(long long int)personId    {
    @try
	{
        @autoreleasepool {
            NSMutableArray* allMeets = [[NSMutableArray alloc] init];
            NSString* query = [[NSString alloc] initWithFormat:@"select DISTINCT MeetId, PersonId, Title, Alarm, Notify, Date, Note from Meet where PersonId = %lld;",personId];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            NSMutableDictionary *meet;
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                meet = [[NSMutableDictionary alloc] init];
                
                [meet setValue:[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 0)] forKey:@"MeetId"];
                [meet setValue:[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 1)] forKey:@"PersonId"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] forKey:@"Title"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] forKey:@"Alarm"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] forKey:@"Notify"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] forKey:@"Date"];
                [meet setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] forKey:@"Note"];
                
                [allMeets addObject:meet];
            }
            
            sqlite3_finalize(stmt);
            queryString = NULL;
            stmt = NULL;
            return allMeets;
        }
	}
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
	
}

-(long long) getlastmeetId  {
    @try
	{
        @autoreleasepool {
            NSString* query = [[NSString alloc] initWithFormat:@"select MAX(MeetId) from Meet"];
            const char *queryString = (const char*) [query UTF8String];
            sqlite3_stmt *stmt;
            stmt = [self runReadQuery:queryString];
            long long int meetId = -1;
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                meetId = [[NSNumber numberWithLongLong: sqlite3_column_int64(stmt, 0)] longLongValue];
            }
            
            sqlite3_finalize(stmt);
            queryString = NULL;
            stmt = NULL;
            return meetId;
        }
    }
	@catch (NSException * e)
	{
		NSLog(@"Unresolved error %@, %@", e, [e userInfo]);
	}
}


-(BOOL) saveMeet:(NSMutableDictionary*)meetInfo    {
    
    return [self insert_entry:meetInfo];
}

- (BOOL)insert_entry:(NSMutableDictionary *)record
{
    @autoreleasepool {
        sqlite3_stmt *init_statement = nil;
        @try
        {
            const char *sql = "insert into Meet(PersonId, Title, Alarm, Notify, Date, Note) values(?,?,?,?,?,?);";
            
            if(sqlite3_prepare_v2(_database, sql, -1, &init_statement, NULL) != SQLITE_OK)
            {
                NSAssert1(0,@"Error: Failed to prepare statement with message '%s'.",sqlite3_errmsg(_database));
                NSLog(@"DataBase error. Please contact to the iphone administrator.");
                init_statement = NULL;
                sql = NULL;
                return FALSE;
            }
            
            sqlite3_bind_int(init_statement, 1,(int)[[record objectForKey:@"PersonId"] integerValue]);
            sqlite3_bind_text(init_statement, 2,[[record objectForKey:@"Title"] UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(init_statement, 3,[[record objectForKey:@"Alarm"] UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(init_statement, 4,[[record objectForKey:@"Notify"] UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(init_statement, 5,[[record objectForKey:@"Date"] UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(init_statement, 6,[[record objectForKey:@"Note"] UTF8String],-1,SQLITE_TRANSIENT);
            
            sql = NULL;
            
            if(SQLITE_DONE != sqlite3_step(init_statement))
            {
                //				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                NSLog(@"DataBase error. Please contact to the iphone administrator.");
                init_statement = NULL;
                return FALSE;
            }
        }
        @catch (NSException *ex)
        {
            NSLog(@"%@ %@",[ex name],[ex userInfo]);
            
            @throw ex;
        }
        @finally 
        {
            if(init_statement)  {
                sqlite3_finalize(init_statement);
                init_statement = NULL;
            }
         }
        return TRUE;
    }
}

//- (void)clear
//{
//	//delete the old Record
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString *path1 = [documentsDirectory stringByAppendingPathComponent:@"myDatabase.sqlite"];
//	
//
//	if (sqlite3_open([path1 UTF8String], &database) == SQLITE_OK) 
//	{   
//		const char *sqlStatement1 = "delete from  UserName where id =1";		
//		sqlite3_stmt *compiledStatement1;
//		if (sqlite3_prepare_v2(database, sqlStatement1, -1, &compiledStatement1, NULL) == SQLITE_OK) 
//		{			
//			while (sqlite3_step(compiledStatement1) == SQLITE_ROW) 
//			{
//				
//				
//			}	
//			
//		}
//	}	
//}

- (BOOL) updateRecordWithMeetInfo:(NSDictionary*)meetInfo {
    @autoreleasepool {
        sqlite3_stmt *init_statement = nil;
        @try
        {
            NSString* query = [[NSString alloc] initWithFormat:@"UPDATE Meet SET Title = \'%@\', Alarm = \'%@\', Notify = \'%@\', Date = \'%@\', Note = \'%@\' WHERE MeetId = %lld",
                               [meetInfo objectForKey:@"Title"],
                               [meetInfo objectForKey:@"Alarm"],
                               [meetInfo objectForKey:@"Notify"],
                               [meetInfo objectForKey:@"Date"],
                               [meetInfo objectForKey:@"Note"],
                               [[meetInfo objectForKey:@"MeetId"] longLongValue]];
            
            const char *queryString = (const char*) [query UTF8String];
            
            if(sqlite3_prepare_v2(_database, queryString, -1, &init_statement, NULL) != SQLITE_OK)
            {
                
                NSAssert1(0,@"Error: Failed to prepare statement with message '%s'.",sqlite3_errmsg(_database));
                NSLog(@"DataBase error. Please contact to the iphone administrator.");
                queryString = NULL;
                init_statement = NULL;
                return FALSE;
            }
            
            if(SQLITE_DONE != sqlite3_step(init_statement))
            {
                //				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                NSLog(@"DataBase error. Please contact to the iphone administrator.");
                queryString = NULL;
                return FALSE;
            }
        }
        @catch (NSException *ex)
        {
            NSLog(@"%@ %@",[ex name],[ex userInfo]);
            @throw ex;
        }
        @finally
        {
            if(init_statement)  {
                sqlite3_finalize(init_statement);
                init_statement = NULL;
            }
        }
        return TRUE;
    }
}

-(BOOL)DeleteMeetWithMeetId:(long long int)meetId   {
    @autoreleasepool {
        sqlite3_stmt *init_statement = nil;
		@try
		{
            NSString* query = [[NSString alloc] initWithFormat:@"DELETE FROM Meet WHERE MeetId = %lld",meetId];
            const char *queryString = (const char*) [query UTF8String];
            
            if(sqlite3_prepare_v2(_database, queryString, -1, &init_statement, NULL) == SQLITE_OK) {
                // Loop through the results and add them to the feeds array
                while(sqlite3_step(init_statement) == SQLITE_ROW) {
                    // Read the data from the result row
                    NSLog(@"result is here");
                }
            }
            else    {
                NSAssert1(0,@"Error: Failed to prepare statement with message '%s'.",sqlite3_errmsg(_database));
				NSLog(@"DataBase error. Please contact to the iphone administrator.");
                queryString = NULL;
                init_statement = NULL;
				return FALSE;
            }
            queryString = NULL;
		}
		@catch (NSException *ex)
		{
			NSLog(@"%@ %@",[ex name],[ex userInfo]);
			@throw ex;
		}
		@finally
		{
			if(init_statement)  {
                sqlite3_finalize(init_statement);
                init_statement = NULL;
            }
		}
    }
	return TRUE;
}

-(BOOL)DeleteAllMeetsWithPersonId:(long long int)personId   {
    @autoreleasepool {
        sqlite3_stmt *init_statement = nil;
		@try
		{
            NSString* query = [[NSString alloc] initWithFormat:@"DELETE FROM Meet WHERE PersonId = %lld",personId];
            const char *queryString = (const char*) [query UTF8String];
            
            if(sqlite3_prepare_v2(_database, queryString, -1, &init_statement, NULL) == SQLITE_OK) {
                // Loop through the results and add them to the feeds array
                while(sqlite3_step(init_statement) == SQLITE_ROW) {
                    // Read the data from the result row
                    NSLog(@"result is here");
                }
            }
            else    {
                NSAssert1(0,@"Error: Failed to prepare statement with message '%s'.",sqlite3_errmsg(_database));
				NSLog(@"DataBase error. Please contact to the iphone administrator.");
                queryString = NULL;
				return FALSE;
            }
            queryString = NULL;
		}
		@catch (NSException *ex)
		{
			NSLog(@"%@ %@",[ex name],[ex userInfo]);
			@throw ex;
		}
		@finally
		{
			if(init_statement)  {
                sqlite3_finalize(init_statement);
            }
		}
    }
	return TRUE;
}

@end
