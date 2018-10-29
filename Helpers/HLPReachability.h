//
//  HLPReachability.h
//  Helpers
//
//  Created by Dan Kalinin on 4/18/18.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "HLPOperation.h"
#import "HLPURL.h"

@class HLPReachability;

typedef NS_ENUM(NSUInteger, HLPReachabilityStatus) {
    HLPReachabilityStatusNone,
    HLPReachabilityStatusWiFi,
    HLPReachabilityStatusWWAN
};



@protocol HLPReachabilityDelegate <HLPOperationDelegate>

@optional
- (void)HLPReachabilityDidUpdateState:(HLPReachability *)reachability;

- (void)HLPReachabilityDidBegin:(HLPReachability *)reachability;
- (void)HLPReachabilityDidCancel:(HLPReachability *)reachability;
- (void)HLPReachabilityDidEnd:(HLPReachability *)reachability;

- (void)HLPReachabilityDidUpdateFlags:(HLPReachability *)reachability;

@end



@interface HLPReachability : HLPOperation <HLPReachabilityDelegate>

@property (readonly) HLPArray<HLPReachabilityDelegate> *delegates;
@property (readonly) NSURLComponents *localComponents;
@property (readonly) NSURLComponents *remoteComponents;
@property (readonly) SCNetworkReachabilityRef reachability;
@property (readonly) SCNetworkReachabilityFlags flags;
@property (readonly) HLPReachabilityStatus status;

+ (HLPReachabilityStatus)statusForFlags:(SCNetworkReachabilityFlags)flags;
- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents;

@end










@protocol NSEReachabilityDelegate <NSEOperationDelegate>

@end



@interface NSEReachability : NSEOperation <NSEReachabilityDelegate>

extern void NSEReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

typedef NS_ENUM(NSUInteger, NSEReachabilityStatus) {
    NSEReachabilityStatusNone,
    NSEReachabilityStatusWiFi,
    NSEReachabilityStatusWWAN
};

@property (readonly) SCNetworkReachabilityRef reachability;
@property (readonly) NSString *nodename;
@property (readonly) SCNetworkReachabilityContext *context;
@property (readonly) SCNetworkReachabilityFlags flags;
@property (readonly) NSEReachabilityStatus status;

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability;
- (instancetype)initWithName:(NSString *)nodename;

- (void)setCallback:(SCNetworkReachabilityCallBack)callback context:(SCNetworkReachabilityContext *)context;

@end
