//
//  HLPTimer.h
//  Helpers
//
//  Created by Dan Kalinin on 5/20/18.
//

#import <Helpers/Helpers.h>

@class HLPTick, HLPTimer, HLPClock;










@interface HLPTick : HLPOperation

@property (readonly) NSTimeInterval interval;

- (instancetype)initWithInterval:(NSTimeInterval)interval;

@end










@protocol HLPTimerDelegate <HLPOperationDelegate>

@optional
- (void)HLPTimerDidUpdateState:(HLPTimer *)timer;
- (void)HLPTimerDidUpdateProgress:(HLPTimer *)timer;

- (void)HLPTimerDidBegin:(HLPTimer *)timer;
- (void)HLPTimerDidCancel:(HLPTimer *)timer;
- (void)HLPTimerDidEnd:(HLPTimer *)timer;

@end



@interface HLPTimer : HLPOperation <HLPTimerDelegate>

@property (readonly) HLPArray<HLPTimerDelegate> *delegates;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSUInteger repeats;

@property (weak, readonly) HLPTick *tick;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;

- (HLPTick *)tickWithInterval:(NSTimeInterval)interval;
- (HLPTick *)tickWithInterval:(NSTimeInterval)interval completion:(HLPVoidBlock)completion;

@end










@protocol HLPClockDelegate <HLPTimerDelegate>

@end



@interface HLPClock : HLPOperationQueue <HLPClockDelegate>

- (HLPTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;
- (HLPTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats completion:(HLPVoidBlock)completion;

@end
