//
//  HLPStream.h
//  Helpers
//
//  Created by Dan Kalinin on 3/5/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPOperation.h"
#import "HLPTimer.h"

@class HLPStreamOpening, HLPStreamClosing, HLPStreamReading, HLPStreamWriting, HLPStream, HLPInputStream, HLPOutputStream;
@class HLPStreamsOpening, HLPStreamsClosing, HLPStreams;

extern NSErrorDomain const HLPStreamErrorDomain;

NS_ERROR_ENUM(HLPStreamErrorDomain) {
    HLPStreamErrorUnknown,
    HLPStreamErrorNotOpen,
    HLPStreamErrorTimeout
};










@protocol HLPStreamOpeningDelegate <HLPOperationDelegate>

@end



@interface HLPStreamOpening : HLPOperation <HLPStreamOpeningDelegate>

@property (readonly) HLPStream *parent;
@property (readonly) HLPArray<HLPStreamOpeningDelegate> *delegates;
@property (readonly) NSTimeInterval timeout;
@property (readonly) HLPTimer *timer;
@property (readonly) HLPStreamClosing *closing;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamClosingDelegate <HLPOperationDelegate>

@end



@interface HLPStreamClosing : HLPOperation <HLPStreamClosingDelegate>

@property (readonly) HLPStream *parent;
@property (readonly) HLPArray<HLPStreamClosingDelegate> *delegates;

@end










@protocol HLPStreamReadingDelegate <HLPOperationDelegate>

@end



@interface HLPStreamReading : HLPOperation <HLPStreamReadingDelegate>

@property (readonly) HLPInputStream *parent;
@property (readonly) HLPArray<HLPStreamReadingDelegate> *delegates;
@property (readonly) NSMutableData *data;
@property (readonly) NSUInteger minLength;
@property (readonly) NSUInteger maxLength;
@property (readonly) NSTimeInterval timeout;
@property (readonly) HLPTimer *timer;

- (instancetype)initWithData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamWritingDelegate <HLPOperationDelegate>

@end



@interface HLPStreamWriting : HLPOperation <HLPStreamWritingDelegate>

@property (readonly) HLPOutputStream *parent;
@property (readonly) HLPArray<HLPStreamWritingDelegate> *delegates;
@property (readonly) NSMutableData *data;
@property (readonly) NSTimeInterval timeout;
@property (readonly) HLPTimer *timer;

- (instancetype)initWithData:(NSMutableData *)data timeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamDelegate <HLPStreamOpeningDelegate, HLPStreamClosingDelegate>

@end



@interface HLPStream : HLPOperationQueue <HLPStreamDelegate>

@property (readonly) HLPArray<HLPStreamDelegate> *delegates;
@property (readonly) NSStream *stream;

- (instancetype)initWithStream:(NSStream *)stream;

- (HLPStreamOpening *)openWithTimeout:(NSTimeInterval)timeout;
- (HLPStreamOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

- (HLPStreamClosing *)close;
- (HLPStreamClosing *)closeWithCompletion:(HLPVoidBlock)completion;

@end










@protocol HLPInputStreamDelegate <HLPStreamDelegate, HLPStreamReadingDelegate>

@end



@interface HLPInputStream : HLPStream <HLPInputStreamDelegate>

@property (readonly) HLPArray<HLPInputStreamDelegate> *delegates;
@property (readonly) NSInputStream *stream;

- (HLPStreamReading *)readData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout;
- (HLPStreamReading *)readData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol HLPOutputStreamDelegate <HLPStreamDelegate, HLPStreamWritingDelegate>

@end



@interface HLPOutputStream : HLPStream <HLPOutputStreamDelegate>

@property (readonly) HLPArray<HLPOutputStreamDelegate> *delegates;
@property (readonly) NSOutputStream *stream;

- (HLPStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout;
- (HLPStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol HLPStreamsOpeningDelegate <HLPStreamOpeningDelegate>

@end



@interface HLPStreamsOpening : HLPOperation <HLPStreamsOpeningDelegate>

@property (readonly) HLPStreams *parent;
@property (readonly) HLPArray<HLPStreamsOpeningDelegate> *delegates;
@property (readonly) NSTimeInterval timeout;
@property (readonly) HLPStreamOpening *opening;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamsClosingDelegate <HLPStreamClosingDelegate>

@end



@interface HLPStreamsClosing : HLPOperation <HLPStreamsClosingDelegate>

@property (readonly) HLPStreams *parent;
@property (readonly) HLPArray<HLPStreamsClosingDelegate> *delegates;
@property (readonly) HLPStreamClosing *closing;

@end










@protocol HLPStreamsDelegate <HLPInputStreamDelegate, HLPOutputStreamDelegate>

@end



@interface HLPStreams : HLPOperationQueue <HLPStreamsDelegate>

@property (readonly) HLPArray<HLPStreamsDelegate> *delegates;
@property (readonly) HLPInputStream *input;
@property (readonly) HLPOutputStream *output;

+ (instancetype)streamsWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
+ (instancetype)streamsToHost:(NSString *)host port:(NSInteger)port;
+ (instancetype)streamsWithComponents:(NSURLComponents *)components;

- (instancetype)initWithInput:(HLPInputStream *)input output:(HLPOutputStream *)output;

- (HLPStreamsOpening *)openWithTimeout:(NSTimeInterval)timeout;
- (HLPStreamsOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

- (HLPStreamsClosing *)close;
- (HLPStreamsClosing *)closeWithCompletion:(HLPVoidBlock)completion;

@end
