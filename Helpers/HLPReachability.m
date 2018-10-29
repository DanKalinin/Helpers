//
//  HLPReachability.m
//  Helpers
//
//  Created by Dan Kalinin on 4/18/18.
//

#import "HLPReachability.h"



static void HLPReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);



@interface HLPReachability ()

@property NSURLComponents *localComponents;
@property NSURLComponents *remoteComponents;
@property SCNetworkReachabilityRef reachability;

@end



@implementation HLPReachability

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
    SCNetworkReachabilitySetCallback(self.reachability, HLPReachabilityCallback, &ctx);
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    SCNetworkReachabilityScheduleWithRunLoop(self.reachability, loop, kCFRunLoopDefaultMode);
    
    [self updateState:HLPOperationStateDidBegin];
}

- (void)cancel {
    [super cancel];
    
    SCNetworkReachabilitySetCallback(self.reachability, NULL, NULL);
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, loop, kCFRunLoopDefaultMode);
    
    [self updateState:HLPOperationStateDidEnd];
}

- (NSString *)description {
    SCNetworkReachabilityFlags flags = self.flags;
    
    NSMutableArray *descriptions = NSMutableArray.array;
    
    NSString *description = [NSString stringWithFormat:@"TransientConnection - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsTransientConnection)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"Reachable - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsReachable)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionRequired - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsConnectionRequired)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionOnTraffic - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"InterventionRequired - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsInterventionRequired)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionOnDemand - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsConnectionOnDemand)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsLocalAddress - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsIsLocalAddress)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsDirect - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsIsDirect)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsWWAN - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsIsWWAN)];
    [descriptions addObject:description];
    
    description = [descriptions componentsJoinedByString:@"\r\n"];
    return description;
}

#pragma mark - Accesors

- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(self.reachability, &flags);
    return flags;
}

- (HLPReachabilityStatus)status {
    HLPReachabilityStatus status = [HLPReachability statusForFlags:self.flags];
    return status;
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];

    [self.delegates HLPReachabilityDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates HLPReachabilityDidBegin:self];
    } else if (state == HLPOperationStateDidCancel) {
        [self.delegates HLPReachabilityDidCancel:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates HLPReachabilityDidEnd:self];
    }
}

+ (HLPReachabilityStatus)statusForFlags:(SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired) && !(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            return HLPReachabilityStatusWWAN;
        } else {
            return HLPReachabilityStatusWiFi;
        }
    } else {
        return HLPReachabilityStatusNone;
    }
}

@end



static void HLPReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    HLPReachability *reachability = (__bridge HLPReachability *)info;
    [reachability.delegates HLPReachabilityDidUpdateFlags:reachability];
}










@interface NSEReachability ()

@property SCNetworkReachabilityRef reachability;
@property NSString *nodename;

@end



@implementation NSEReachability

void NSEReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = super.init;
    if (self) {
        self.reachability = reachability;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)nodename {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, nodename.UTF8String);
    self = [self initWithReachability:reachability];
    if (self) {
        self.nodename = nodename;
    }
    return self;
}

- (void)dealloc {
    CFRelease(self.reachability);
}

@end
