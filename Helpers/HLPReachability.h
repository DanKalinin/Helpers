//
//  HLPReachability.h
//  Helpers
//
//  Created by Dan Kalinin on 4/18/18.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "HLPOperation.h"

@class HLPReachability;

typedef NS_ENUM(NSUInteger, HLPReachabilityStatus) {
    HLPReachabilityStatusNone,
    HLPReachabilityStatusWiFi,
    HLPReachabilityStatusWWAN
};



@protocol HLPReachabilityDelegate <HLPOperationDelegate>

@optional
- (void)reachabilityDidUpdateState:(HLPReachability *)reachability;

@end



@interface HLPReachability : HLPOperation

@property (readonly) SurrogateArray<HLPReachabilityDelegate> *delegates;
@property (readonly) NSURLComponents *localComponents;
@property (readonly) NSURLComponents *remoteComponents;
@property (readonly) SCNetworkReachabilityRef reachability;
@property (readonly) SCNetworkReachabilityFlags state;
@property (readonly) HLPReachabilityStatus status;

+ (HLPReachabilityStatus)statusForState:(SCNetworkReachabilityFlags)state;
- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents;

@end
