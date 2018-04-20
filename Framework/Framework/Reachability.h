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

extern const OperationState ReachabilityStateNone;
extern const OperationState ReachabilityStateWiFi;
extern const OperationState ReachabilityStateWWAN;










@protocol ReachabilityDelegate <OperationDelegate>

@optional
- (void)reachabilityDidUpdateState:(Reachability *)reachability;
- (void)reachabilityStateNone:(Reachability *)reachability;
- (void)reachabilityStateWiFi:(Reachability *)reachability;
- (void)reachabilityStateWWAN:(Reachability *)reachability;

@end



@interface Reachability : Operation

@property (readonly) SurrogateArray<ReachabilityDelegate> *delegates;
@property (readonly) NSURLComponents *localComponents;
@property (readonly) NSURLComponents *remoteComponents;
@property (readonly) SCNetworkReachabilityRef reachability;
@property (readonly) SCNetworkReachabilityFlags flags;
@property (readonly) OperationState state;

- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents;

@end
