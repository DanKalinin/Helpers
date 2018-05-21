//
//  HLPURLManager.h
//  Helpers
//
//  Created by Dan Kalinin on 4/25/18.
//

#import <Foundation/Foundation.h>
#import "HLPURLClient.h"

@class HLPURLManager;



@protocol HLPURLManagerDelegate <HLPOperationDelegate>

@end



@interface HLPURLManager : HLPOperationQueue <HLPURLManagerDelegate>

@property HLPURLClient *client1;
@property HLPURLClient *client2;

@property (readonly) SurrogateArray<HLPURLManagerDelegate> *delegates;
@property (readonly) HLPURLClient *client;

@end