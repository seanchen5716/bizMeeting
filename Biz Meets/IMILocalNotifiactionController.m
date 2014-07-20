//
//  IMILocalNotifiactionController.m
//  YO MAP
//
//  Created by imicreation on 07/10/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMILocalNotifiactionController.h"

@implementation IMILocalNotifiactionController

+(void)createLocalNotifactionName:(NSString*)name date :(NSDate*) notificationDate  userInfo:(NSDictionary*)userInfo isAlarm:(BOOL) isAlarm  {
    
    
	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];

	// Break the date up into components
	NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
												   fromDate:notificationDate];
	NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
												   fromDate:notificationDate];
	
	// Set up the fire time
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[timeComponents hour]];
	// Notification will fire in one minute
    [dateComps setMinute:[timeComponents minute]];
	[dateComps setSecond:[timeComponents second]];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
	NSDate* preNotificationDate = [itemDate dateByAddingTimeInterval:-1800];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
	
	// Notification details
    localNotif.alertBody = name;
	// Set the action button
    localNotif.alertAction = @"View";
	
    if(isAlarm)
        localNotif.soundName = UILocalNotificationDefaultSoundName;
    else
        localNotif.soundName = nil;
    
    localNotif.applicationIconBadgeNumber = 1;
	
    localNotif.userInfo = userInfo;
	
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
   
    // reminder before 30 min.
    
    UILocalNotification *preNotificationLocalNotif = [[UILocalNotification alloc] init];
    if (preNotificationLocalNotif == nil)
        return;
    preNotificationLocalNotif.fireDate = preNotificationDate;
    preNotificationLocalNotif.timeZone = [NSTimeZone defaultTimeZone];
    // Notification details
    preNotificationLocalNotif.alertBody = name;
	// Set the action button
    preNotificationLocalNotif.alertAction = @"View";
	
    if(isAlarm)
        preNotificationLocalNotif.soundName = UILocalNotificationDefaultSoundName;
    else
        preNotificationLocalNotif.soundName = nil;
    
    preNotificationLocalNotif.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:preNotificationLocalNotif];
}

+ (void)cancelNotification:(NSString*)meetId
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"Cancelling... Before %d",[[[UIApplication sharedApplication]scheduledLocalNotifications]count]);
    
    for (UILocalNotification *notification in notifications)
    {
        NSString* notifMeetId = [NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"MeetId"]];
        
        NSLog(@"remedyID  : %@",meetId);
        NSLog(@"notifyId : %@",notifMeetId);
        if ([meetId isEqualToString:notifMeetId])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    NSLog(@"Cancelling... After %d",[[[UIApplication sharedApplication]scheduledLocalNotifications]count]);
}
@end
