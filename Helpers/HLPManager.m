//
//  HLPManager.m
//  Helpers
//
//  Created by Dan Kalinin on 7/13/18.
//

#import "HLPManager.h"



@interface HLPManager ()

@property HLPClock *clock;
@property HLPReachability *reachability;

@end



@implementation HLPManager

@dynamic delegates;

+ (instancetype)shared {
    static HLPManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

- (instancetype)init {
    self = super.init;
    if (self) {
        self.clock = HLPClock.shared;
        [self.clock.delegates addObject:self.delegates];
        
        NSURLComponents *components = NSURLComponents.new;
        components.host = NSURLComponents.hostAny;
        self.reachability = [HLPReachability.alloc initWithLocalComponents:components remoteComponents:nil];
        [self.reachability.delegates addObject:self.delegates];
        [self.reachability start];
    }
    return self;
}

@end
