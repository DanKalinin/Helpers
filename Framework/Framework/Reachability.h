//
//  Reachability.h
//  Helpers
//
//  Created by Dan Kalinin on 4/18/18.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Operation.h"

@class Reachability;

typedef NS_ENUM(NSUInteger, ReachabilityStatus) {
    ReachabilityStatusNone,
    ReachabilityStatusWiFi,
    ReachabilityStatusWWAN
};



@protocol ReachabilityDelegate <OperationDelegate>

@optional
- (void)reachabilityDidUpdateState:(Reachability *)reachability;

@end



@interface Reachability : Operation

@property (readonly) SurrogateArray<ReachabilityDelegate> *delegates;
@property (readonly) NSURLComponents *localComponents;
@property (readonly) NSURLComponents *remoteComponents;
@property (readonly) SCNetworkReachabilityRef reachability;
@property (readonly) SCNetworkReachabilityFlags state;
@property (readonly) ReachabilityStatus status;

+ (ReachabilityStatus)statusForState:(SCNetworkReachabilityFlags)state;
- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents;

@end
