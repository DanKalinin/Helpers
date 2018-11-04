//
//  HLPRPC.h
//  Helpers
//
//  Created by Dan Kalinin on 7/20/18.
//

#import <Foundation/Foundation.h>
#import "HLPStream.h"
#import "HLPSequence.h"

@class HLPRPCPayload, HLPRPCPayloadReading, HLPRPCPayloadWriting, HLPRPCMessageSending, HLPRPCMessageReceiving, HLPRPCResponseSending, HLPRPC;

extern NSErrorDomain const HLPRPCErrorDomain;

NS_ERROR_ENUM(HLPRPCErrorDomain) {
    HLPRPCErrorUnknown,
    HLPRPCErrorTimeout
};

typedef NS_ENUM(NSUInteger, HLPRPCPayloadType) {
    HLPRPCPayloadTypeSignal,
    HLPRPCPayloadTypeCall,
    HLPRPCPayloadTypeReturn
};










@interface HLPRPCPayload : HLPObject

@property HLPRPCPayloadType type;
@property int64_t serial;
@property int64_t responseSerial;
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
@property (readonly) BOOL needsResponse;
@property (readonly) id response;
@property (readonly) HLPRPCPayloadWriting *writing;
@property (readonly) HLPTimer *timer;

- (instancetype)initWithMessage:(id)message needsResponse:(BOOL)needsResponse;
- (void)endWithResponse:(id)response error:(NSError *)error;

@end










@protocol HLPRPCMessageReceivingDelegate <HLPOperationDelegate>

@end



@interface HLPRPCMessageReceiving : HLPOperation <HLPRPCMessageReceivingDelegate>

@property (readonly) HLPRPC *parent;
@property (readonly) HLPArray<HLPRPCMessageReceivingDelegate> *delegates;
@property (readonly) HLPRPCPayload *payload;
@property (readonly) id message;
@property (readonly) id response;

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
@property (readonly) HLPRPCPayloadWriting *writing;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload response:(id)response error:(NSError *)error;

@end










@protocol HLPRPCDelegate <HLPStreamsDelegate, HLPRPCPayloadReadingDelegate, HLPRPCPayloadWritingDelegate, HLPRPCMessageSendingDelegate, HLPRPCMessageReceivingDelegate, HLPRPCResponseSendingDelegate>

@end



@interface HLPRPC : HLPOperation <HLPRPCDelegate>

@property Class payloadReadingClass;
@property Class payloadWritingClass;
@property NSTimeInterval timeout;
@property HLPSequence *sequence;

@property (readonly) HLPStreams *streams;
@property (readonly) HLPDictionary<NSNumber *, HLPRPCMessageSending *> *sendings;
@property (readonly) HLPRPCPayloadReading *reading;

- (instancetype)initWithStreams:(HLPStreams *)streams;

- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload;
- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion;

- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload;
- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion;

- (HLPRPCMessageReceiving *)receiveMessage:(HLPRPCPayload *)payload;
- (HLPRPCMessageReceiving *)receiveMessage:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion;

- (HLPRPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse;
- (HLPRPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse completion:(HLPVoidBlock)completion;

- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error;
- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion;

@end










//@class NSERPCPayload;
//@class NSERPCPayloadReading;
//@class NSERPCPayloadWriting;
//@class NSERPCMessageSending;
//@class NSERPCMessageReceiving;
//@class NSERPCResponseSending;
//@class NSERPC;
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
//@interface NSERPCPayload : HLPObject
//
//typedef NS_ENUM(NSUInteger, NSERPCPayloadType) {
//    NSERPCPayloadTypeSignal,
//    NSERPCPayloadTypeCall,
//    NSERPCPayloadTypeReturn
//};
//
//@property NSERPCPayloadType type;
//@property int64_t serial;
//@property int64_t responseSerial;
//@property id message;
//@property id response;
//@property NSError *error;
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
//@protocol NSERPCPayloadReadingDelegate <NSEOperationDelegate>
//
//@end
//
//
//
//@interface NSERPCPayloadReading : NSEOperation <NSERPCPayloadReadingDelegate>
//
//@property (readonly) NSERPCPayload *payload;
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
//@protocol NSERPCPayloadWritingDelegate <NSEOperationDelegate>
//
//@end
//
//
//
//@interface NSERPCPayloadWriting : NSEOperation <NSERPCPayloadWritingDelegate>
//
//@property (readonly) NSERPCPayload *payload;
//
//- (instancetype)initWithPayload:(NSERPCPayload *)payload;
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
//@protocol NSERPCMessageSendingDelegate <NSEOperationDelegate>
//
//@end
//
//
//
//@interface NSERPCMessageSending : NSEOperation <NSERPCMessageSendingDelegate>
//
//@property (readonly) NSERPC *parent;
//@property (readonly) id message;
//@property (readonly) BOOL needsResponse;
//@property (readonly) id response;
//@property (readonly) NSERPCPayloadWriting *writing;
//@property (readonly) NSETimer *timer;
//
//- (instancetype)initWithMessage:(id)message needsResponse:(BOOL)needsResponse;
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
//@protocol NSERPCMessageReceivingDelegate <NSEOperationDelegate>
//
//@end
//
//
//
//@interface NSERPCMessageReceiving : NSEOperation <NSERPCMessageReceivingDelegate>
//
//@property (readonly) NSERPC *parent;
//@property (readonly) NSERPCPayload *payload;
//@property (readonly) id message;
//@property (readonly) id response;
//@property (readonly) NSError *responseError;
//
//- (instancetype)initWithPayload:(NSERPCPayload *)payload;
//
//- (NSERPCResponseSending *)sendResponse:(id)response error:(NSError *)error;
//- (NSERPCResponseSending *)sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion;
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
//@protocol NSERPCResponseSendingDelegate <NSEOperationDelegate>
//
//@end
//
//
//
//@interface NSERPCResponseSending : NSEOperation <NSERPCResponseSendingDelegate>
//
//@property (readonly) NSERPC *parent;
//@property (readonly) NSERPCPayload *payload;
//@property (readonly) id response;
//@property (readonly) NSError *responseError;
//@property (readonly) NSERPCPayloadWriting *writing;
//
//- (instancetype)initWithPayload:(NSERPCPayload *)payload response:(id)response error:(NSError *)error;
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
//@protocol NSERPCDelegate <NSERPCPayloadReadingDelegate, NSERPCPayloadWritingDelegate, NSERPCMessageSendingDelegate, NSERPCMessageReceivingDelegate, NSERPCResponseSendingDelegate>
//
//@end
//
//
//
//@interface NSERPC : NSEOperation <NSERPCDelegate>
//
//extern NSErrorDomain const NSERPCErrorDomain;
//
//NS_ERROR_ENUM(NSERPCErrorDomain) {
//    NSERPCErrorUnknown,
//    NSERPCErrorTimeout
//};
//
//@property Class payloadReadingClass;
//@property Class payloadWritingClass;
//@property Class messageReceivingClass;
//@property Class messageSendingClass;
//@property Class responseSendingClass;
//@property HLPSequence *sequence;
//@property NSTimeInterval timeout;
//
//@property (readonly) NSEStreams *streams;
//@property (readonly) HLPDictionary<NSNumber *, NSERPCMessageSending *> *sendings;
//@property (readonly) NSERPCPayloadReading *reading;
//@property (readonly) NSERPCMessageReceiving *receiving;
//
//- (instancetype)initWithStreams:(NSEStreams *)streams;
//
//- (NSERPCPayloadReading *)readPayload;
//- (NSERPCPayloadReading *)readPayloadWithCompletion:(HLPVoidBlock)completion;
//
//- (NSERPCPayloadWriting *)writePayload:(NSERPCPayload *)payload;
//- (NSERPCPayloadWriting *)writePayload:(NSERPCPayload *)payload completion:(HLPVoidBlock)completion;
//
//- (NSERPCMessageReceiving *)receiveMessageWithPayload:(NSERPCPayload *)payload;
//- (NSERPCMessageReceiving *)receiveMessageWithPayload:(NSERPCPayload *)payload completion:(HLPVoidBlock)completion;
//
//- (NSERPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse;
//- (NSERPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse completion:(HLPVoidBlock)completion;
//
//- (NSERPCResponseSending *)payload:(NSERPCPayload *)payload sendResponse:(id)response error:(NSError *)error;
//- (NSERPCResponseSending *)payload:(NSERPCPayload *)payload sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion;
//
//@end









@class NSERPCOperation;
@class NSERPCReading;
@class NSERPCWriting;
@class NSERPC;










@protocol NSERPCOperationDelegate <NSEOperationDelegate>

@end



@interface NSERPCOperation : NSEOperation <NSERPCOperationDelegate>

typedef NS_ENUM(NSUInteger, NSERPCOperationType) {
    NSERPCOperationTypeSignal,
    NSERPCOperationTypeCall,
    NSERPCOperationTypeReturn
};

@property NSERPCOperationType type;
@property int64_t serial;
@property int64_t responseSerial;
@property NSError *responseError;
@property id message;
@property id response;

@property (readonly) NSERPC *parent;

@end










@protocol NSERPCReadingDelegate <NSERPCOperationDelegate>

@end



@interface NSERPCReading : NSERPCOperation <NSERPCReadingDelegate>

- (void)read;

- (NSERPCWriting *)writeResponse:(id)response responseError:(NSError *)responseError;
- (NSERPCWriting *)writeResponse:(id)response responseError:(NSError *)responseError completion:(HLPVoidBlock)completion;

@end










@protocol NSERPCWritingDelegate <NSERPCOperationDelegate>

@end



@interface NSERPCWriting : NSERPCOperation <NSERPCWritingDelegate>

@property (readonly) BOOL needsResponse;
@property (readonly) NSETimer *timer;

- (instancetype)initWithMessage:(id)message needsResponse:(BOOL)needsResponse;
- (instancetype)initWithResponse:(id)response responseError:(NSError *)responseError responseSerial:(int64_t)responseSerial;

- (void)write;

@end










@protocol NSERPCDelegate <NSERPCReadingDelegate, NSERPCWritingDelegate>

@end



@interface NSERPC : NSEOperation <NSERPCDelegate>

extern NSErrorDomain const NSERPCErrorDomain;

NS_ERROR_ENUM(NSERPCErrorDomain) {
    NSERPCErrorUnknown,
    NSERPCErrorTimeout
};

@property Class readingClass;
@property Class writingClass;
@property HLPSequence *sequence;
@property NSTimeInterval timeout;

@property (readonly) NSEStreams *streams;
@property (readonly) HLPDictionary<NSNumber *, NSERPCWriting *> *writings;
@property (readonly) NSERPCReading *reading;

- (instancetype)initWithStreams:(NSEStreams *)streams;

- (NSERPCReading *)read;
- (NSERPCReading *)readWithCompletion:(HLPVoidBlock)completion;

- (NSERPCWriting *)writeMessage:(id)message needsResponse:(BOOL)needsResponse;
- (NSERPCWriting *)writeMessage:(id)message needsResponse:(BOOL)needsResponse completion:(HLPVoidBlock)completion;

- (NSERPCWriting *)writeResponse:(id)response responseError:(NSError *)responseError responseSerial:(int64_t)responseSerial;
- (NSERPCWriting *)writeResponse:(id)response responseError:(NSError *)responseError responseSerial:(int64_t)responseSerial completion:(HLPVoidBlock)completion;

@end
