//
//  HLPOperation.h
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import <Foundation/Foundation.h>
#import "Main.h"
#import "HLPMain.h"
#import "HLPObject.h"
#import "HLPArray.h"

@class HLPOperation, HLPOperationQueue;

typedef NS_ENUM(NSUInteger, HLPOperationState) {
    HLPOperationStateDidInit = 0,
    HLPOperationStateDidCancel = 1,
    HLPOperationStateDidEnd = 2,
    HLPOperationStateDidBegin = 3
};










@protocol HLPOperationDelegate <HLPObject>

@optional
- (void)HLPOperationDidUpdateState:(HLPOperation *)operation;
- (void)HLPOperationDidUpdateProgress:(HLPOperation *)operation;

- (void)HLPOperationDidBegin:(HLPOperation *)operation;
- (void)HLPOperationDidCancel:(HLPOperation *)operation;
- (void)HLPOperationDidEnd:(HLPOperation *)operation;

@end



@interface HLPOperation : NSOperation <HLPOperationDelegate, NSProgressReporting>

@property HLPOperation *operation;

@property (copy) HLPVoidBlock stateBlock;
@property (copy) HLPVoidBlock progressBlock;

@property (readonly) id parent;
@property (readonly) HLPArray<HLPOperationDelegate> *delegates;
@property (readonly) NSMutableArray<NSNumber *> *states;
@property (readonly) NSMutableArray<NSError *> *errors;
@property (readonly) NSProgress *progress;
@property (readonly) NSOperationQueue *operationQueue;
@property (readonly) NSNotificationCenter *notificationCenter;
@property (readonly) dispatch_group_t group;

+ (instancetype)shared;

- (void)stop;
- (void)updateState:(HLPOperationState)state;
- (void)updateProgress:(uint64_t)completedUnitCount;
- (void)addOperation:(HLPOperation *)operation;

@end










@interface HLPOperationQueue : NSOperationQueue <HLPOperationDelegate>

@property (readonly) HLPArray<HLPOperationDelegate> *delegates;

+ (instancetype)shared;

@end










@interface NSOperationQueue (HLP)

- (void)addOperationWithBlockAndWait:(HLPVoidBlock)block;

@end










typedef NS_ENUM(NSUInteger, NSEOperationState) {
    NSEOperationStateInitial = 0,
    NSEOperationStateDidStart = 1,
    NSEOperationStateDidCancel = 2,
    NSEOperationStateDidFinish = 3
};










@protocol NSEOperationDelegate <HLPObject>

@end



@interface NSEOperation : NSOperation

@property (nonatomic) BOOL isCancelled;
@property (nonatomic) BOOL isExecuting;
@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isAsynchronous;
@property (nonatomic) BOOL isReady;

- (void)finish;

@end
