//
//  NF1ConnectionManager.h
//  iPhone
//
//  Created by Atin Amit on 04/10/12.
//  Copyright (c) 2012 Synchronoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NF1ConnectionManager : NSObject

- (BOOL) IsConnectionVia3G;
- (BOOL) IsConnectionViaWifi;
+ (NF1ConnectionManager*)connectionManager;
@end
