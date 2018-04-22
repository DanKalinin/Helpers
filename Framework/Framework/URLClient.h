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










@protocol URLClientDelegate <OperationDelegate, ReachabilityDelegate, NSURLSessionDelegate>

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

//@protocol URLConnectionDelegate
//
//@optional
//- (void)URLConnection:(URLConnection *)connection didUpdateURL:(NSURLComponents *)URL;
//
//@end
//
//
//
//@interface URLConnection : OperationQueue <URLConnectionDelegate>
//
//@property NSUInteger URLHistorySize;
//
//@property (readonly) NSMutableArray<NSURLComponents *> *URLs;
//@property (readonly) NSMutableArray<_Reachability *> *reachabilities;
//
//@property (readonly) NSURLComponents *URL;
//@property (readonly) NSMutableArray<NSURLComponents *> *URLHistory;
//
//@end
