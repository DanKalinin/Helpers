//
//  HLPOperation.m
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import "HLPOperation.h"










@interface HLPOperation ()

@property SurrogateArray<HLPOperationDelegate> *delegates;
@property NSMutableArray<NSNumber *> *states;
@property NSMutableArray<NSError *> *errors;
@property NSProgress *progress;
@property NSOperationQueue *operationQueue;
@property dispatch_group_t group;

@end



@implementation HLPOperation

+ (instancetype)shared {
    static HLPOperation *shared = nil;
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

- (void)cancel {
    [super cancel];
    
    [self updateState:HLPOperationStateDidCancel];
}

#pragma mark - Accessors

- (id)parent {
    return self.delegates[1][0];
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [self.states addObject:@(state)];
    
    [self.delegates HLPOperationDidUpdateState:self];
    [self invokeHandler:self.stateBlock queue:self.delegates.operationQueue];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates HLPOperationDidBegin:self];
    } else if (state == HLPOperationStateDidCancel) {
        [self.delegates HLPOperationDidCancel:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates HLPOperationDidEnd:self];
        [self invokeHandler:self.completionBlock queue:self.delegates.operationQueue];
        
        self.stateBlock = nil;
        self.progressBlock = nil;
        self.completionBlock = nil;
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    self.progress.completedUnitCount = completedUnitCount;
    
    [self.delegates HLPOperationDidUpdateProgress:self];
    [self invokeHandler:self.progressBlock queue:self.delegates.operationQueue];
}

- (void)addOperation:(HLPOperation *)operation {
    [self.operationQueue addOperation:operation];
    
    [operation.delegates addObject:self.delegates];
}

@end










@interface HLPOperationQueue ()

@property SurrogateArray<HLPOperationDelegate> *delegates;

@end



@implementation HLPOperationQueue

+ (instancetype)shared {
    static HLPOperationQueue *shared = nil;
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

- (void)addOperation:(HLPOperation *)operation {
    [super addOperation:operation];
    
    [operation.delegates addObject:self.delegates];
}

#pragma mark - Accessors

- (HLPOperation *)operation {
    return self.operations.firstObject;
}

@end
