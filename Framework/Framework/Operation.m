//
//  Operation.m
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import "Operation.h"










@interface Operation ()

@property SurrogateArray<OperationDelegate> *delegates;
@property NSMutableArray<NSNumber *> *states;
@property NSMutableArray<NSError *> *errors;
@property NSProgress *progress;
@property NSOperationQueue *operationQueue;
@property dispatch_group_t group;

@end



@implementation Operation

+ (instancetype)shared {
    static Operation *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

- (instancetype)init {
    self = super.init;
    if (self) {
        self.delegates = (id)SurrogateArray.new;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
        
        self.states = NSMutableArray.array;
        self.errors = NSMutableArray.array;
        
        self.progress = NSProgress.new;
        
        self.operationQueue = NSOperationQueue.new;
        
        self.group = dispatch_group_create();
    }
    return self;
}

#pragma mark - Accessors

- (id)parent {
    return self.delegates[1][0];
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [self.states addObject:@(state)];
    
    [self.delegates operationDidUpdateState:self];
    [self invokeHandler:self.stateBlock queue:self.delegates.operationQueue];
    if (state == OperationStateDidBegin) {
        [self.delegates operationDidBegin:self];
    } else if (state == OperationStateDidEnd) {
        [self.delegates operationDidEnd:self];
        [self invokeHandler:self.completionBlock queue:self.delegates.operationQueue];
        
        self.stateBlock = nil;
        self.progressBlock = nil;
        self.completionBlock = nil;
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    self.progress.completedUnitCount = completedUnitCount;
    
    [self.delegates opertionDidUpdateProgress:self];
    [self invokeHandler:self.progressBlock queue:self.delegates.operationQueue];
}

- (void)addOperation:(Operation *)operation {
    [self.operationQueue addOperation:operation];
    
    [operation.delegates addObject:self.delegates];
}

@end










@interface OperationQueue ()

@property SurrogateArray<OperationDelegate> *delegates;

@end



@implementation OperationQueue

+ (instancetype)shared {
    static OperationQueue *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

- (instancetype)init {
    self = super.init;
    if (self) {
        self.delegates = (id)SurrogateArray.new;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
    }
    return self;
}

- (void)addOperation:(Operation *)operation {
    [super addOperation:operation];
    
    [operation.delegates addObject:self.delegates];
}

#pragma mark - Accessors

- (Operation *)operation {
    return self.operations.firstObject;
}

@end
