//
//  HLPTimer.h
//  Helpers
//
//  Created by Dan Kalinin on 5/20/18.
//

#import <Helpers/Helpers.h>

@class HLPTimer;



@protocol HLPTimerDelegate <HLPOperationDelegate>

@optional
- (void)timerDidUpdateState:(HLPTimer *)timer;
- (void)timerDidUpdateProgress:(HLPTimer *)timer;

- (void)timerDidBegin:(HLPTimer *)timer;
- (void)timerDidEnd:(HLPTimer *)timer;

@end



@interface HLPTimer : HLPOperation <HLPTimerDelegate>

@property (readonly) SurrogateArray<HLPTimerDelegate> *delegates;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSUInteger repeats;
@property (readonly) NSTimer *timer;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;

@end
