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










//@protocol HLPStreamsDelegate <HLPStreamOpeningDelegate, HLPStreamClosingDelegate, HLPStreamReadingDelegate, HLPStreamWritingDelegate>
//
//@end
//
//
//
//@interface HLPStreams : HLPOperationQueue <HLPStreamsDelegate>
//
//@property (readonly) NSInputStream *input;
//@property (readonly) NSOutputStream *output;
//
//- (instancetype)initWithInput:(NSInputStream *)input output:(NSOutputStream *)output;
//
//- (HLPStreamOpening *)openStream:(NSStream *)stream;
//- (HLPStreamOpening *)openStream:(NSStream *)stream completion:(HLPVoidBlock)completion;
//
//- (HLPStreamClosing *)closeStream:(NSStream *)stream;
//- (HLPStreamClosing *)closeStream:(NSStream *)stream completion:(HLPVoidBlock)completion;
//
//- (HLPStreamReading *)readData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout;
//- (HLPStreamReading *)readData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (HLPStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout;
//- (HLPStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//@end










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




































@interface HLPStreamMessage : HLPObject

@property NSMutableData *data;

- (NSInteger)readFromInput:(NSInputStream *)input;
- (NSInteger)writeToOutput:(NSOutputStream *)output;

@end










@interface NSInputStream (HLP)

- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length all:(BOOL)all;
- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator;

@end










@interface NSOutputStream (HLP)

- (NSInteger)write:(NSMutableData *)data all:(BOOL)all;

@end













//#import <Foundation/Foundation.h>
//#import "Main.h"
//#import "HLPObject.h"
//#import "HLPOperation.h"
//
//@class HLPStreamMessage, HLPStreamLoad, HLPStreamPair, HLPStreamEndpoint, HLPStreamClient, HLPStreamServer;
//
//typedef void (^HLPStreamMessageErrorBlock)(__kindof HLPStreamMessage *message, NSError *error);
//
//extern const HLPOperationState HLPStreamPairStateDidOpen;
//
//extern const HLPOperationState HLPStreamLoadStateDidInit;
//extern const HLPOperationState HLPStreamLoadStateDidProcess;
//
//extern NSErrorDomain const HLPStreamErrorDomain;
//
//NS_ERROR_ENUM(HLPStreamErrorDomain) {
//    HLPStreamErrorUnknown = 0,
//    HLPStreamErrorTimedOut = 1,
//    HLPStreamErrorClosed = 2,
//    HLPStreamErrorCancelled = 3
//};
//
//typedef NS_ENUM(NSUInteger, HLPStreamLoadOperation) {
//    HLPStreamLoadOperationUp = 1,
//    HLPStreamLoadOperationDown = 2
//};
//
//
//
//
//
//
//
//
//
//
//@interface HLPStreamMessage : HLPObject
//
//@property BOOL reply;
//@property NSUInteger serial;
//@property NSUInteger replySerial;
//@property HLPStreamMessageErrorBlock completion;
//@property NSTimer *timer;
//
//- (NSInteger)readFromStream:(NSInputStream *)inputStream;
//- (NSInteger)writeToStream:(NSOutputStream *)outputStream;
//
//@end
//
//
//
//
//
//
//
//
//
//
//@protocol HLPStreamLoadDelegate <HLPOperationDelegate>
//
//@optional
//- (void)HLPStreamLoadDidUpdateState:(HLPStreamLoad *)load;
//- (void)HLPStreamLoadDidUpdateProgress:(HLPStreamLoad *)load;
//
//- (void)HLPStreamLoadDidBegin:(HLPStreamLoad *)load;
//- (void)HLPStreamLoadDidInit:(HLPStreamLoad *)load;
//- (void)HLPStreamLoadDidProcess:(HLPStreamLoad *)load;
//- (void)HLPStreamLoadDidEnd:(HLPStreamLoad *)load;
//
//@end
//
//
//
//@interface HLPStreamLoad : HLPOperation <HLPStreamLoadDelegate>
//
//@property (readonly) __kindof HLPStreamPair *parent;
//@property (readonly) HLPArray<HLPStreamLoadDelegate> *delegates;
//@property (readonly) HLPStreamLoadOperation operation;
//@property (readonly) NSMutableData *data;
//@property (readonly) NSString *path;
//
//- (instancetype)initWithOperation:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path;
//
//@end
//
//
//
//
//
//
//
//
//
//
//@protocol HLPStreamPairDelegate <HLPStreamLoadDelegate>
//
//@optional
//- (void)HLPStreamPairDidUpdateState:(HLPStreamPair *)pair;
//
//- (void)HLPStreamPairDidBegin:(HLPStreamPair *)pair;
//- (void)HLPStreamPairDidOpen:(HLPStreamPair *)pair;
//- (void)HLPStreamPairDidEnd:(HLPStreamPair *)pair;
//
//- (void)HLPStreamPair:(HLPStreamPair *)pair didReceiveData:(NSData *)data;
//- (void)HLPStreamPair:(HLPStreamPair *)pair didReceiveMessage:(HLPStreamMessage *)message;
//
//@end
//
//
//
//@interface HLPStreamPair : HLPOperation <HLPStreamPairDelegate>
//
//@property Class messageClass;
//@property NSTimeInterval timeout;
//@property Proto protocol;
//@property id object;
//
//@property (readonly) HLPStreamEndpoint *parent;
//@property (readonly) HLPStreamClient *client;
//@property (readonly) HLPStreamServer *server;
//@property (readonly) HLPArray<HLPStreamPairDelegate> *delegates;
//@property (readonly) NSInputStream *inputStream;
//@property (readonly) NSOutputStream *outputStream;
//@property (readonly) Sequence *sequence;
//@property (readonly) NSMutableDictionary<NSNumber *, HLPStreamMessage *> *messages;
//
//@property Class loadClass;
//@property NSUInteger loadChunk;
//@property NSURL *loadDirectory;
//
//@property (readonly) Sequence *loadSequence;
//@property (readonly) NSMutableDictionary<NSNumber *, NSMutableData *> *loadData;
//
//- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
//- (void)writeMessage:(HLPStreamMessage *)message completion:(HLPStreamMessageErrorBlock)completion;
//- (__kindof HLPStreamMessage *)writeMessage:(HLPStreamMessage *)message error:(NSError **)error;
//
//- (__kindof HLPStreamLoad *)load:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path;
//- (__kindof HLPStreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path;
//- (__kindof HLPStreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path;
//
//- (__kindof HLPStreamLoad *)load:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path completion:(HLPVoidBlock)completion;
//- (__kindof HLPStreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path completion:(HLPVoidBlock)completion;
//- (__kindof HLPStreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path completion:(HLPVoidBlock)completion;
//
//@end
//
//
//
//
//
//
//
//
//
//
//@protocol HLPStreamEndpointDelegate <HLPStreamPairDelegate>
//
//@end
//
//
//
//@interface HLPStreamEndpoint : HLPOperationQueue <HLPStreamPairDelegate>
//
//@property Class pairClass;
//
//@property (readonly) HLPArray<HLPStreamEndpointDelegate> *delegates;
//
//- (instancetype)initWithPair:(Class)pair;
//- (__kindof HLPStreamPair *)pairWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface HLPStreamClient : HLPStreamEndpoint
//
//@property (readonly) __kindof HLPStreamPair *operation;
//
//- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream pair:(Class)pair;
//- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair;
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface HLPStreamServer : HLPStreamEndpoint
//
//@property (readonly, copy) NSArray<__kindof HLPStreamPair *> *operations;
//
//- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair;
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface NSStream (HLP)
//
//@end
//
//
//
//@interface NSInputStream (HLP)
//
//- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length;
//- (NSInteger)readAll:(NSMutableData *)data; // -> + - EOF, -1 - error
//- (NSInteger)readLine:(NSMutableData *)data;
//- (NSInteger)read:(NSMutableData *)data exactly:(NSUInteger)length;
//- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator;
//
//@end
//
//
//
//@interface NSOutputStream (HLP)
//
//- (NSInteger)write:(NSMutableData *)data;
//- (NSInteger)writeAll:(NSMutableData *)data;
//- (NSInteger)writeLines:(NSMutableArray<NSMutableData *> *)lines;
//- (NSInteger)writeChunks:(NSMutableArray<NSMutableData *> *)chunks separator:(NSData *)separator;
//
//@end
