//
//  NSEStream.h
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import <Foundation/Foundation.h>
#import "NSEObject.h"

@class NSEStream;
@class NSEStreamOperation;

@protocol NSEStreamDelegate;










@interface NSStream (NSE)

@property (readonly) NSEStreamOperation *nseOperation;

@end










@interface NSEStream : NSStream

@end










@protocol NSEStreamDelegate <NSEObjectDelegate>

@optional
- (void)nseStreamOpenCompleted:(NSStream *)stream;
- (void)nseStreamHasBytesAvailable:(NSStream *)stream;
- (void)nseStreamHasSpaceAvailable:(NSStream *)stream;
- (void)nseStreamErrorOccurred:(NSStream *)stream;
- (void)nseStreamEndEncountered:(NSStream *)stream;

@end



@interface NSEStreamOperation : NSEObjectOperation <NSEStreamDelegate, NSStreamDelegate>

@property (readonly) HLPArray<NSEStreamDelegate> *delegates;

@property (weak, readonly) NSStream *object;

@end
