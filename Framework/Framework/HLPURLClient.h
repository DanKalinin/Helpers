//
//  HLPURLClient.h
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import <Foundation/Foundation.h>
#import "HLPStream.h"
#import "HLPReachability.h"

@class HLPURLLoad, HLPURLClient;










@interface NSURLSessionTask (HLP)

@property HLPURLLoad *load;
@property NSMutableData *data;

@end










@protocol HLPURLLoadDelegate <HLPOperationDelegate>

@optional
- (void)URLLoadDidUpdateState:(HLPURLLoad *)load;
- (void)URLLoadDidUpdateProgress:(HLPURLLoad *)load;

- (void)URLLoadDidBegin:(HLPURLLoad *)load;
- (void)URLLoadDidEnd:(HLPURLLoad *)load;

- (void)URLLoad:(HLPURLLoad *)load didEndTask:(NSURLSessionTask *)task;

@end



@interface HLPURLLoad : HLPOperation <HLPURLLoadDelegate>

@property (readonly) HLPURLClient *parent;
@property (readonly) SurrogateArray<HLPURLLoadDelegate> *delegates;
@property (readonly) NSArray<NSURLSessionTask *> *tasks;

- (instancetype)initWithTasks:(NSArray<NSURLSessionTask *> *)tasks;
- (void)endTask:(NSURLSessionTask *)task;
- (void)cancelAllTasks;

@end










@protocol HLPURLClientDelegate <HLPOperationDelegate, HLPReachabilityDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end



@interface HLPURLClient : HLPOperationQueue <HLPURLClientDelegate>

@property NSURLSessionConfiguration *defaultConfiguration;
@property NSURLSessionConfiguration *ephemeralConfiguration;
@property NSURLSessionConfiguration *backgroundConfiguration;

@property (readonly) SurrogateArray<HLPURLClientDelegate> *delegates;
@property (readonly) NSURLSession *defaultSesssion;
@property (readonly) NSURLSession *ephemeralSesssion;
@property (readonly) NSURLSession *backgroundSession;
@property (readonly) HLPReachability *reachability;
@property (readonly) HLPStreamClient *streamClient;

- (HLPURLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks;
- (HLPURLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks completion:(VoidBlock)completion;

@end
