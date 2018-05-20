//
//  Timer.h
//  Helpers
//
//  Created by Dan Kalinin on 5/20/18.
//

#import <Helpers/Helpers.h>

@class Timer;



@protocol TimerDelegate <OperationDelegate>

@optional
- (void)timerDidUpdateState:(Timer *)timer;
- (void)timerDidUpdateProgress:(Timer *)timer;

- (void)timerDidBegin:(Timer *)timer;
- (void)timerDidEnd:(Timer *)timer;

@end



@interface Timer : Operation <TimerDelegate>

@property (readonly) SurrogateArray<TimerDelegate> *delegates;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSUInteger repeats;
@property (readonly) NSTimer *timer;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;

@end
