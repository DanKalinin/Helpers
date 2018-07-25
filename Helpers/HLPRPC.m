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
@property HLPRPCPayloadWriting *writing;
@property HLPTimer *timer;

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
    [self updateState:HLPOperationStateDidBegin];
    
    HLPRPCPayload *payload = HLPRPCPayload.new;
    payload.serial = @"1";
    payload.message = self.message;
    self.writing = [self.parent writePayload:payload];
    [self.writing waitUntilFinished];
    if (self.writing.cancelled) {
    } else if (self.writing.errors.count > 0) {
        [self.errors addObjectsFromArray:self.writing.errors];
    } else {
        if (payload.needsResponse) {
            self.parent.sendings[payload.serial] = self;
            self.timer = [HLPClock.shared timerWithInterval:self.parent.timeout repeats:1];
            [self.timer waitUntilFinished];
            if (!self.timer.cancelled) {
                NSError *error = [NSError errorWithDomain:HLPRPCErrorDomain code:HLPRPCErrorTimeout userInfo:nil];
                [self.errors addObject:error];
            }
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.writing cancel];
    [self.timer cancel];
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
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPRPC ()

@property HLPStreams *streams;
@property HLPRPCPayloadReading *reading;
@property HLPDictionary<NSString *, HLPRPCMessageSending *> *sendings;

@end



@implementation HLPRPC

- (instancetype)initWithStreams:(HLPStreams *)streams {
    self = super.init;
    if (self) {
        self.streams = streams;
        [self.streams.delegates addObject:self.delegates];
        
        self.sendings = HLPDictionary.strongToWeakDictionary;
        
        self.timeout = 30.0;
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
        [self.errors addObjectsFromArray:self.reading.errors];
        
        if (self.reading.cancelled) {
        } else if (self.reading.errors.count > 0) {
        } else {
            [self receiveMessage:payload];
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload {
    HLPRPCPayloadReading *reading = [HLPRPCPayloadReading.alloc initWithPayload:payload];
    [self addOperation:reading];
    return reading;
}

- (HLPRPCPayloadReading *)readPayload:(HLPRPCPayload *)payload completion:(HLPVoidBlock)completion {
    HLPRPCPayloadReading *reading = [self readPayload:payload];
    reading.completionBlock = completion;
    return reading;
}

- (HLPRPCPayloadWriting *)writePayload:(HLPRPCPayload *)payload {
    HLPRPCPayloadWriting *writing = [HLPRPCPayloadWriting.alloc initWithPayload:payload];
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

























//@interface HLPRPCMessage ()
//
//@end
//
//
//
//@implementation HLPRPCMessage
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
//@interface HLPRPCMessageReading ()
//
//@property HLPRPCMessage *message;
//
//@end
//
//
//
//@implementation HLPRPCMessageReading
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithMessage:(HLPRPCMessage *)message {
//    self = super.init;
//    if (self) {
//        self.message = message;
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
//@interface HLPRPCMessageWriting ()
//
//@property HLPRPCMessage *message;
//
//@end
//
//
//
//@implementation HLPRPCMessageWriting
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithMessage:(HLPRPCMessage *)message {
//    self = super.init;
//    if (self) {
//        self.message = message;
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
//@interface HLPRPCRequestReceiving ()
//
//@property HLPRPCMessage *message;
//@property id request;
//@property id response;
//@property HLPTimer *timer;
//@property HLPRPCMessageWriting *writing;
//
//@end
//
//
//
//@implementation HLPRPCRequestReceiving
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithMessage:(HLPRPCMessage *)message {
//    self = super.init;
//    if (self) {
//        self.message = message;
//    }
//    return self;
//}
//
//- (void)main {
//    self.request = self.message.payload;
//
//    [self updateState:HLPOperationStateDidBegin];
//
//    if (self.message.needsResponse) {
//        self.timer = [HLPClock.shared timerWithInterval:self.parent.timeout repeats:1];
//        [self.timer waitUntilFinished];
//        if (self.cancelled) {
//        } else if (self.timer.cancelled) {
//            HLPRPCMessage *message = HLPRPCMessage.new;
//            message.responseIdentifier = self.message.identifier;
//            message.error = self.errors.firstObject;
//            message.payload = self.response;
//            self.writing = [self.parent writeMessage:message];
//            [self.writing waitUntilFinished];
//            [self.errors addObjectsFromArray:self.writing.errors];
//        } else {
//            NSError *error = [NSError errorWithDomain:HLPRPCErrorDomain code:HLPRPCErrorTimeout userInfo:nil];
//            [self.errors addObject:error];
//        }
//    }
//
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//- (void)cancel {
//    [super cancel];
//
//    [self.timer cancel];
//    [self.writing cancel];
//}
//
//#pragma mark - Helpers
//
//- (void)endWithResponse:(id)response error:(NSError *)error {
//    [self.timer cancel];
//
//    if (error) {
//        [self.errors addObject:error];
//    } else {
//        self.response = response;
//    }
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
//@interface HLPRPCRequestSending ()
//
//@property id request;
//@property id response;
//@property HLPRPCMessageWriting *writing;
//@property HLPTimer *timer;
//
//@end
//
//
//
//@implementation HLPRPCRequestSending
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithRequest:(id)request {
//    self = super.init;
//    if (self) {
//        self.request = request;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//
//    HLPRPCMessage *message = HLPRPCMessage.new;
//    // Serial
//    message.payload = self.request;
//    self.writing = [self.parent writeMessage:message];
//    [self.writing waitUntilFinished];
//    [self.errors addObjectsFromArray:self.writing.errors];
//    if (self.writing.cancelled) {
//    } else if (self.writing.errors.count > 0) {
//    } else {
//        if (message.needsResponse) {
//            self.parent.sentRequest[message.identifier] = self;
//            self.timer = [HLPClock.shared timerWithInterval:self.parent.timeout repeats:1];
//            [self.timer waitUntilFinished];
//            if (self.cancelled) {
//            } else if (!self.timer.cancelled) {
//                NSError *error = [NSError errorWithDomain:HLPRPCErrorDomain code:HLPRPCErrorTimeout userInfo:nil];
//                [self.errors addObject:error];
//            }
//        }
//    }
//
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//- (void)cancel {
//    [super cancel];
//
//    [self.writing cancel];
//    [self.timer cancel];
//}
//
//#pragma mark - Helpers
//
//- (void)endWithResponse:(id)response error:(NSError *)error {
//    [self.timer cancel];
//
//    if (error) {
//        [self.errors addObject:error];
//    } else {
//        self.response = response;
//    }
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
//@interface HLPRPC ()
//
//@property HLPStreams *streams;
//@property HLPRPCMessageReading *reading;
//@property HLPDictionary<NSString *, HLPRPCRequestSending *> *sentRequest;
//
//@end
//
//
//
//@implementation HLPRPC
//
//- (instancetype)initWithStreams:(HLPStreams *)streams {
//    self = super.init;
//    if (self) {
//        self.streams = streams;
//        [self.streams.delegates addObject:self.delegates];
//
//        self.sentRequest = HLPDictionary.strongToWeakDictionary;
//
//        self.messageReadingClass = HLPRPCMessageReading.class;
//        self.messageWritingClass = HLPRPCMessageWriting.class;
//        self.requestReceivingClass = HLPRPCRequestReceiving.class;
//        self.requestSendingClass = HLPRPCRequestSending.class;
//        self.timeout = 30.0;
//    }
//    return self;
//}
//
//- (void)start {
//    [NSThread detachNewThreadWithBlock:^{
//        [self main];
//    }];
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//
//    while (!self.cancelled && (self.errors.count == 0)) {
//        HLPRPCMessage *message = HLPRPCMessage.new;
//        self.reading = [self readMessage:message];
//        [self.reading waitUntilFinished];
//        [self.errors addObjectsFromArray:self.reading.errors];
//        if (self.reading.cancelled) {
//        } else if (self.reading.errors.count > 0) {
//        } else {
//            if (message.responseIdentifier.length > 0) {
//                HLPRPCRequestSending *sending = self.sentRequest[message.responseIdentifier];
//                [sending endWithResponse:message.payload error:message.error];
//            } else {
//                [self receiveRequest:message];
//            }
//        }
//    }
//
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//- (HLPRPCMessageReading *)readMessage:(HLPRPCMessage *)message {
//    HLPRPCMessageReading *reading = [self.messageReadingClass.alloc initWithMessage:message];
//    [self addOperation:reading];
//    return reading;
//}
//
//- (HLPRPCMessageReading *)readMessage:(HLPRPCMessage *)message completion:(HLPVoidBlock)completion {
//    HLPRPCMessageReading *reading = [self readMessage:message];
//    reading.completionBlock = completion;
//    return reading;
//}
//
//- (HLPRPCMessageWriting *)writeMessage:(HLPRPCMessage *)message {
//    HLPRPCMessageWriting *writing = [self.messageWritingClass.alloc initWithMessage:message];
//    [self addOperation:writing];
//    return writing;
//}
//
//- (HLPRPCMessageWriting *)writeMessage:(HLPRPCMessage *)message completion:(HLPVoidBlock)completion {
//    HLPRPCMessageWriting *writing = [self writeMessage:message];
//    writing.completionBlock = completion;
//    return writing;
//}
//
//- (HLPRPCRequestReceiving *)receiveRequest:(HLPRPCMessage *)message {
//    HLPRPCRequestReceiving *receiving = [self.requestReceivingClass.alloc initWithMessage:message];
//    [self addOperation:receiving];
//    return receiving;
//}
//
//- (HLPRPCRequestReceiving *)receiveRequest:(HLPRPCMessage *)message completion:(HLPVoidBlock)completion {
//    HLPRPCRequestReceiving *receiving = [self receiveRequest:message];
//    receiving.completionBlock = completion;
//    return receiving;
//}
//
//- (HLPRPCRequestSending *)sendRequest:(id)request {
//    HLPRPCRequestSending *sending = [self.requestSendingClass.alloc initWithRequest:request];
//    [self addOperation:sending];
//    return sending;
//}
//
//- (HLPRPCRequestSending *)sendRequest:(id)request completion:(HLPVoidBlock)completion {
//    HLPRPCRequestSending *sending = [self sendRequest:request];
//    sending.completionBlock = completion;
//    return sending;
//}
//
//@end




























//#import "HLPStream.h"
//#import <netinet/in.h>
//
//const HLPOperationState HLPStreamPairStateDidOpen = 2;
//
//const HLPOperationState HLPStreamLoadStateDidInit = 2;
//const HLPOperationState HLPStreamLoadStateDidProcess = 3;
//
//NSErrorDomain const HLPStreamErrorDomain = @"HLPStream";
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
//@interface HLPStreamMessage ()
//
//@end
//
//
//
//@implementation HLPStreamMessage
//
//- (NSInteger)readFromStream:(NSInputStream *)inputStream {
//    return 0;
//}
//
//- (NSInteger)writeToStream:(NSOutputStream *)outputStream {
//    return 0;
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
//@interface HLPStreamLoad ()
//
//@property HLPStreamLoadOperation operation;
//@property NSMutableData *data;
//@property NSString *path;
//
//@end
//
//
//
//@implementation HLPStreamLoad
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithOperation:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path {
//    self = super.init;
//    if (self) {
//        self.operation = operation;
//        self.data = data;
//        self.path = path;
//
//        self.progress.totalUnitCount = data.length;
//    }
//    return self;
//}
//
//#pragma mark - Helpers
//
//- (void)updateState:(HLPOperationState)state {
//    [super updateState:state];
//
//    [self.delegates HLPStreamLoadDidUpdateState:self];
//    if (state == HLPOperationStateDidBegin) {
//        [self.delegates HLPStreamLoadDidBegin:self];
//    } else if (state == HLPStreamLoadStateDidInit) {
//        [self.delegates HLPStreamLoadDidInit:self];
//    } else if (state == HLPStreamLoadStateDidProcess) {
//        [self.delegates HLPStreamLoadDidProcess:self];
//    } else if (state == HLPOperationStateDidEnd) {
//        [self.delegates HLPStreamLoadDidEnd:self];
//    }
//}
//
//- (void)updateProgress:(uint64_t)completedUnitCount {
//    [super updateProgress:completedUnitCount];
//
//    [self.delegates HLPStreamLoadDidUpdateProgress:self];
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
//@interface HLPStreamPair ()
//
//@property NSInputStream *inputStream;
//@property NSOutputStream *outputStream;
//@property Sequence *sequence;
//@property NSMutableDictionary<NSNumber *, HLPStreamMessage *> *messages;
//
//@property Sequence *loadSequence;
//@property NSMutableDictionary<NSNumber *, NSMutableData *> *loadData;
//
//@end
//
//
//
//@implementation HLPStreamPair
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
//    self = super.init;
//    if (self) {
//        self.inputStream = inputStream;
//        self.outputStream = outputStream;
//
//        self.progress.totalUnitCount = -1;
//
//        self.timeout = 60.0;
//        self.sequence = Sequence.new;
//        self.messages = NSMutableDictionary.dictionary;
//
//        self.loadChunk = 1024;
//        self.loadDirectory = NSFileManager.defaultManager.userDownloadsDirectoryURL;
//        self.loadSequence = Sequence.new;
//        self.loadData = NSMutableDictionary.dictionary;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//
//    [self.inputStream open];
//    [self.outputStream open];
//
//    while (!self.cancelled) {
//        if (self.inputStream.streamStatus == NSStreamStatusOpening) {
//            continue;
//        } else if (self.inputStream.streamStatus == NSStreamStatusOpen) {
//            [self updateState:HLPStreamPairStateDidOpen];
//            while (!self.cancelled) {
//                if (self.inputStream.hasBytesAvailable) {
//                    if (self.messageClass) {
//                        HLPStreamMessage *message = self.messageClass.new;
//                        NSInteger result = [message readFromStream:self.inputStream];
//                        if (result > 0) {
//                            if (message.replySerial > 0) {
//                                HLPStreamMessage *msg = [self.messages popObjectForKey:@(message.replySerial)];
//                                [msg.timer invalidate];
//                                [self invokeHandler:msg.completion object:message object:nil queue:self.delegates.operationQueue];
//                                msg.completion = nil;
//                            } else {
//                                [self.delegates HLPStreamPair:self didReceiveMessage:message];
//                            }
//                        } else {
//                            NSError *error = (result < 0) ? self.inputStream.streamError : [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorClosed userInfo:nil];
//                            [self.errors addObject:error];
//                            [self completeMessagesWithError:error];
//                            break;
//                        }
//                    } else {
//                        NSMutableData *data = NSMutableData.data;
//                        NSInteger result = [self.inputStream read:data length:1024];
//                        if (result > 0) {
//                            [self.delegates HLPStreamPair:self didReceiveData:data];
//                        } else {
//                            NSError *error = (result < 0) ? self.inputStream.streamError : [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorClosed userInfo:nil];
//                            [self.errors addObject:error];
//                            break;
//                        }
//                    }
//                }
//            }
//            break;
//        } else {
//            [self.errors addObject:self.inputStream.streamError];
//            break;
//        }
//    }
//
//    if (self.cancelled) {
//        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorCancelled userInfo:nil];
//        [self completeMessagesWithError:error];
//    }
//
//    [self.inputStream close];
//    [self.outputStream close];
//
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//- (void)writeMessage:(HLPStreamMessage *)message completion:(HLPStreamMessageErrorBlock)completion {
//    message.serial = self.sequence.value;
//    [self.sequence increment];
//
//    NSInteger result = [message writeToStream:self.outputStream];
//    if (result > 0) {
//        if (message.reply) {
//            message.completion = completion;
//            self.messages[@(message.serial)] = message;
//            message.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer *timer) {
//                self.messages[@(message.serial)] = nil;
//                NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimedOut userInfo:nil];
//                [self invokeHandler:completion object:nil object:error queue:self.delegates.operationQueue];
//            }];
//        } else {
//            [self invokeHandler:completion object:message object:nil queue:self.delegates.operationQueue];
//        }
//    } else if (result == 0) {
//        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorClosed userInfo:nil];
//        [self invokeHandler:completion object:nil object:error queue:self.delegates.operationQueue];
//    } else {
//        [self invokeHandler:completion object:nil object:self.outputStream.streamError queue:self.delegates.operationQueue];
//    }
//}
//
//- (HLPStreamMessage *)writeMessage:(HLPStreamMessage *)message error:(NSError **)error {
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_enter(group);
//    __block HLPStreamMessage *msg;
//    __block NSError *err;
//    [self writeMessage:message completion:^(HLPStreamMessage *message, NSError *error) {
//        msg = message;
//        err = error;
//        dispatch_group_leave(group);
//    }];
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    *error = err;
//    return msg;
//}
//
//- (HLPStreamLoad *)load:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path {
//    HLPStreamLoad *load = [self.loadClass.alloc initWithOperation:operation data:data path:path];
//    [self addOperation:load];
//    return load;
//}
//
//- (HLPStreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path {
//    HLPStreamLoad *load = [self load:HLPStreamLoadOperationUp data:data path:path];
//    return load;
//}
//
//- (HLPStreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path {
//    HLPStreamLoad *load = [self load:HLPStreamLoadOperationDown data:data path:path];
//    return load;
//}
//
//- (HLPStreamLoad *)load:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path completion:(HLPVoidBlock)completion {
//    HLPStreamLoad *load = [self load:operation data:data path:path];
//    load.completionBlock = completion;
//    return load;
//}
//
//- (HLPStreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path completion:(HLPVoidBlock)completion {
//    HLPStreamLoad *load = [self uploadData:data toPath:path];
//    load.completionBlock = completion;
//    return load;
//}
//
//- (HLPStreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path completion:(HLPVoidBlock)completion {
//    HLPStreamLoad *load = [self downloadData:data fromPath:path];
//    load.completionBlock = completion;
//    return load;
//}
//
//#pragma mark - Accessors
//
//- (HLPStreamClient *)client {
//    return (HLPStreamClient *)self.parent;
//}
//
//- (HLPStreamServer *)server {
//    return (HLPStreamServer *)self.parent;
//}
//
//#pragma mark - Helpers
//
//- (void)updateState:(HLPOperationState)state {
//    [super updateState:state];
//
//    [self.delegates HLPStreamPairDidUpdateState:self];
//    if (state == HLPOperationStateDidBegin) {
//        [self.delegates HLPStreamPairDidBegin:self];
//    } else if (state == HLPStreamPairStateDidOpen) {
//        [self.delegates HLPStreamPairDidOpen:self];
//    } else if (state == HLPOperationStateDidEnd) {
//        [self.delegates HLPStreamPairDidEnd:self];
//    }
//}
//
//- (void)completeMessagesWithError:(NSError *)error {
//    for (NSNumber *serial in self.messages.allKeys) {
//        HLPStreamMessage *message = [self.messages popObjectForKey:serial];
//        [message.timer invalidate];
//        [self invokeHandler:message.completion object:nil object:error queue:self.delegates.operationQueue];
//        message.completion = nil;
//    }
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
//@interface HLPStreamEndpoint ()
//
//@end
//
//
//
//@implementation HLPStreamEndpoint
//
//@dynamic delegates;
//
//- (instancetype)initWithPair:(Class)pair {
//    self = super.init;
//    if (self) {
//        self.pairClass = pair;
//    }
//    return self;
//}
//
//#pragma mark - Helpers
//
//- (HLPStreamPair *)pairWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
//    HLPStreamPair *pair = [self.pairClass.alloc initWithInputStream:inputStream outputStream:outputStream];
//    [self addOperation:pair];
//    return pair;
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
//@interface HLPStreamClient ()
//
//@end
//
//
//
//@implementation HLPStreamClient
//
//@dynamic operation;
//
//- (instancetype)initWithPair:(Class)pair {
//    self = [super initWithPair:pair];
//    if (self) {
//    }
//    return self;
//}
//
//- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream pair:(Class)pair {
//    self = [self initWithPair:pair];
//
//    [self pairWithInputStream:inputStream outputStream:outputStream];
//    return self;
//}
//
//- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair {
//    NSInputStream *inputStream;
//    NSOutputStream *outputStream;
//    [NSStream getStreamsToHostWithName:components.host port:components.port.integerValue inputStream:&inputStream outputStream:&outputStream];
//
//    self = [self initWithInputStream:inputStream outputStream:outputStream pair:pair];
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
//static void HLPStreamServerAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);
//
//
//
//@interface HLPStreamServer ()
//
//@end
//
//
//
//@implementation HLPStreamServer
//
//@dynamic operations;
//
//- (instancetype)initWithPair:(Class)pair {
//    self = [super initWithPair:pair];
//    if (self) {
//    }
//    return self;
//}
//
//- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair {
//    self = [self initWithPair:pair];
//
//    // Create
//
//    CFSocketContext ctx = {0};
//    ctx.info = (__bridge void *)self;
//    CFSocketRef socket = CFSocketCreate(NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, HLPStreamServerAcceptCallback, &ctx);
//
//    // Bind
//
//    struct sockaddr address = components.address;
//    NSData *data = [NSData dataWithBytes:&address length:sizeof(address)];
//    CFSocketSetAddress(socket, (__bridge CFDataRef)data);
//
//    // Listen
//
//    CFRunLoopRef loop = CFRunLoopGetCurrent();
//    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(NULL, socket, 0);
//    CFRunLoopAddSource(loop, source, kCFRunLoopDefaultMode);
//
//    return self;
//}
//
//@end
//
//
//
//static void HLPStreamServerAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
//    CFReadStreamRef readStream;
//    CFWriteStreamRef writeStream;
//    CFSocketNativeHandle handle = CFSocketGetNative(socket);
//    CFStreamCreatePairWithSocket(NULL, handle, &readStream, &writeStream);
//    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
//
//    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
//    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
//    HLPStreamServer *server = (__bridge HLPStreamServer *)info;
//    [server pairWithInputStream:inputStream outputStream:outputStream];
//}
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
//@implementation NSStream (HLP)
//
//@end
//
//
//
//@implementation NSInputStream (HLP)
//
//- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length {
//    uint8_t buffer[length];
//    NSInteger result = [self read:buffer maxLength:length];
//    if (result > 0) {
//        [data appendBytes:buffer length:result];
//    }
//    return result;
//}
//
//- (NSInteger)readAll:(NSMutableData *)data {
//    NSInteger length = 0;
//    while (YES) {
//        NSInteger result = [self read:data length:1024];
//        if (result > 0) {
//            length += result;
//        } else if (result == 0) {
//            return length;
//        } else {
//            return result;
//        }
//    }
//}
//
//- (NSInteger)readLine:(NSMutableData *)data {
//    NSData *separator = [StringN dataUsingEncoding:NSUTF8StringEncoding];
//    NSInteger result = [self read:data until:separator];
//    return result;
//}
//
//- (NSInteger)read:(NSMutableData *)data exactly:(NSUInteger)length {
//    NSInteger remaining = length;
//    while (YES) {
//        NSInteger result = [self read:data length:length];
//        if (result > 0) {
//            remaining -= result;
//            if (remaining == 0) {
//                return length;
//            }
//        } else {
//            return result;
//        }
//    }
//}
//
//- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator {
//    NSInteger length = 0;
//    while (YES) {
//        NSInteger result = [self read:data length:1];
//        if (result > 0) {
//            length += result;
//            if (data.length >= separator.length) {
//                NSUInteger location = data.length - separator.length;
//                NSRange range = NSMakeRange(location, separator.length);
//                NSData *suffix = [data subdataWithRange:range];
//                if ([suffix isEqualToData:separator]) {
//                    return length;
//                }
//            }
//        } else {
//            return result;
//        }
//    }
//}
//
//@end
//
//
//
//@implementation NSOutputStream (HLP)
//
//- (NSInteger)write:(NSMutableData *)data {
//    NSInteger result = [self write:data.bytes maxLength:data.length];
//    return result;
//}
//
//- (NSInteger)writeAll:(NSMutableData *)data {
//    NSInteger length = data.length;
//    while (YES) {
//        NSInteger result = [self write:data];
//        if (result > 0) {
//            NSRange range = NSMakeRange(0, result);
//            [data replaceBytesInRange:range withBytes:NULL length:0];
//            if (data.length == 0) {
//                return length;
//            }
//        } else {
//            return result;
//        }
//    }
//}
//
//@end
