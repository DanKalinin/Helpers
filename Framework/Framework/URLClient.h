//
//  URLConnection.h
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import <Foundation/Foundation.h>
#import "Main.h"
#import "Operation.h"
#import "Reachability.h"

@class URLClient;










@protocol URLClientDelegate <OperationDelegate, ReachabilityDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end



@interface URLClient : OperationQueue <URLClientDelegate>

@property NSUInteger priority;

@property (readonly) SurrogateArray<URLClientDelegate> *delegates;
@property (readonly) Reachability *reachability;
@property (readonly) NSURLSession *defaultSesssion;
@property (readonly) NSURLSession *ephemeralSesssion;
@property (readonly) NSURLSession *backgroundSession;

- (void)setConfiguration:(NSURLSessionConfiguration *)configuration forSession:(NSURLSession *)session;

@end
