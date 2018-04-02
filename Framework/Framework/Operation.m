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
@property NSMutableArray<NSNumber *> *states;
@property NSMutableArray<NSError *> *errors;
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
        
        self.states = NSMutableArray.array;
        self.errors = NSMutableArray.array;
        
        self.progress = NSProgress.new;
    }
    return self;
}

- (void)resume {
    self.queue = NSOperationQueue.new;
    [self.queue addOperation:self];
}

#pragma mark - Accessors

- (id)parent {
    return self.delegates[1][0];
}

- (void)setError:(NSError *)error {
    _error = error;
    [self.errors addObject:error];
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    self.state = state;
    [self.states addObject:@(state)];
    
    [self.delegates operationDidUpdateState:self];
    if (state == OperationStateDidBegin) {
        [self.delegates operationDidBegin:self];
    } else if (state == OperationStateDidEnd) {
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
