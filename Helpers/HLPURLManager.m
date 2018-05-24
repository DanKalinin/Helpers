//
//  HLPURLManager.m
//  Helpers
//
//  Created by Dan Kalinin on 4/25/18.
//

#import "HLPURLManager.h"



@interface HLPURLManager ()

@end



@implementation HLPURLManager

@dynamic delegates;

- (instancetype)init {
    self = super.init;
    if (self) {
    }
    return self;
}

#pragma mark - Accessors

- (HLPURLClient *)client {
    if (self.client1.reachability.status != HLPReachabilityStatusNone) {
        return self.client1;
    } else if (self.client2.reachability.status != HLPReachabilityStatusNone) {
        return self.client2;
    } else {
        return nil;
    }
}

@end
