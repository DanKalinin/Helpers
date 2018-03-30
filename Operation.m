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
@property NSProgress *progress;

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

- (void)main {
    [self updateState:OperationStateBegin];
    [self updateProgress:0];
}

#pragma mark - Accessors

- (OperationQueue *)queue {
    return self.delegates[1][0];
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    self.state = state;
    [self.delegates operationDidUpdateState:self];
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

@end










@interface OperationTask ()

@property NSProgress *progress;
@property BOOL cancelled;

@end



@implementation OperationTask

- (instancetype)init {
    self = super.init;
    if (self) {
        self.progress = NSProgress.new;
    }
    return self;
}

- (void)cancel {
    self.cancelled = YES;
}

@end
