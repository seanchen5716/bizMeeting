//
//  IMILocalNotifiactionController.h
//  YO MAP
//
//  Created by imicreation on 07/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMILocalNotifiactionController : NSObject    {
    
    
}

+(void)createLocalNotifactionName:(NSString*)name date :(NSDate*) notificationDate  userInfo:(NSDictionary*)userInfo isAlarm:(BOOL) isAlarm;
+ (void)cancelNotification:(NSString*)meetId;

@end
