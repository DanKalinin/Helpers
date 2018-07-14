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










@interface NSURLComponents (HLP)

@property (class, readonly) NSString *hostAny;

@property struct sockaddr address;

@end
