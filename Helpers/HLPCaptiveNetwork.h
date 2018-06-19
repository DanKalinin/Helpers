//
//  HLPCaptiveNetwork.h
//  Helpers
//
//  Created by Dan Kalinin on 6/16/18.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "HLPObject.h"

@class HLPNetworkInfo, HLPCaptiveNetwork;










@interface HLPNetworkInfo : HLPObject

@property (readonly) NSDictionary *dictionary;
@property (readonly) NSData *ssidData;
@property (readonly) NSString *ssid;
@property (readonly) NSString *bssid;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end










@interface HLPCaptiveNetwork : HLPObject

@property (class, readonly) NSArray<NSString *> *supportedInterfaces;

+ (HLPNetworkInfo *)currentNetworkInfoForInterface:(NSString *)interface;

@end
