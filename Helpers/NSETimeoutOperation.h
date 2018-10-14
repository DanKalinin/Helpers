//
//  NSETimeoutOperation.h
//  Helpers
//
//  Created by Dan Kalinin on 10/14/18.
//

#import "HLPOperation.h"
#import "HLPTimer.h"

@class NSETimeoutOperation;



@protocol NSETimeoutOperationDelegate <NSEOperationDelegate>

@end



@interface NSETimeoutOperation : NSEOperation <NSETimeoutOperationDelegate>

@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end
