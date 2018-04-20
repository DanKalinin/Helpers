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










static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);



@interface Reachability ()

@property NSURLComponents *localComponents;
@property NSURLComponents *remoteComponents;
@property SCNetworkReachabilityRef reachability;

@end



@implementation Reachability

@dynamic delegates;

- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents {
    self = super.init;
    if (self) {
        self.localComponents = localComponents;
        self.remoteComponents = remoteComponents;
        
        if (localComponents && !remoteComponents) {
            struct sockaddr address = localComponents.address;
            self.reachability = SCNetworkReachabilityCreateWithAddressPair(NULL, &address, NULL);
        } else if (!localComponents && remoteComponents) {
            struct sockaddr address = remoteComponents.address;
            self.reachability = SCNetworkReachabilityCreateWithAddressPair(NULL, NULL, &address);
        } else if (localComponents && remoteComponents) {
            struct sockaddr localAddress = localComponents.address;
            struct sockaddr remoteAddress = remoteComponents.address;
            self.reachability = SCNetworkReachabilityCreateWithAddressPair(NULL, &localAddress, &remoteAddress);
        }
    }
    return self;
}

- (void)dealloc {
    CFRelease(self.reachability);
}

- (void)start {
    SCNetworkReachabilityContext ctx = {0};
    ctx.info = (__bridge void *)self;
    SCNetworkReachabilitySetCallback(self.reachability, ReachabilityCallback, &ctx);
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    SCNetworkReachabilityScheduleWithRunLoop(self.reachability, loop, kCFRunLoopDefaultMode);
}

- (void)cancel {
    SCNetworkReachabilitySetCallback(self.reachability, NULL, NULL);
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, loop, kCFRunLoopDefaultMode);
}

#pragma mark - Accessors

- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(self.reachability, &flags);
    return flags;
}

- (OperationState)state {
    SCNetworkReachabilityFlags flags = self.flags;
    return ReachabilityStateNone;
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates reachabilityDidUpdateState:self];
    if (state == ReachabilityStateNone) {
        [self.delegates reachabilityStateNone:self];
    } else if (state == ReachabilityStateWiFi) {
        [self.delegates reachabilityStateWiFi:self];
    } else if (state == ReachabilityStateWWAN) {
        [self.delegates reachabilityStateWWAN:self];
    }
}

@end



static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    Reachability *reachability = (__bridge Reachability *)info;
    OperationState state = reachability.state;
    if (state != reachability.states.lastObject.unsignedIntValue) {
        [reachability updateState:state];
    }
}
