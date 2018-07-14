//
//  HLPURL.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>

@class HLPURLComponents;










@interface HLPURLComponents : NSURLComponents

@end










@interface NSURL (HLP)

@end










@interface NSURLComponents (HLP)

@property struct sockaddr address;

@end
