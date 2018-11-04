//
//  HLPRPC.m
//  Helpers
//
//  Created by Dan Kalinin on 7/20/18.
//

#import "HLPRPC.h"

NSErrorDomain const HLPRPCErrorDomain = @"HLPRPC";










@interface HLPRPCPayload ()

@end



@implementation HLPRPCPayload

@end










@interface HLPRPCPayloadReading ()

@property HLPRPCPayload *payload;

@end



@implementation HLPRPCPayloadReading

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload {
    self = super.init;
    if (self) {
        self.payload = payload;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    [NSThread sleepForTimeInterval:1.0];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPRPCPayloadWriting ()

@property HLPRPCPayload *payload;

@end



@implementation HLPRPCPayloadWriting

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload {
    self = super.init;
    if (self) {
        self.payload = payload;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    [NSThread sleepForTimeInterval:1.0];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPRPCMessageSending ()

@property id message;
@property BOOL needsResponse;
@property id response;
@property HLPRPCPayloadWriting *writing;
@property HLPTimer *timer;

@end



@implementation HLPRPCMessageSending

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithMessage:(id)message needsResponse:(BOOL)needsResponse {
    self = super.init;
    if (self) {
        self.message = message;
        self.needsResponse = needsResponse;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    HLPRPCPayload *payload = HLPRPCPayload.new;
    payload.type = self.needsResponse ? HLPRPCPayloadTypeCall : HLPRPCPayloadTypeSignal;
    payload.serial = self.parent.sequence.value;
    [self.parent.sequence next];
    payload.message = self.message;

    self.operation = self.writing = [self.parent writePayload:payload];
    [self.writing waitUntilFinished];
    if (self.writing.cancelled) {
    } else if (self.writing.errors.count > 0) {
        [self.errors addObjectsFromArray:self.writing.errors];
    } else {
        if (payload.type == HLPRPCPayloadTypeCall) {
            [self updateProgress:1];

            self.parent.sendings[@(payload.serial)] = self;

            self.operation = self.timer = [HLPClock.shared timerWithInterval:self.parent.timeout repeats:1];
            [self.timer waitUntilFinished];
            if (self.cancelled) {
            } else if (self.timer.cancelled) {
                [self updateProgress:2];
            } else {
                NSError *error = [NSError errorWithDomain:HLPRPCErrorDomain code:HLPRPCErrorTimeout userInfo:nil];
                [self.errors addObject:error];
            }
        } else {
            [self updateProgress:2];
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Helpers

- (void)endWithResponse:(id)response error:(NSError *)error {
    [self.timer cancel];
    
    if (error) {
        [self.errors addObject:error];
    } else {
        self.response = response;
    }
}

@end










@interface HLPRPCMessageReceiving ()

@property HLPRPCPayload *payload;
@property id message;
@property id response;

@end



@implementation HLPRPCMessageReceiving

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload {
    self = super.init;
    if (self) {
        self.payload = payload;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    if (self.payload.type == HLPRPCPayloadTypeReturn) {
        if (self.payload.error) {
            [self.errors addObject:self.payload.error];
        } else {
            self.response = self.payload.response;
        }
        
        HLPRPCMessageSending *sending = self.parent.sendings[@(self.payload.responseSerial)];
        [sending endWithResponse:self.payload.response error:self.payload.error];
    } else {
        self.message = self.payload.message;
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (HLPRPCResponseSending *)sendResponse:(id)response error:(NSError *)error {
    HLPRPCResponseSending *sending = [self.parent payload:self.payload sendResponse:response error:error];
    return sending;
}

- (HLPRPCResponseSending *)sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion {
    HLPRPCResponseSending *sending = [self.parent payload:self.payload sendResponse:response error:error completion:completion];
    return sending;
}

@end










@interface HLPRPCResponseSending ()

@property HLPRPCPayload *payload;
@property id response;
@property NSError *error;
@property HLPRPCPayloadWriting *writing;

@end



@implementation HLPRPCResponseSending

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPayload:(HLPRPCPayload *)payload response:(id)response error:(NSError *)error {
    self = super.init;
    if (self) {
        self.payload = payload;
        self.response = response;
        self.error = error;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    HLPRPCPayload *payload = HLPRPCPayload.new;
    payload.type = HLPRPCPayloadTypeReturn;
    payload.responseSerial = self.payload.serial;
    payload.response = self.response;
    payload.error = self.error;
    
    self.operation = self.writing = [self.parent writePayload:payload];
    [self.writing waitUntilFinished];
    if (self.writing.cancelled) {
    } else if (self.writing.errors.count > 0) {
        [self.errors addObjectsFromArray:self.writing.errors];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPRPC ()

@property HLPStreams *streams;
@property HLPDictionary<NSNumber *, HLPRPCMessageSending *> *sendings;
@property HLPRPCPayloadReading *reading;

@end



@implementation HLPRPC

- (instancetype)initWithStreams:(HLPStreams *)streams {
    self = super.init;
    if (self) {
        self.streams = streams;
        [self.streams.delegates addObject:self.delegates];
        
        self.payloadReadingClass = HLPRPCPayloadReading.class;
        self.payloadWritingClass = HLPRPCPayloadWriting.class;
        
        self.timeout = 30.0;
        
        self.sequence = [HLPSequence.alloc initWithStart:INT64_MIN stop:INT64_MAX step:1];
        
        self.sendings = HLPDictionary.strongToWeakDictionary;
    }
    return self;
}

- (void)start {
    [NSThread detachNewThreadWithBlock:^{
        [self main];
    }];
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    while (!self.cancelled && (self.errors.count == 0)) {
        HLPRPCPayload *payload = HLPRPCPayload.new;
        
        self.reading = [self readPayload:payload];
        [self.reading waitUntilFinished];
        if (self.reading.cancelled) {
        } else if (self.reading.errors.count > 0) {
            [self.errors addObjectsFromArray:self.reading.errors];
        } else {
            [self receiveMessage:payload];
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload {
    HLPRPCPayloadReading *reading = [self.payloadReadingClass.alloc initWithPayload:payload];
    [self addOperation:reading];
    return reading;
}

- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion {
    HLPRPCPayloadReading *reading = [self readPayload:payload];
    reading.completionBlock = completion;
    return reading;
}

- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload {
    HLPRPCPayloadWriting *writing = [self.payloadWritingClass.alloc initWithPayload:payload];
    [self addOperation:writing];
    return writing;
}

- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion {
    HLPRPCPayloadWriting *writing = [self writePayload:payload];
    writing.completionBlock = completion;
    return writing;
}

- (HLPRPCMessageReceiving *)receiveMessage:(HLPRPCPayload *)payload {
    HLPRPCMessageReceiving *receiving = [HLPRPCMessageReceiving.alloc initWithPayload:payload];
    [self addOperation:receiving];
    return receiving;
}

- (HLPRPCMessageReceiving *)receiveMessage:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion {
    HLPRPCMessageReceiving *receiving = [self receiveMessage:payload];
    receiving.completionBlock = completion;
    return receiving;
}

- (HLPRPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse {
    HLPRPCMessageSending *sending = [HLPRPCMessageSending.alloc initWithMessage:message needsResponse:needsResponse];
    [self addOperation:sending];
    return sending;
}

- (HLPRPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse completion:(HLPVoidBlock)completion {
    HLPRPCMessageSending *sending = [self sendMessage:message needsResponse:needsResponse];
    sending.completionBlock = completion;
    return sending;
}

- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error {
    HLPRPCResponseSending *sending = [HLPRPCResponseSending.alloc initWithPayload:payload response:response error:error];
    [self addOperation:sending];
    return sending;
}

- (HLPRPCResponseSending *)payload:(HLPRPCPayload *)payload sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion {
    HLPRPCResponseSending *sending = [self payload:payload sendResponse:response error:error];
    sending.completionBlock = completion;
    return sending;
}

@end















//@interface NSERPCPayload ()
//
//@end
//
//
//
//@implementation NSERPCPayload
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
//@interface NSERPCPayloadReading ()
//
//@property NSERPCPayload *payload;
//
//@end
//
//
//
//@implementation NSERPCPayloadReading
//
//- (instancetype)init {
//    self = super.init;
//    if (self) {
//        self.payload = NSERPCPayload.new;
//    }
//    return self;
//}
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
//@interface NSERPCPayloadWriting ()
//
//@property NSERPCPayload *payload;
//
//@end
//
//
//
//@implementation NSERPCPayloadWriting
//
//- (instancetype)initWithPayload:(NSERPCPayload *)payload {
//    self = super.init;
//    if (self) {
//        self.payload = payload;
//    }
//    return self;
//}
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
//@interface NSERPCMessageSending ()
//
//@property id message;
//@property BOOL needsResponse;
//@property id response;
//@property NSERPCPayloadWriting *writing;
//@property NSETimer *timer;
//
//@end
//
//
//
//@implementation NSERPCMessageSending
//
//@dynamic parent;
//
//- (instancetype)initWithMessage:(id)message needsResponse:(BOOL)needsResponse {
//    self = super.init;
//    if (self) {
//        self.message = message;
//        self.needsResponse = needsResponse;
//    }
//    return self;
//}
//
//- (void)main {
//    NSERPCPayload *payload = NSERPCPayload.new;
//    payload.type = self.needsResponse ? NSERPCPayloadTypeCall : NSERPCPayloadTypeSignal;
//    payload.serial = self.parent.sequence.value;
//    payload.message = self.message;
//
//    [self.parent.sequence next];
//
//    self.operation = self.writing = [self.parent writePayload:payload];
//    [self.writing waitUntilFinished];
//    if (self.writing.isCancelled) {
//    } else if (self.writing.error) {
//        self.error = self.writing.error;
//    } else {
//        if (payload.type == NSERPCPayloadTypeCall) {
//            self.operation = self.timer = [NSEClock.shared timerWithInterval:self.parent.timeout repeats:1];
//
//            self.parent.sendings[@(payload.serial)] = self;
//
//            [self.timer waitUntilFinished];
//            if (self.timer.isCancelled) {
//            } else {
//                self.error = [NSError errorWithDomain:NSERPCErrorDomain code:NSERPCErrorTimeout userInfo:nil];
//            }
//        }
//    }
//
//    [self finish];
//}
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
//@interface NSERPCMessageReceiving ()
//
//@property NSERPCPayload *payload;
//@property id message;
//@property id response;
//@property NSError *responseError;
//
//@end
//
//
//
//@implementation NSERPCMessageReceiving
//
//@dynamic parent;
//
//- (instancetype)initWithPayload:(NSERPCPayload *)payload {
//    self = super.init;
//    if (self) {
//        self.payload = payload;
//    }
//    return self;
//}
//
//- (void)main {
//    if (self.payload.type == NSERPCPayloadTypeReturn) {
//        NSERPCMessageSending *sending = self.parent.sendings[@(self.payload.responseSerial)];
//        self.response = sending.response = self.payload.response;
//        self.responseError = sending.error = self.payload.error;
//        [sending.timer cancel];
//    } else {
//        self.message = self.payload.message;
//    }
//
//    [self finish];
//}
//
//- (NSERPCResponseSending *)sendResponse:(id)response error:(NSError *)error {
//    NSERPCResponseSending *sending = [self.parent payload:self.payload sendResponse:response error:error];
//    return sending;
//}
//
//- (NSERPCResponseSending *)sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion {
//    NSERPCResponseSending *sending = [self.parent payload:self.payload sendResponse:response error:error completion:completion];
//    return sending;
//}
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
//@interface NSERPCResponseSending ()
//
//@property NSERPCPayload *payload;
//@property id response;
//@property NSError *responseError;
//@property NSERPCPayloadWriting *writing;
//
//@end
//
//
//
//@implementation NSERPCResponseSending
//
//@dynamic parent;
//
//- (instancetype)initWithPayload:(NSERPCPayload *)payload response:(id)response error:(NSError *)error {
//    self = super.init;
//    if (self) {
//        self.payload = payload;
//        self.response = response;
//        self.responseError = error;
//    }
//    return self;
//}
//
//- (void)main {
//    NSERPCPayload *payload = NSERPCPayload.new;
//    payload.type = NSERPCPayloadTypeReturn;
//    payload.responseSerial = self.payload.serial;
//    payload.response = self.response;
//    payload.error = self.responseError;
//
//    self.operation = self.writing = [self.parent writePayload:payload];
//    [self.writing waitUntilFinished];
//    if (self.writing.isCancelled) {
//    } else if (self.writing.error) {
//        self.error = self.writing.error;
//    }
//
//    [self finish];
//}
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
//@interface NSERPC ()
//
//@property NSEStreams *streams;
//@property HLPDictionary<NSNumber *, NSERPCMessageSending *> *sendings;
//@property NSERPCPayloadReading *reading;
//@property NSERPCMessageReceiving *receiving;
//
//@end
//
//
//
//@implementation NSERPC
//
//NSErrorDomain const NSERPCErrorDomain = @"NSERPC";
//
//- (instancetype)initWithStreams:(NSEStreams *)streams {
//    self = super.init;
//    if (self) {
//        self.streams = streams;
//        [self.streams.delegates addObject:self.delegates];
//
//        self.isAsynchronous = YES;
//
//        self.payloadReadingClass = NSERPCPayloadReading.class;
//        self.payloadWritingClass = NSERPCPayloadWriting.class;
//        self.messageReceivingClass = NSERPCMessageReceiving.class;
//        self.messageSendingClass = NSERPCMessageSending.class;
//        self.responseSendingClass = NSERPCResponseSending.class;
//        self.sequence = [HLPSequence.alloc initWithStart:INT64_MIN stop:INT64_MAX step:1];
//        self.timeout = 30.0;
//
//        self.sendings = HLPDictionary.strongToWeakDictionary;
//    }
//    return self;
//}
//
//- (void)main {
//    while (YES) {
//        self.operation = self.reading = self.readPayload;
//        [self.reading waitUntilFinished];
//        if (self.reading.isCancelled) {
//        } else if (self.reading.error) {
//            self.error = self.reading.error;
//        } else {
//            self.receiving = [self receiveMessageWithPayload:self.reading.payload];
//        }
//
//        if (self.isCancelled || self.error) {
//            break;
//        }
//    }
//
//    [self finish];
//}
//
//- (NSERPCPayloadReading *)readPayload {
//    NSERPCPayloadReading *reading = self.payloadReadingClass.new;
//    [self addOperation:reading];
//    return reading;
//}
//
//- (NSERPCPayloadReading *)readPayloadWithCompletion:(HLPVoidBlock)completion {
//    NSERPCPayloadReading *reading = self.readPayload;
//    reading.completionBlock = completion;
//    return reading;
//}
//
//- (NSERPCPayloadWriting *)writePayload:(NSERPCPayload *)payload {
//    NSERPCPayloadWriting *writing = [self.payloadWritingClass.alloc initWithPayload:payload];
//    [self addOperation:writing];
//    return writing;
//}
//
//- (NSERPCPayloadWriting *)writePayload:(NSERPCPayload *)payload completion:(HLPVoidBlock)completion {
//    NSERPCPayloadWriting *writing = [self writePayload:payload];
//    writing.completionBlock = completion;
//    return writing;
//}
//
//- (NSERPCMessageReceiving *)receiveMessageWithPayload:(NSERPCPayload *)payload {
//    NSERPCMessageReceiving *receiving = [self.messageReceivingClass.alloc initWithPayload:payload];
//    [self addOperation:receiving];
//    return receiving;
//}
//
//- (NSERPCMessageReceiving *)receiveMessageWithPayload:(NSERPCPayload *)payload completion:(HLPVoidBlock)completion {
//    NSERPCMessageReceiving *receiving = [self receiveMessageWithPayload:payload];
//    receiving.completionBlock = completion;
//    return receiving;
//}
//
//- (NSERPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse {
//    NSERPCMessageSending *sending = [self.messageSendingClass.alloc initWithMessage:message needsResponse:needsResponse];
//    [self addOperation:sending];
//    return sending;
//}
//
//- (NSERPCMessageSending *)sendMessage:(id)message needsResponse:(BOOL)needsResponse completion:(HLPVoidBlock)completion {
//    NSERPCMessageSending *sending = [self sendMessage:message needsResponse:needsResponse];
//    sending.completionBlock = completion;
//    return sending;
//}
//
//- (NSERPCResponseSending *)payload:(NSERPCPayload *)payload sendResponse:(id)response error:(NSError *)error {
//    NSERPCResponseSending *sending = [self.responseSendingClass.alloc initWithPayload:payload response:response error:error];
//    [self addOperation:sending];
//    return sending;
//}
//
//- (NSERPCResponseSending *)payload:(NSERPCPayload *)payload sendResponse:(id)response error:(NSError *)error completion:(HLPVoidBlock)completion {
//    NSERPCResponseSending *sending = [self payload:payload sendResponse:response error:error];
//    sending.completionBlock = completion;
//    return sending;
//}
//
//@end





@interface NSERPCMessage ()

@end



@implementation NSERPCMessage

@end










@interface NSERPCMessageSending ()

@end



@implementation NSERPCMessageSending

@end










@interface NSERPC ()

@end



@implementation NSERPC

@end
