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

@class URLLoad, URLClient;










@protocol URLLoadDelegate <OperationDelegate>

@end



@interface URLLoad : Operation

@property (readonly) NSMutableArray<NSURLSessionTask *> *tasks;

- (instancetype)initWithTasks:(NSMutableArray<NSURLSessionTask *> *)tasks;
- (NSMutableArray<NSURLSessionTask *> *)tasksForState:(NSURLSessionTaskState)state;

@end










@protocol URLClientDelegate <ReachabilityDelegate, URLLoadDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end



@interface URLClient : OperationQueue <URLClientDelegate>

@property NSUInteger priority;

@property (readonly) SurrogateArray<URLClientDelegate> *delegates;
@property (readonly) NSURLComponents *localComponents;
@property (readonly) NSURLComponents *remoteComponents;
@property (readonly) Reachability *reachability;
@property (readonly) NSURLSession *defaultSesssion;
@property (readonly) NSURLSession *ephemeralSesssion;
@property (readonly) NSURLSession *backgroundSession;

- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents;
- (void)session:(NSURLSession *)session setConfiguration:(NSURLSessionConfiguration *)configuration;
- (URLLoad *)session:(NSURLSession *)session loadWithTasks:(NSMutableArray<NSURLSessionTask *> *)tasks;

@end
