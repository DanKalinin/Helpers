//
//  Reachability.m
//  Helpers
//
//  Created by Dan Kalinin on 4/18/18.
//

#import "Reachability.h"

const OperationState ReachabilityStateNone = 2;
const OperationState ReachabilityStateWiFi = 3;
const OperationState ReachabilityStateWWAN = 4;










@interface Reachability ()

@property SCNetworkReachabilityRef reachability;

@end



@implementation Reachability

- (instancetype)initWithLocalHost:(Host)localHost remoteHost:(Host)remoteHost {
    self = super.init;
    if (self) {
        
    }
    return self;
}

- (void)start {
    
}

- (void)cancel {
    
}

@end
