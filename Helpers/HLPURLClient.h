//
//  HLPURLClient.h
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import <Foundation/Foundation.h>
#import "HLPStream.h"
#import "HLPReachability.h"

@class HLPURLLoad, HLPURLClient, HLPURLClientManager;

extern NSErrorDomain const HLPURLHTTPErrorDomain;

NS_ERROR_ENUM(HLPURLHTTPErrorDomain) {
    HLPURLHTTPStatusCodeContinue = 100,
    HLPURLHTTPStatusCodeOK = 200,
    HLPURLHTTPStatusCodeMultipleChoices = 300,
    HLPURLHTTPStatusCodeBadRequest = 400,
    HLPURLHTTPStatusCodeInternalServerError = 500
};










@protocol HLPURLLoadDelegate <HLPOperationDelegate>

@optional
- (void)HLPURLLoadDidUpdateState:(HLPURLLoad *)load;
- (void)HLPURLLoadDidUpdateProgress:(HLPURLLoad *)load;

- (void)HLPURLLoadDidBegin:(HLPURLLoad *)load;
- (void)HLPURLLoadDidEnd:(HLPURLLoad *)load;

- (void)HLPURLLoad:(HLPURLLoad *)load didEndTask:(NSURLSessionTask *)task;

@end



@interface HLPURLLoad : HLPOperation <HLPURLLoadDelegate>

@property (readonly) HLPURLClient *parent;
@property (readonly) HLPArray<HLPURLLoadDelegate> *delegates;
@property (readonly) NSArray<NSURLSessionTask *> *tasks;

- (instancetype)initWithTasks:(NSArray<NSURLSessionTask *> *)tasks;
- (void)endTask:(NSURLSessionTask *)task;
- (void)cancelAllTasks;

@end










@protocol HLPURLClientDelegate <HLPURLLoadDelegate, HLPReachabilityDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end



@interface HLPURLClient : HLPOperationQueue <HLPURLClientDelegate>

@property NSURLSessionConfiguration *defaultConfiguration;
@property NSURLSessionConfiguration *ephemeralConfiguration;
@property NSURLSessionConfiguration *backgroundConfiguration;

@property (readonly) HLPArray<HLPURLClientDelegate> *delegates;
@property (readonly) NSURLSession *defaultSesssion;
@property (readonly) NSURLSession *ephemeralSesssion;
@property (readonly) NSURLSession *backgroundSession;
@property (readonly) HLPReachability *reachability;
@property (readonly) HLPStreamClient *streamClient;

- (HLPURLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks;
- (HLPURLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks completion:(VoidBlock)completion;

@end










@protocol HLPURLClientManagerDelegate <HLPURLClientDelegate>

@end



@interface HLPURLClientManager : HLPOperationQueue <HLPURLClientManagerDelegate>

@property HLPURLClient *localClient;
@property HLPURLClient *remoteClient;

@property (readonly) HLPArray<HLPURLClientManagerDelegate> *delegates;
@property (readonly) HLPURLClient *client;

@end










@interface NSURLSessionTask (HLP)

@property HLPURLLoad *load;
@property NSMutableData *data;

@end
