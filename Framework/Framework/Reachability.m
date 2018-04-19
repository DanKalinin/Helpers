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

@property NSURLComponents *localComponents;
@property NSURLComponents *remoteComponents;
@property SCNetworkReachabilityRef reachability;

@end



@implementation Reachability

- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents {
    self = super.init;
    if (self) {
        self.localComponents = localComponents;
        self.remoteComponents = remoteComponents;
        
        self.reachability = 
    }
    return self;
}

- (void)dealloc {
    CFRelease(self.reachability);
}

- (void)start {
    
}

- (void)cancel {
    
}

@end
