//
//  HLPURL.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>










@interface HLPURLComponents : NSURLComponents

@end










@interface NSURLComponents (HLP)

@property struct sockaddr address;

@end
