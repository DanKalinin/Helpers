//
//  HLPURL.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>
#import "HLPString.h"

@class HLPURLComponents;










@interface HLPURLComponents : NSURLComponents

@end










@interface NSURL (HLP)

@property (class, readonly) NSString *hostAny;

@end










@interface NSURLComponents (HLP)

@property struct sockaddr address;

@end
