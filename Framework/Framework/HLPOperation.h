//
//  HLPOperation.h
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import <Foundation/Foundation.h>
#import "HLPMain.h"

@class HLPOperation, HLPOperationQueue;

typedef NS_ENUM(NSUInteger, HLPOperationState) {
    HLPOperationStateDidBegin,
    HLPOperationStateDidEnd
};










@protocol HLPOperationDelegate <NSObject>

@optional
- (void)operationDidUpdateState:(HLPOperation *)operation;
- (void)opertionDidUpdateProgress:(HLPOperation *)operation;

- (void)operationDidBegin:(HLPOperation *)operation;
- (void)operationDidEnd:(HLPOperation *)operation;

@end



@interface HLPOperation : NSOperation <HLPOperationDelegate, NSProgressReporting>

@property (copy) VoidBlock stateBlock;
@property (copy) VoidBlock progressBlock;

@property (readonly) id parent;
@property (readonly) SurrogateArray<HLPOperationDelegate> *delegates;
@property (readonly) NSMutableArray<NSNumber *> *states;
@property (readonly) NSMutableArray<NSError *> *errors;
@property (readonly) NSProgress *progress;
@property (readonly) NSOperationQueue *operationQueue;
@property (readonly) dispatch_group_t group;

+ (instancetype)shared;

- (void)updateState:(HLPOperationState)state;
- (void)updateProgress:(uint64_t)completedUnitCount;
- (void)addOperation:(HLPOperation *)operation;

@end










@interface HLPOperationQueue : NSOperationQueue <HLPOperationDelegate>

@property (readonly) __kindof HLPOperation *operation;
@property (readonly) SurrogateArray<HLPOperationDelegate> *delegates;

+ (instancetype)shared;

@end