//
//  HLPCaptiveNetwork.m
//  Helpers
//
//  Created by Dan Kalinin on 6/16/18.
//

#import "HLPCaptiveNetwork.h"










@interface HLPNetworkInfo ()

@property NSDictionary *dictionary;
@property NSData *ssidData;
@property NSString *ssid;
@property NSString *bssid;

@end



@implementation HLPNetworkInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = super.init;
    if (self) {
        self.dictionary = dictionary;
        
        self.ssidData = dictionary[(__bridge NSString *)kCNNetworkInfoKeySSIDData];
        self.ssid = dictionary[(__bridge NSString *)kCNNetworkInfoKeySSID];
        self.bssid = dictionary[(__bridge NSString *)kCNNetworkInfoKeyBSSID];
    }
    return self;
}

- (NSString *)description {
    NSMutableArray *descriptions = NSMutableArray.array;
    
    NSString *description = [NSString stringWithFormat:@"SSID - %@", self.ssid];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"BSSID - %@", self.bssid];
    [descriptions addObject:description];
    
    description = [descriptions componentsJoinedByString:@"\r\n"];
    return description;
}

@end










@interface HLPCaptiveNetwork ()

@end



@implementation HLPCaptiveNetwork

+ (NSArray<NSString *> *)supportedInterfaces {
    NSArray *interfaces = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    return interfaces;
}

+ (HLPNetworkInfo *)currentNetworkInfoForInterface:(NSString *)interface {
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
    if (dictionary) {
        HLPNetworkInfo *info = [HLPNetworkInfo.alloc initWithDictionary:dictionary];
        return info;
    } else {
        return nil;
    }
}

@end
