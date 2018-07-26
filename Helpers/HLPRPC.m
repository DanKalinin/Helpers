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

@end










@interface HLPRPCMessageSending ()

@property id message;
@property id response;

@end



@implementation HLPRPCMessageSending

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithMessage:(id)message {
    self = super.init;
    if (self) {
        self.message = message;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    HLPRPCPayload *payload = HLPRPCPayload.new;
    payload.serial = @"1"; // TODO: Sequence
    payload.message = self.message;
    
    self.operation = [self.parent writePayload:payload];
    [self.operation waitUntilFinished];
    if (self.operation.cancelled) {
    } else if (self.operation.errors.count > 0) {
    } else {
        if (payload.needsResponse) {
            [self updateProgress:1];
            
            self.parent.sendings[payload.serial] = self;
            
            self.operation = [HLPClock.shared timerWithInterval:self.parent.timeout repeats:1];
            [self.operation waitUntilFinished];
            if (self.operation.cancelled) {
                [self updateProgress:2];
            } else {
                NSError *error = [NSError errorWithDomain:HLPRPCErrorDomain code:HLPRPCErrorTimeout userInfo:nil];
                [self.errors addObject:error];
            }
        } else {
            [self updateProgress:2];
        }
    }
    
    [self.errors addObjectsFromArray:self.operation.errors];
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Helpers

- (void)endWithResponse:(id)response error:(NSError *)error {
    [self.operation cancel];
    
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
    
    if (self.payload.responseSerial.length > 0) {
        if (self.payload.error) {
            [self.errors addObject:self.payload.error];
        } else {
            self.response = self.payload.response;
        }
        
        HLPRPCMessageSending *sending = self.parent.sendings[self.payload.responseSerial];
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
    payload.responseSerial = self.payload.serial;
    payload.response = self.response;
    payload.error = self.error;
    
    self.operation = [self.parent writePayload:payload];
    [self.operation waitUntilFinished];
    [self.errors addObjectsFromArray:self.operation.errors];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPRPC ()

@property HLPStreams *streams;
@property HLPDictionary<NSString *, HLPRPCMessageSending *> *sendings;

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
        
        self.operation = [self readPayload:payload];
        [self.operation waitUntilFinished];
        if (self.operation.cancelled) {
        } else if (self.operation.errors.count > 0) {
        } else {
            [self receiveMessage:payload];
        }
        
        [self.errors addObjectsFromArray:self.operation.errors];
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

- (HLPRPCMessageSending *)sendMessage:(id)message {
    HLPRPCMessageSending *sending = [HLPRPCMessageSending.alloc initWithMessage:message];
    [self addOperation:sending];
    return sending;
}

- (HLPRPCMessageSending *)sendMessage:(id)message completion:(HLPVoidBlock)completion {
    HLPRPCMessageSending *sending = [self sendMessage:message];
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
