//
//  HLPManager.h
//  Helpers
//
//  Created by Dan Kalinin on 7/13/18.
//

#import <Foundation/Foundation.h>
#import "HLPOperation.h"
#import "HLPTimer.h"
#import "HLPReachability.h"

@class HLPManager;



@protocol HLPManagerDelegate <HLPClockDelegate, HLPReachabilityDelegate>

@end



@interface HLPManager : HLPOperationQueue <HLPManagerDelegate>

@property (readonly) HLPArray<HLPManagerDelegate> *delegates;
@property (readonly) HLPClock *clock;
@property (readonly) HLPReachability *reachability;

@end
