//
//  HLPTimer.h
//  Helpers
//
//  Created by Dan Kalinin on 5/20/18.
//

#import <Foundation/Foundation.h>
#import "HLPOperation.h"

@class HLPTick, HLPTimer, HLPClock;










@protocol HLPTickDelegate <HLPOperationDelegate>

@end



@interface HLPTick : HLPOperation <HLPTickDelegate>

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

@property (readonly) HLPClock *parent;
@property (readonly) HLPArray<HLPTimerDelegate> *delegates;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSUInteger repeats;
@property (readonly) HLPTick *tick;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;

@end










@protocol HLPClockDelegate <HLPTimerDelegate>

@end



@interface HLPClock : HLPOperationQueue <HLPClockDelegate>

- (HLPTick *)tickWithInterval:(NSTimeInterval)interval;
- (HLPTick *)tickWithInterval:(NSTimeInterval)interval completion:(HLPVoidBlock)completion;

- (HLPTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;
- (HLPTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats completion:(HLPVoidBlock)completion;

@end




















@class NSETimer;
@class NSEClock;










@protocol NSETimerDelegate <NSEOperationDelegate>

@end



@interface NSETimer : NSEOperation <NSETimerDelegate>

@property (readonly) HLPArray<NSETimerDelegate> *delegates;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSUInteger repeats;

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;

@end










@protocol NSEClockDelegate <NSETimerDelegate>

@end



@interface NSEClock : NSEOperation <NSEClockDelegate>

- (NSETimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats;
- (NSETimer *)timerWithInterval:(NSTimeInterval)interval repeats:(NSUInteger)repeats completion:(HLPVoidBlock)completion;

@end
