//
//  Reachability.m
//  Helpers
//
//  Created by Dan Kalinin on 4/18/18.
//

#import "Reachability.h"



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
    [super start];
    
    SCNetworkReachabilityContext ctx = {0};
    ctx.info = (__bridge void *)self;
    SCNetworkReachabilitySetCallback(self.reachability, ReachabilityCallback, &ctx);
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    SCNetworkReachabilityScheduleWithRunLoop(self.reachability, loop, kCFRunLoopDefaultMode);
}

- (void)cancel {
    [super cancel];
    
    SCNetworkReachabilitySetCallback(self.reachability, NULL, NULL);
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, loop, kCFRunLoopDefaultMode);
}

- (NSString *)description {
    SCNetworkReachabilityFlags state = self.state;
    
    NSMutableArray *descriptions = NSMutableArray.array;
    
    NSString *description = [NSString stringWithFormat:@"TransientConnection - %i", (BOOL)(state & kSCNetworkReachabilityFlagsTransientConnection)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"Reachable - %i", (BOOL)(state & kSCNetworkReachabilityFlagsReachable)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionRequired - %i", (BOOL)(state & kSCNetworkReachabilityFlagsConnectionRequired)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionOnTraffic - %i", (BOOL)(state & kSCNetworkReachabilityFlagsConnectionOnTraffic)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"InterventionRequired - %i", (BOOL)(state & kSCNetworkReachabilityFlagsInterventionRequired)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionOnDemand - %i", (BOOL)(state & kSCNetworkReachabilityFlagsConnectionOnDemand)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsLocalAddress - %i", (BOOL)(state & kSCNetworkReachabilityFlagsIsLocalAddress)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsDirect - %i", (BOOL)(state & kSCNetworkReachabilityFlagsIsDirect)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsWWAN - %i", (BOOL)(state & kSCNetworkReachabilityFlagsIsWWAN)];
    [descriptions addObject:description];
    
    description = [descriptions componentsJoinedByString:StringRN];
    return description;
}

#pragma mark - Accesors

- (SCNetworkReachabilityFlags)state {
    SCNetworkReachabilityFlags state;
    SCNetworkReachabilityGetFlags(self.reachability, &state);
    return state;
}

- (ReachabilityStatus)status {
    ReachabilityStatus status = [Reachability statusForState:self.state];
    return status;
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates reachabilityDidUpdateState:self];
}

+ (ReachabilityStatus)statusForState:(SCNetworkReachabilityFlags)state {
    if ((state & kSCNetworkReachabilityFlagsReachable) && !(state & kSCNetworkReachabilityFlagsConnectionRequired) && !(state & kSCNetworkReachabilityFlagsInterventionRequired)) {
        if (state & kSCNetworkReachabilityFlagsIsWWAN) {
            return ReachabilityStatusWWAN;
        } else {
            return ReachabilityStatusWiFi;
        }
    } else {
        return ReachabilityStatusNone;
    }
}

@end



static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    Reachability *reachability = (__bridge Reachability *)info;
    [reachability updateState:(OperationState)flags];
}
