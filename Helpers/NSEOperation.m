//
//  NSEOperation.m
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEOperation.h"
#import "NSEOrderedSet.h"
#import "NSEObject.h"



@interface NSEOperation ()

@property NSEOrderedSet<NSEOperationDelegate> *delegates;
@property NSMutableArray<NSError *> *errors;
@property NSProgress *progress;
@property NSOperationQueue *queue;
@property NSNotificationCenter *center;
@property NSRunLoop *loop;

@end



@implementation NSEOperation

NSErrorDomain const NSEOperationErrorDomain = @"NSEOperation";

+ (instancetype)nseShared {
    static NSEOperation *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

- (instancetype)init {
    self = super.init;
    if (self) {
        self.isReady = YES;
        
        self.delegates = (NSEOrderedSet<NSEOperationDelegate> *)NSEOrderedSet.weakOrderedSet;
        self.delegates.queue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
        
        self.errors = NSMutableArray.array;
        self.progress = NSProgress.new;
        self.queue = NSOperationQueue.new;
        self.center = NSNotificationCenter.defaultCenter;
        self.loop = NSRunLoop.mainRunLoop;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)start {
    if (self.isCancelled) {
        self.isFinished = YES;
        [self updateState:NSEOperationStateDidFinish];
    } else {
        self.isExecuting = YES;
        [self updateState:NSEOperationStateDidStart];
        if (self.isAsynchronous) {
            [NSThread detachNewThreadWithBlock:^{
                [self main];
            }];
        } else {
            [self main];
        }
    }
}

- (void)main {
    [self finish];
}

- (void)cancel {
    self.isCancelled = YES;
    
    [self.operation cancel];
    
    [self updateState:NSEOperationStateDidCancel];
}

- (void)finish {
    self.isExecuting = NO;
    self.isFinished = YES;
    [self updateState:NSEOperationStateDidFinish];
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

- (NSEOperation *)parent {
    return self.delegates[1][0];
}

#pragma mark - Helpers

- (void)updateState:(NSEOperationState)state {
    self.state = state;
    
    [self.delegates nseOperationDidUpdateState:self];
    [self.delegates.queue nseInvokeBlock:self.stateBlock];
    if (self.state == NSEOperationStateDidStart) {
        [self.delegates nseOperationDidStart:self];
    } else if (self.state == NSEOperationStateDidCancel) {
        [self.delegates nseOperationDidCancel:self];
    } else if (self.state == NSEOperationStateDidFinish) {
        [self.delegates nseOperationDidFinish:self];
        [self.delegates.queue nseInvokeBlock:self.completionBlock];
        
        self.stateBlock = nil;
        self.progressBlock = nil;
        self.completionBlock = nil;
        
        [self.center removeObserver:self];
    }
}

- (void)updateProgress:(int64_t)completedUnitCount {
    self.progress.completedUnitCount = completedUnitCount;
    
    [self.delegates nseOperationDidUpdateProgress:self];
    [self.delegates.queue nseInvokeBlock:self.progressBlock];
}

- (void)addOperation:(NSEOperation *)operation {
    [operation.delegates addObject:self.delegates];
    [self.queue addOperation:operation];
}

@end
