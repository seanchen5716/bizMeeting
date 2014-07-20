//
//  IMISettingsManager.h
//  YO MAP
//
//  Created by imicreation on 15/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMISettingsManager : NSObject    {
    
    NSUserDefaults *defaults;
    
}

@property(nonatomic, retain) NSUserDefaults *defaults;


-(BOOL)getGPSValue;
-(BOOL)getMeetingAlertValue;
-(NSString*)getSearchAreaValue;
-(BOOL)getMapTypeValue;

-(void) setGPSValue:(BOOL)value;
-(void) setMeetingAlertValue:(BOOL)value;
-(void) setSearchAreaValue:(NSString*)value;
-(void) setMapTypeValue:(BOOL)value;
@end
