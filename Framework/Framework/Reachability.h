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

@end



@interface Reachability : Operation

@property (readonly) SCNetworkReachabilityRef reachability;

- (instancetype)initWithLocalHost:(Host)localHost remoteHost:(Host)remoteHost;

@end
