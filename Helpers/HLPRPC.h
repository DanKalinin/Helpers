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

typedef NS_ENUM(NSUInteger, HLPRPCPayloadType) {
    HLPRPCPayloadTypeSignal,
    HLPRPCPayloadTypeCall,
    HLPRPCPayloadTypeReturn
};










@interface HLPRPCPayload : HLPObject

@property HLPRPCPayloadType type;
@property NSInteger serial;
@property NSInteger responseSerial;
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

- (HLPRPCMessageSending *)sendMessage:(id)message;
- (HLPRPCMessageSending *)sendMessage:(id)message completion:(HLPVoidBlock)completion;

- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error;
- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion;

@end
