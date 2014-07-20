//
//  NF1ConnectionManager.m
//  iPhone
//
//  Created by Atin Amit on 04/10/12.
//  Copyright (c) 2012 Synchronoss. All rights reserved.
//

#import "NF1ConnectionManager.h"



@implementation NF1ConnectionManager

static NF1ConnectionManager *_connectionManager;

- (NF1ConnectionManager*)init {
    self = [super init];
   
    return self;
}

+ (NF1ConnectionManager*)connectionManager {
    if (_connectionManager == nil) {
        _connectionManager = [[NF1ConnectionManager alloc] init];
    }
    return _connectionManager;
}

-(void)dealloc  {
    _connectionManager = NULL;
}

- (BOOL) IsConnectionVia3G {
    Reachability* reachability3G = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability3G currentReachabilityStatus];
    
    if(status == ReachableViaWWAN) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL) IsConnectionViaWifi {
    Reachability* reachabilityWifi = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachabilityWifi currentReachabilityStatus];
    
    if(status == ReachableViaWiFi) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
