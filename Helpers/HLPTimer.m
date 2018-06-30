//
//  HLPTimer.m
//  Helpers
//
//  Created by Dan Kalinin on 5/20/18.
//

#import "HLPTimer.h"










@interface HLPTick ()

@property NSTimeInterval interval;

@end



@implementation HLPTick

- (instancetype)initWithInterval:(NSTimeInterval)interval {
    self = super.init;
    if (self) {
        self.interval = interval;
        
        dispatch_group_enter(self.group);
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    dispatch_group_wait(self.group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)));
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    dispatch_group_leave(self.group);
}

@end










@interface HLPTimer ()

@property NSTimeInterval interval;
@property NSUInteger repeats;

@property (weak) HLPTick *tick;

@end



@implementation HLPTimer

@dynamic delegates;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats {
    self = super.init;
    if (self) {
        self.interval = interval;
        self.repeats = repeats;
        
        self.progress.totalUnitCount = repeats;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    for (uint64_t completedUnitCount = 0; completedUnitCount < self.repeats; completedUnitCount++) {
        [self updateProgress:completedUnitCount];
        
        self.tick = [self tickWithInterval:self.interval];
        [self.tick waitUntilFinished];
    }
    
    [self updateProgress:self.repeats];
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.tick cancel];
}

- (HLPTick *)tickWithInterval:(NSTimeInterval)interval {
    HLPTick *tick = [HLPTick.alloc initWithInterval:interval];
    [self addOperation:tick];
    return tick;
}

- (HLPTick *)tickWithInterval:(NSTimeInterval)interval completion:(HLPVoidBlock)completion {
    HLPTick *tick = [self tickWithInterval:interval];
    tick.completionBlock = completion;
    return tick;
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates HLPTimerDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates HLPTimerDidBegin:self];
    } else if (state == HLPOperationStateDidCancel) {
        [self.delegates HLPTimerDidCancel:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates HLPTimerDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates HLPTimerDidUpdateProgress:self];
}

@end










@interface HLPClock ()

@end



@implementation HLPClock

+ (instancetype)shared {
    static HLPClock *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

- (HLPTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats {
    HLPTimer *timer = [HLPTimer.alloc initWithInterval:interval repeats:repeats];
    [self addOperation:timer];
    return timer;
}

- (HLPTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats completion:(HLPVoidBlock)completion {
    HLPTimer *timer = [self timerWithInterval:interval repeats:repeats];
    timer.completionBlock = completion;
    return timer;
}

@end
