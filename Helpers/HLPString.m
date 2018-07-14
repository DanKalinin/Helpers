//
//  HLPString.m
//  Helpers
//
//  Created by Dan Kalinin on 7/14/18.
//

#import "HLPString.h"



@implementation NSString (HLP)

+ (instancetype)dot {
    return [self stringWithString:@"."];
}

+ (instancetype)comma {
    return [self stringWithString:@","];
}

+ (instancetype)space {
    return [self stringWithString:@" "];
}

@end
