//
//  NSEOperation.h
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEMain.h"

@class NSEOperation;
@class NSEOrderedSet;

@protocol NSEOperationDelegate;



@protocol NSEOperationDelegate <NSObject>

@optional
- (void)nseOperationDidUpdateState:(NSEOperation *)operation;
- (void)nseOperationDidStart:(NSEOperation *)operation;
- (void)nseOperationDidCancel:(NSEOperation *)operation;
- (void)nseOperationDidFinish:(NSEOperation *)operation;

- (void)nseOperationDidUpdateProgress:(NSEOperation *)operation;

@end



@interface NSEOperation : NSOperation <NSEOperationDelegate, NSProgressReporting>

extern NSErrorDomain const NSEOperationErrorDomain;

NS_ERROR_ENUM(NSEOperationErrorDomain) {
    NSEOperationErrorUnknown = 0
};

typedef NS_ENUM(NSUInteger, NSEOperationState) {
    NSEOperationStateDidInit = 0,
    NSEOperationStateDidStart = 1,
    NSEOperationStateDidCancel = 99,
    NSEOperationStateDidFinish = 100
};

@property NSEOperationState state;
@property NSError *error;
@property NSEOperation *operation;

@property (nonatomic) BOOL isCancelled;
@property (nonatomic) BOOL isExecuting;
@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isAsynchronous;
@property (nonatomic) BOOL isReady;

@property (copy) NSEBlock stateBlock;
@property (copy) NSEBlock progressBlock;

@property (readonly) NSEOperation *parent;
@property (readonly) NSEOrderedSet<NSEOperationDelegate> *delegates;
@property (readonly) NSMutableArray<NSError *> *errors;
@property (readonly) NSProgress *progress;
@property (readonly) NSOperationQueue *queue;
@property (readonly) NSNotificationCenter *center;
@property (readonly) NSRunLoop *loop;

- (void)finish;
- (void)updateState:(NSEOperationState)state;
- (void)updateProgress:(int64_t)completedUnitCount;
- (void)addOperation:(NSEOperation *)operation;

@end
