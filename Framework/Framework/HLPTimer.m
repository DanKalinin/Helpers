//
//  HLPTimer.m
//  Helpers
//
//  Created by Dan Kalinin on 5/20/18.
//

#import "HLPTimer.h"



@interface HLPTimer ()

@property NSTimeInterval interval;
@property NSUInteger repeats;
@property NSTimer *timer;

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

- (void)start {
    [super start];
    
    [self updateState:OperationStateDidBegin];
    [self updateProgress:0];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval repeats:YES block:^(NSTimer *timer) {
        uint64_t completedUnitCount = self.progress.completedUnitCount + 1;
        [self updateProgress:completedUnitCount];
        
        if (completedUnitCount == self.repeats) {
            [timer invalidate];
            [self updateState:OperationStateDidEnd];
        }
    }];
}

- (void)cancel {
    [super cancel];
    
    [self.timer invalidate];
    [self updateState:OperationStateDidEnd];
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates timerDidUpdateState:self];
    if (state == OperationStateDidBegin) {
        [self.delegates timerDidBegin:self];
    } else if (state == OperationStateDidEnd) {
        [self.delegates timerDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates timerDidUpdateProgress:self];
}

@end
