//
//  Operation.h
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import <Foundation/Foundation.h>
#import "HLPMain.h"

@class Operation, GroupOperation, OperationQueue;

typedef NS_ENUM(NSUInteger, OperationState) {
    OperationStateDidBegin,
    OperationStateDidEnd
};










@protocol OperationDelegate <NSObject>

@optional
- (void)operationDidUpdateState:(Operation *)operation;
- (void)opertionDidUpdateProgress:(Operation *)operation;

- (void)operationDidBegin:(Operation *)operation;
- (void)operationDidEnd:(Operation *)operation;

@end



@interface Operation : NSOperation <OperationDelegate, NSProgressReporting>

@property (copy) VoidBlock stateBlock;
@property (copy) VoidBlock progressBlock;

@property (readonly) id parent;
@property (readonly) SurrogateArray<OperationDelegate> *delegates;
@property (readonly) NSMutableArray<NSNumber *> *states;
@property (readonly) NSMutableArray<NSError *> *errors;
@property (readonly) NSProgress *progress;
@property (readonly) NSOperationQueue *operationQueue;
@property (readonly) dispatch_group_t group;

+ (instancetype)shared;

- (void)updateState:(OperationState)state;
- (void)updateProgress:(uint64_t)completedUnitCount;
- (void)addOperation:(Operation *)operation;

@end










@interface OperationQueue : NSOperationQueue <OperationDelegate>

@property (readonly) __kindof Operation *operation;
@property (readonly) SurrogateArray<OperationDelegate> *delegates;

+ (instancetype)shared;

@end
