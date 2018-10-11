//
//  HLPOperation.m
//  Helpers
//
//  Created by Dan Kalinin on 3/30/18.
//

#import "HLPOperation.h"










@interface HLPOperation ()

@property HLPArray<HLPOperationDelegate> *delegates;
@property NSMutableArray<NSNumber *> *states;
@property NSMutableArray<NSError *> *errors;
@property NSProgress *progress;
@property NSOperationQueue *operationQueue;
@property NSNotificationCenter *notificationCenter;
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
        self.delegates = (id)HLPArray.weakArray;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
        
        self.states = NSMutableArray.array;
        self.errors = NSMutableArray.array;
        
        self.progress = NSProgress.new;
        
        self.operationQueue = NSOperationQueue.new;
        
        self.notificationCenter = NSNotificationCenter.defaultCenter;
        
        self.group = dispatch_group_create();
    }
    return self;
}

- (void)cancel {
    if (self.cancelled) return;
    
    [super cancel];
    
    [self.operation cancel];
    [self.operationQueue cancelAllOperations];
    
    [self updateState:HLPOperationStateDidCancel];
}

- (void)stop {
    [self.notificationCenter removeObserver:self];
    
    [self updateState:HLPOperationStateDidEnd];
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

@property HLPArray<HLPOperationDelegate> *delegates;

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
        self.delegates = (id)HLPArray.weakArray;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
    }
    return self;
}

- (void)addOperation:(HLPOperation *)operation {
    [super addOperation:operation];
    
    [operation.delegates addObject:self.delegates];
}

@end










@implementation NSOperationQueue (HLP)

- (void)addOperationWithBlockAndWait:(HLPVoidBlock)block {
    if ([self isEqual:NSOperationQueue.currentQueue]) {
        block();
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
        [self addOperation:operation];
        [operation waitUntilFinished];
    }
}

@end










@interface NSEOperation ()

@end



@implementation NSEOperation

- (instancetype)init {
    self = super.init;
    if (self) {
        self.isReady = YES;
    }
    return self;
}

- (void)start {
    if (self.cancelled) {
        self.isFinished = YES;
    } else {
        self.isExecuting = YES;
        [self main];
    }
}

- (void)main {
    NSLog(@"executing - %i", self.isExecuting);
    
    [self finish];
}

- (void)cancel {
    self.isCancelled = YES;
}

- (void)finish {
    self.isExecuting = NO;
    self.isFinished = YES;
}

#pragma mark - Accessors

- (void)setIsCancelled:(BOOL)isCancelled {
    [self willChangeValueForKey:NSStringFromSelector(@selector(isCancelled))];
    _isCancelled = isCancelled;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isCancelled))];
}

- (void)setIsExecuting:(BOOL)isExecuting {
    [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
}

- (void)setIsFinished:(BOOL)isFinished {
    [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    _isFinished = isFinished;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
}

- (void)setIsAsynchronous:(BOOL)isAsynchronous {
    [self willChangeValueForKey:NSStringFromSelector(@selector(isAsynchronous))];
    _isAsynchronous = isAsynchronous;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isAsynchronous))];
}

- (void)setIsReady:(BOOL)isReady {
    [self willChangeValueForKey:NSStringFromSelector(@selector(isReady))];
    _isReady = isReady;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isReady))];
}

@end
