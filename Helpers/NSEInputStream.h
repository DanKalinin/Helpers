//
//  NSEInputStream.h
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import "NSEStream.h"

@class NSEInputStream;
@class NSEInputStreamOperation;

@protocol NSEInputStreamDelegate;










@interface NSInputStream (NSE)

@property (readonly) NSEInputStreamOperation *nseOperation;

@end










@interface NSEInputStream : NSInputStream

@end










@protocol NSEInputStreamDelegate <NSEStreamDelegate>

@optional
- (void)nseInputStreamOpenCompleted:(NSInputStream *)inputStream;
- (void)nseInputStreamHasBytesAvailable:(NSInputStream *)inputStream;
- (void)nseInputStreamErrorOccurred:(NSInputStream *)inputStream;
- (void)nseInputStreamEndEncountered:(NSInputStream *)inputStream;

@end



@interface NSEInputStreamOperation : NSEStreamOperation <NSEInputStreamDelegate>

@property (readonly) NSEOrderedSet<NSEInputStreamDelegate> *delegates;

@property (weak, readonly) NSInputStream *object;

@end
