//
//  Operation.m
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import "Operation.h"










@interface Operation ()

@property SurrogateArray<OperationDelegate> *delegates;
@property OperationState state;
@property OperationState previousState;
@property NSProgress *progress;
@property NSOperationQueue *queue;

@end



@implementation Operation

- (instancetype)init {
    self = super.init;
    if (self) {
        self.delegates = (id)SurrogateArray.new;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
        
        self.progress = NSProgress.new;
    }
    return self;
}

- (void)start {
    self.queue = NSOperationQueue.new;
    [self.queue addOperation:self];
}

#pragma mark - Accessors

- (id)parent {
    return self.delegates[1][0];
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    self.previousState = self.state;
    self.state = state;
    [self.delegates operationDidUpdateState:self];
    
    if (state == OperationStateBegin) {
        [self.delegates operationDidBegin:self];
    } else if (state == OperationStateProcess) {
        [self.delegates operationDidProcess:self];
    } else {
        [self.delegates operationDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    self.progress.completedUnitCount = completedUnitCount;
    [self.delegates opertionDidUpdateProgress:self];
}

@end










@interface OperationQueue ()

@property SurrogateArray<OperationDelegate> *delegates;

@end



@implementation OperationQueue

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
    
    operation.delegates.operationQueue = self.delegates.operationQueue;
    [operation.delegates addObject:self.delegates];
}

@end
