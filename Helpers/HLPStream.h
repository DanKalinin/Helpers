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

@class HLPStreamOpening, HLPStreamReading, HLPStreamWriting, HLPStream, HLPInputStream, HLPOutputStream;
@class HLPStreamsOpening, HLPStreams;

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
@property (readonly) HLPTick *tick;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

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
@property (readonly) HLPTick *tick;

- (instancetype)initWithData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamWritingDelegate <HLPOperationDelegate>

@end



@interface HLPStreamWriting : HLPOperation <HLPStreamWritingDelegate>

@property (readonly) HLPOutputStream *parent;
@property (readonly) HLPArray<HLPStreamWritingDelegate> *delegates;
@property (readonly) NSMutableData *data;
@property (readonly) NSTimeInterval timeout;
@property (readonly) HLPTick *tick;

- (instancetype)initWithData:(NSMutableData *)data timeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamDelegate <HLPStreamOpeningDelegate>

@end



@interface HLPStream : HLPOperation <HLPStreamDelegate>

@property (readonly) HLPArray<HLPStreamDelegate> *delegates;
@property (readonly) NSStream *stream;

- (instancetype)initWithStream:(NSStream *)stream;

- (HLPStreamOpening *)openWithTimeout:(NSTimeInterval)timeout;
- (HLPStreamOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

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
@property (readonly) HLPStreamOpening *inputOpening;
@property (readonly) HLPStreamOpening *outputOpening;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end










@protocol HLPStreamsDelegate <HLPInputStreamDelegate, HLPOutputStreamDelegate>

@end



@interface HLPStreams : HLPOperation <HLPStreamsDelegate>

@property (readonly) HLPArray<HLPStreamsDelegate> *delegates;
@property (readonly) HLPInputStream *input;
@property (readonly) HLPOutputStream *output;

+ (instancetype)streamsWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
+ (instancetype)streamsToHost:(NSString *)host port:(NSInteger)port;
+ (instancetype)streamsWithComponents:(NSURLComponents *)components;

- (instancetype)initWithInput:(HLPInputStream *)input output:(HLPOutputStream *)output;

- (HLPStreamsOpening *)openWithTimeout:(NSTimeInterval)timeout;
- (HLPStreamsOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@class NSEStreamOpening;
@class NSEStream;

@class NSEStreamReading;
@class NSEInputStream;

@class NSEStreamWriting;
@class NSEOutputStream;

@class NSEStreamsOpening;
@class NSEStreams;

extern NSErrorDomain const NSEStreamErrorDomain;

NS_ERROR_ENUM(NSEStreamErrorDomain) {
    NSEStreamErrorUnknown,
    NSEStreamErrorTimeout,
    NSEStreamErrorAtEnd
};










@protocol NSEStreamOpeningDelegate <NSEOperationDelegate>

@end



@interface NSEStreamOpening : NSEOperation <NSEStreamOpeningDelegate>

@property (readonly) NSEStream *parent;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end










@protocol NSEStreamDelegate <NSEStreamOpeningDelegate, NSStreamDelegate>

@end



@interface NSEStream : NSEOperation <NSEStreamDelegate>

@property (weak) NSEStreamOpening *opening;

@property (readonly) HLPArray<NSEStreamDelegate> *delegates;
@property (readonly) NSStream *stream;

- (instancetype)initWithStream:(NSStream *)stream;

- (void)close;

- (NSEStreamOpening *)openWithTimeout:(NSTimeInterval)timeout;
- (NSEStreamOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol NSEStreamReadingDelegate <NSEOperationDelegate>

@end



@interface NSEStreamReading : NSEOperation <NSEStreamReadingDelegate>

@property (readonly) NSEInputStream *parent;
@property (readonly) NSUInteger minLength;
@property (readonly) NSUInteger maxLength;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) NSMutableData *data;

- (instancetype)initWithMinLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout;

@end










@protocol NSEInputStreamDelegate <NSEStreamReadingDelegate>

@end



@interface NSEInputStream : NSEStream <NSEInputStreamDelegate>

@property (weak) NSEStreamReading *reading;

@property (readonly) NSInputStream *stream;

- (NSEStreamReading *)readDataOfMinLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout;
- (NSEStreamReading *)readDataOfMinLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol NSEStreamWritingDelegate <NSEOperationDelegate>

@end



@interface NSEStreamWriting : NSEOperation <NSEStreamWritingDelegate>

@property (readonly) NSEOutputStream *parent;
@property (readonly) NSMutableData *data;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;

- (instancetype)initWithData:(NSMutableData *)data timeout:(NSTimeInterval)timeout;

@end










@protocol NSEOutputStreamDelegate <NSEStreamWritingDelegate>

@end



@interface NSEOutputStream : NSEStream <NSEOutputStreamDelegate>

@property (weak) NSEStreamWriting *writing;

@property (readonly) NSOutputStream *stream;

- (NSEStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout;
- (NSEStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol NSEStreamsOpeningDelegate <NSEOperationDelegate>

@end



@interface NSEStreamsOpening : NSEOperation <NSEStreamsOpeningDelegate>

@end










@protocol NSEStreamsDelegate <NSEStreamsOpeningDelegate>

@end



@interface NSEStreams : NSEOperation <NSEStreamsDelegate>

@property (readonly) NSEInputStream *input;
@property (readonly) NSEOutputStream *output;

- (instancetype)initWithInput:(NSEInputStream *)input output:(NSEOutputStream *)output;

@end
