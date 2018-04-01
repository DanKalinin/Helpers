//
//  Operation.h
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import <Foundation/Foundation.h>
#import "Main.h"

@class Operation, OperationQueue, OperationTask;

typedef NS_ENUM(NSUInteger, OperationState) {
    OperationStatePossible,
    OperationStateBegin,
    OperationStateProcess,
    OperationStateEnd
};










@protocol OperationDelegate <NSObject>

@optional
- (void)operationDidUpdateState:(Operation *)operation;
- (void)operationDidBegin:(Operation *)operation;
- (void)operationDidProcess:(Operation *)operation;
- (void)operationDidEnd:(Operation *)operation;
- (void)opertionDidUpdateProgress:(Operation *)operation;

@end



@interface Operation : NSOperation <OperationDelegate, NSProgressReporting>

@property NSError *error;

@property (readonly) id parent;
@property (readonly) SurrogateArray<OperationDelegate> *delegates;
@property (readonly) OperationState state;
@property (readonly) OperationState previousState;
@property (readonly) NSProgress *progress;
@property (readonly) NSOperationQueue *queue;

- (void)resume;
- (void)updateState:(OperationState)state;
- (void)updateProgress:(uint64_t)completedUnitCount;

@end










@interface OperationQueue : NSOperationQueue <OperationDelegate>

@property (readonly) SurrogateArray<OperationDelegate> *delegates;

@end
