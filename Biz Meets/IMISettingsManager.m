//
//  IMISettingsManager.m
//  YO MAP
//
//  Created by imicreation on 15/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMISettingsManager.h"

NSString *key1 = @"GPSVlaue";
NSString *key2 = @"MeetingAlertVlaue";
NSString *key3 = @"SearchAreaVlaue";
NSString *key4 = @"MapTypeVlaue";

@implementation IMISettingsManager
@synthesize defaults;

- (id)init {
    
    self = [super init];
    
    if(self) {
        defaults = [NSUserDefaults standardUserDefaults];
        [self setDefaultValuesForAllSettings];
    }
    return self;
}

-(void)setDefaultValuesForAllSettings   {
    if(!defaults)
        defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
    
    if(![allKeys containsObject:key1])   {
        [defaults setBool:YES forKey:key1];
    }
    if(![allKeys containsObject:key2])   {
        [defaults setBool:YES forKey:key2];
    }
    if(![allKeys containsObject:key3])   {
        [defaults setObject:@"50" forKey:key3];
    }
    if(![allKeys containsObject:key4])   {
        [defaults setBool:NO forKey:key4];
    }
    [defaults synchronize];
}

-(BOOL)getGPSValue  {
     NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
    
    if([allKeys containsObject:key1])
        return [defaults boolForKey:key1];
    else    {
        [defaults setBool:YES forKey:key1];
        return YES;
    }
    allKeys = NULL;
}

-(BOOL)getMeetingAlertValue  {
    NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
        if([allKeys containsObject:key2])
        return [defaults boolForKey:key2];
    else    {
        [defaults setBool:YES forKey:key2];
        return YES;
    }
}

-(NSString*)getSearchAreaValue  {
    NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
    
    if([allKeys containsObject:key3])
        return [defaults stringForKey:key3];
    else    {
        [defaults setObject:@"50" forKey:key3];
        return @"50";
    }
}

-(BOOL)getMapTypeValue  {
    NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
    
    if([allKeys containsObject:key4])
        return [defaults boolForKey:key4];
    else    {
        [defaults setBool:NO forKey:key4];
        return YES;
    }
}

-(void) setGPSValue:(BOOL)value {
    [defaults setBool:value forKey:key1];
    [defaults synchronize];
}

-(void) setMapTypeValue:(BOOL)value {   
    [defaults setBool:value forKey:key4];
    [defaults synchronize]; 
}

-(void) setMeetingAlertValue:(BOOL)value {
    [defaults setBool:value forKey:key2];
    [defaults synchronize];
}

-(void) setSearchAreaValue:(NSString*)value {
    [defaults setObject:value forKey:key3];
    [defaults synchronize];
}
@end