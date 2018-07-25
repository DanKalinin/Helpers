//
//  HLPRPC.h
//  Helpers
//
//  Created by Dan Kalinin on 7/20/18.
//

#import <Foundation/Foundation.h>
#import "HLPStream.h"

@class HLPRPCPayload, HLPRPCPayloadReading, HLPRPCPayloadWriting, HLPRPCMessageSending, HLPRPCMessageReceiving, HLPRPCResponseSending, HLPRPC;

extern NSErrorDomain const HLPRPCErrorDomain;

NS_ERROR_ENUM(HLPRPCErrorDomain) {
    HLPRPCErrorUnknown,
    HLPRPCErrorTimeout
};










@interface HLPRPCPayload : HLPObject

@property NSString *serial;
@property NSString *responseSerial;
@property BOOL needsResponse;
@property id message;
@property id response;
@property NSError *error;

@end










@protocol HLPRPCPayloadReadingDelegate <HLPOperationDelegate>

@end



@interface HLPRPCPayloadReading : HLPOperation <HLPRPCPayloadReadingDelegate>

@property (readonly) HLPRPC *parent;
@property (readonly) HLPArray<HLPRPCPayloadReadingDelegate> *delegates;
@property (readonly) HLPRPCPayload *payload;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload;

@end










@protocol HLPRPCPayloadWritingDelegate <HLPOperationDelegate>

@end



@interface HLPRPCPayloadWriting : HLPOperation <HLPRPCPayloadWritingDelegate>

@property (readonly) HLPRPC *parent;
@property (readonly) HLPArray<HLPRPCPayloadWritingDelegate> *delegates;
@property (readonly) HLPRPCPayload *payload;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload;

@end










@protocol HLPRPCMessageSendingDelegate <HLPOperationDelegate>

@end



@interface HLPRPCMessageSending : HLPOperation <HLPRPCMessageSendingDelegate>

@property (readonly) HLPRPC *parent;
@property (readonly) HLPArray<HLPRPCMessageSendingDelegate> *delegates;
@property (readonly) id message;
@property (readonly) id response;
@property (readonly) HLPRPCPayloadWriting *writing;
@property (readonly) HLPTimer *timer;

- (instancetype)initWithMessage:(id)message;
- (void)endWithResponse:(id)response error:(NSError *)error;

@end










@protocol HLPRPCMessageReceivingDelegate <HLPOperationDelegate>

@end



@interface HLPRPCMessageReceiving : HLPOperation <HLPRPCMessageReceivingDelegate>

@property (readonly) HLPRPC *parent;
@property (readonly) HLPArray<HLPRPCMessageReceivingDelegate> *delegates;
@property (readonly) HLPRPCPayload *payload;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload;

- (HLPRPCResponseSending *)sendResponse:(id)response error:(NSError *)error;
- (HLPRPCResponseSending *)sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion;

@end










@protocol HLPRPCResponseSendingDelegate <HLPOperationDelegate>

@end



@interface HLPRPCResponseSending : HLPOperation <HLPRPCResponseSendingDelegate>

@property (readonly) HLPRPC *parent;
@property (readonly) HLPArray<HLPRPCResponseSendingDelegate> *delegates;
@property (readonly) HLPRPCPayload *payload;
@property (readonly) id response;
@property (readonly) NSError *error;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload response:(id)response error:(NSError *)error;

@end










@protocol HLPRPCDelegate <HLPStreamsDelegate, HLPRPCPayloadReadingDelegate, HLPRPCPayloadWritingDelegate, HLPRPCMessageSendingDelegate, HLPRPCMessageReceivingDelegate, HLPRPCResponseSendingDelegate>

@end



@interface HLPRPC : HLPOperation <HLPRPCDelegate>

@property NSTimeInterval timeout;

@property (readonly) HLPStreams *streams;
@property (readonly) HLPRPCPayloadReading *reading;
@property (readonly) HLPDictionary<NSString *, HLPRPCMessageSending *> *sendings;

- (instancetype)initWithStreams:(HLPStreams *)streams;

- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload;
- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion;

- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload;
- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion;

- (HLPRPCMessageReceiving *)receiveMessage:(HLPRPCPayload *)payload;
- (HLPRPCMessageReceiving *)receiveMessage:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion;

- (HLPRPCMessageSending *)sendMessage:(id)message;
- (HLPRPCMessageSending *)sendMessage:(id)message completion:(HLPVoidBlock)completion;

- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error;
- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion;

@end










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
//
//
//
//
//@interface HLPRPCMessage : HLPObject
//
//@property NSString *identifier;
//@property NSString *responseIdentifier;
//@property BOOL needsResponse;
//@property NSError *error;
//@property id payload;
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
//@protocol HLPRPCMessageReadingDelegate <HLPOperationDelegate>
//
//@end
//
//
//
//@interface HLPRPCMessageReading : HLPOperation <HLPRPCMessageReadingDelegate>
//
//@property HLPStreamReading *reading;
//
//@property (readonly) HLPRPC *parent;
//@property (readonly) HLPArray<HLPRPCMessageReadingDelegate> *delegates;
//@property (readonly) HLPRPCMessage *message;
//
//- (instancetype)initWithMessage:(HLPRPCMessage *)message;
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
//@protocol HLPRPCMessageWritingDelegate <HLPOperationDelegate>
//
//@end
//
//
//
//@interface HLPRPCMessageWriting : HLPOperation <HLPRPCMessageWritingDelegate>
//
//@property HLPStreamWriting *writing;
//
//@property (readonly) HLPRPC *parent;
//@property (readonly) HLPArray<HLPRPCMessageWritingDelegate> *delegates;
//@property (readonly) HLPRPCMessage *message;
//
//- (instancetype)initWithMessage:(HLPRPCMessage *)message;
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
//@protocol HLPRPCRequestReceivingDelegate <HLPOperationDelegate>
//
//@end
//
//
//
//@interface HLPRPCRequestReceiving : HLPOperation <HLPRPCRequestReceivingDelegate>
//
//@property (readonly) HLPRPC *parent;
//@property (readonly) HLPArray<HLPRPCRequestReceivingDelegate> *delegates;
//@property (readonly) HLPRPCMessage *message;
//@property (readonly) id request;
//@property (readonly) id response;
//@property (readonly) HLPTimer *timer;
//@property (readonly) HLPRPCMessageWriting *writing;
//
//- (instancetype)initWithMessage:(HLPRPCMessage *)message;
//- (void)endWithResponse:(id)response error:(NSError *)error;
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
//@protocol HLPRPCRequestSendingDelegate <HLPOperationDelegate>
//
//@end
//
//
//
//@interface HLPRPCRequestSending : HLPOperation <HLPRPCRequestSendingDelegate>
//
//@property (readonly) HLPRPC *parent;
//@property (readonly) HLPArray<HLPRPCRequestSendingDelegate> *delegates;
//@property (readonly) id request;
//@property (readonly) id response;
//@property (readonly) HLPRPCMessageWriting *writing;
//@property (readonly) HLPTimer *timer;
//
//- (instancetype)initWithRequest:(id)request;
//- (void)endWithResponse:(id)response error:(NSError *)error;
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
//@protocol HLPRPCDelegate <HLPStreamsDelegate, HLPRPCMessageReadingDelegate, HLPRPCMessageWritingDelegate, HLPRPCRequestReceivingDelegate, HLPRPCRequestSendingDelegate>
//
//@end
//
//
//
//@interface HLPRPC : HLPOperation <HLPRPCDelegate>
//
//@property Class messageReadingClass;
//@property Class messageWritingClass;
//@property Class requestReceivingClass;
//@property Class requestSendingClass;
//@property NSTimeInterval timeout;
//
//@property (readonly) HLPStreams *streams;
//@property (readonly) HLPRPCMessageReading *reading;
//@property (readonly) HLPDictionary<NSString *, HLPRPCRequestSending *> *sentRequest;
//
//- (instancetype)initWithStreams:(HLPStreams *)streams;
//
//- (HLPRPCMessageReading *)readMessage:(HLPRPCMessage *)message;
//- (HLPRPCMessageReading *)readMessage:(HLPRPCMessage *)message completion:(HLPVoidBlock)completion;
//
//- (HLPRPCMessageWriting *)writeMessage:(HLPRPCMessage *)message;
//- (HLPRPCMessageWriting *)writeMessage:(HLPRPCMessage *)message completion:(HLPVoidBlock)completion;
//
//- (HLPRPCRequestReceiving *)receiveRequest:(HLPRPCMessage *)message;
//- (HLPRPCRequestReceiving *)receiveRequest:(HLPRPCMessage *)message completion:(HLPVoidBlock)completion;
//
//- (HLPRPCRequestSending *)sendRequest:(id)request;
//- (HLPRPCRequestSending *)sendRequest:(id)request completion:(HLPVoidBlock)completion;
//
//@end



































































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

