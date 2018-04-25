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
#import "Stream.h"

@class URLLoad, URLClient;










@protocol URLLoadDelegate <OperationDelegate>

@optional
- (void)loadDidUpdateState:(URLLoad *)load;
- (void)loadDidUpdateProgress:(URLLoad *)load;

- (void)loadDidBegin:(URLLoad *)load;
- (void)loadDidEnd:(URLLoad *)load;

@end



@interface URLLoad : Operation <URLLoadDelegate>

@property (readonly) URLClient *parent;
@property (readonly) SurrogateArray<URLLoadDelegate> *delegates;
@property (readonly) NSArray<NSURLSessionTask *> *tasks;

- (instancetype)initWithTasks:(NSArray<NSURLSessionTask *> *)tasks;
- (void)completeTask:(NSURLSessionTask *)task;
- (void)cancelAllTasks;

@end










@protocol URLClientDelegate <ReachabilityDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end



@interface URLClient : OperationQueue <URLClientDelegate>

@property NSURLSessionConfiguration *defaultConfiguration;
@property NSURLSessionConfiguration *ephemeralConfiguration;
@property NSURLSessionConfiguration *backgroundConfiguration;

@property (readonly) SurrogateArray<URLClientDelegate> *delegates;
@property (readonly) NSURLComponents *localComponents;
@property (readonly) NSURLComponents *remoteComponents;
@property (readonly) Reachability *reachability;
@property (readonly) StreamClient *streamClient;
@property (readonly) NSURLSession *defaultSesssion;
@property (readonly) NSURLSession *ephemeralSesssion;
@property (readonly) NSURLSession *backgroundSession;

- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents;
- (URLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks;

@end
