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
    OperationStateBegin,
    OperationStateProcess,
    OperationStateEnd,
    OperationStateError
};










@protocol OperationDelegate <NSObject>

@optional
- (void)operationDidUpdateState:(Operation *)operation;
- (void)opertionDidUpdateProgress:(Operation *)operation;

@end



@interface Operation : NSOperation <OperationDelegate, NSProgressReporting>

@property NSError *error;

@property (readonly) SurrogateArray<OperationDelegate> *delegates;
@property (readonly) OperationState state;
@property (readonly) NSProgress *progress;
@property (readonly) __kindof OperationQueue *queue;

- (void)updateState:(OperationState)state;
- (void)updateProgress:(uint64_t)completedUnitCount;

@end










@interface OperationQueue : NSOperationQueue <OperationDelegate>

@property (readonly) SurrogateArray<OperationDelegate> *delegates;

@end










@interface OperationTask : NSObject <NSProgressReporting>

@property (readonly) BOOL cancelled;
@property (readonly) NSProgress *progress;

- (void)cancel;

@end
