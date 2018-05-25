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
- (void)HLPTimerDidUpdateState:(HLPTimer *)timer;
- (void)HLPTimerDidUpdateProgress:(HLPTimer *)timer;

- (void)HLPTimerDidBegin:(HLPTimer *)timer;
- (void)HLPTimerDidEnd:(HLPTimer *)timer;

@end



@interface HLPTimer : HLPOperation <HLPTimerDelegate>

@property (readonly) SurrogateArray<HLPTimerDelegate> *delegates;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSUInteger repeats;
@property (readonly) NSTimer *timer;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;

@end
