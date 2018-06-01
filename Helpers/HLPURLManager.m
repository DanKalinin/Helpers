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
    if (self.localClient && !self.remoteClient) {
        return self.localClient;
    } else if (!self.localClient && self.remoteClient) {
        return self.remoteClient;
    } else if (self.localClient && self.remoteClient) {
        if (self.localClient.reachability.status == HLPReachabilityStatusWiFi) {
            return self.localClient;
        } else if (self.remoteClient.reachability.status != HLPReachabilityStatusNone) {
            return self.remoteClient;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end
