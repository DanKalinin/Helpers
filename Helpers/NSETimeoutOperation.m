//
//  NSETimeoutOperation.m
//  Helpers
//
//  Created by Dan Kalinin on 10/14/18.
//

#import "NSETimeoutOperation.h"



@interface NSETimeoutOperation ()

@property NSTimeInterval timeout;
@property NSETimer *timer;

@end



@implementation NSETimeoutOperation

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
    [self.timer.delegates addObject:self];
}

#pragma mark - Timer

-(void)NSETimerDidFinish:(NSETimer *)timer {
    if (self.isFinished) {
    } else {
        NSError *error = [NSError errorWithDomain:NSEOperationErrorDomain code:NSEOperationErrorTimeout userInfo:nil];
        [self.errors addObject:error];
        
        [self finish];
    }
}

@end
