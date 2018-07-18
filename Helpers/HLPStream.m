//
//  HLPStream.m
//  Helpers
//
//  Created by Dan Kalinin on 3/5/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "HLPStream.h"

NSErrorDomain const HLPStreamErrorDomain = @"HLPStream";










@interface HLPStreamOpening ()

@property NSTimeInterval timeout;
@property HLPTimer *timer;
@property HLPStreamClosing *closing;

@end



@implementation HLPStreamOpening

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1];
    
    [self.parent.stream open];
    while (!self.cancelled && (self.parent.stream.streamStatus == NSStreamStatusOpening) && !self.timer.finished) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    if (self.cancelled) {
    } else if (self.parent.stream.streamStatus == NSStreamStatusOpen) {
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.timer.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.timer cancel];
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.closing = [self.parent close];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStreamClosing ()

@end



@implementation HLPStreamClosing

@dynamic parent;
@dynamic delegates;

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    [self.parent.stream close];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStreamReading ()

@property NSMutableData *data;
@property NSUInteger minLength;
@property NSUInteger maxLength;
@property NSTimeInterval timeout;
@property HLPTimer *timer;

@end



@implementation HLPStreamReading

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.data = data;
        self.minLength = minLength;
        self.maxLength = maxLength;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = self.maxLength;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1];
    
    while (!self.cancelled && (self.parent.stream.streamStatus == NSStreamStatusOpen) && (self.data.length < self.minLength) && (self.errors.count == 0) && !self.timer.finished) {
        if (self.parent.stream.hasBytesAvailable) {
            NSUInteger length = self.maxLength - self.data.length;
            uint8_t buffer[length];
            NSInteger result = [self.parent.stream read:buffer maxLength:length];
            if (result > 0) {
                [self.data appendBytes:buffer length:result];
                
                [self updateProgress:self.data.length];
            }
        } else {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    
    if (self.cancelled) {
    } else if (self.parent.stream.streamStatus == NSStreamStatusOpen) {
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.timer.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.timer cancel];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStreamWriting ()

@property NSMutableData *data;
@property NSTimeInterval timeout;
@property HLPTimer *timer;

@end



@implementation HLPStreamWriting

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithData:(NSMutableData *)data timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.data = data;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = self.data.length;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1];
    
    while (!self.cancelled && (self.parent.stream.streamStatus == NSStreamStatusOpen) && (self.data.length > 0) && (self.errors.count == 0) && !self.timer.finished) {
        if (self.parent.stream.hasSpaceAvailable) {
            NSInteger result = [self.parent.stream write:self.data.bytes maxLength:self.data.length];
            if (result > 0) {
                NSRange range = NSMakeRange(0, result);
                [self.data replaceBytesInRange:range withBytes:NULL length:0];
                
                int64_t completedUnitCount = self.progress.completedUnitCount - result;
                [self updateProgress:completedUnitCount];
            }
        } else {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    
    if (self.cancelled) {
    } else if (self.parent.stream.streamStatus == NSStreamStatusOpen) {
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.timer.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.timer cancel];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStream ()

@property NSStream *stream;

@end



@implementation HLPStream

@dynamic delegates;

- (instancetype)initWithStream:(NSStream *)stream {
    self = super.init;
    if (self) {
        self.stream = stream;
        
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (HLPStreamOpening *)openWithTimeout:(NSTimeInterval)timeout {
    HLPStreamOpening *opening = [HLPStreamOpening.alloc initWithTimeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (HLPStreamOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    HLPStreamOpening *opening = [self openWithTimeout:timeout];
    opening.completionBlock = completion;
    return opening;
}

- (HLPStreamClosing *)close {
    HLPStreamClosing *closing = HLPStreamClosing.new;
    [self addOperation:closing];
    return closing;
}

- (HLPStreamClosing *)closeWithCompletion:(HLPVoidBlock)completion {
    HLPStreamClosing *closing = [self close];
    closing.completionBlock = completion;
    return closing;
}

@end










@interface HLPInputStream ()

@end



@implementation HLPInputStream

@dynamic delegates;
@dynamic stream;

- (HLPStreamReading *)readData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout {
    HLPStreamReading *reading = [HLPStreamReading.alloc initWithData:data minLength:minLength maxLength:maxLength timeout:timeout];
    [self addOperation:reading];
    return reading;
}

- (HLPStreamReading *)readData:(NSMutableData *)data minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    HLPStreamReading *reading = [self readData:data minLength:minLength maxLength:maxLength timeout:timeout];
    reading.completionBlock = completion;
    return reading;
}

@end










@interface HLPOutputStream ()

@end



@implementation HLPOutputStream

@dynamic delegates;
@dynamic stream;

- (HLPStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout {
    HLPStreamWriting *writing = [HLPStreamWriting.alloc initWithData:data timeout:timeout];
    [self addOperation:writing];
    return writing;
}

- (HLPStreamWriting *)writeData:(NSMutableData *)data timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    HLPStreamWriting *writing = [self writeData:data timeout:timeout];
    writing.completionBlock = completion;
    return writing;
}

@end










@interface HLPStreamsOpening ()

@property NSTimeInterval timeout;
@property HLPStreamOpening *opening;

@end



@implementation HLPStreamsOpening

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    self.opening = [self.parent.input openWithTimeout:self.timeout];
    [self.opening waitUntilFinished];
    if (self.opening.errors.count > 0) {
    } else if (self.opening.cancelled) {
    } else {
        [self updateProgress:1];
        
        self.opening = [self.parent.output openWithTimeout:self.timeout];
        [self.opening waitUntilFinished];
        if (self.opening.errors.count > 0) {
        } else if (self.opening.cancelled) {
        } else {
            [self updateProgress:2];
        }
    }
    
    [self.errors addObjectsFromArray:self.opening.errors];
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.opening cancel];
}

@end










@interface HLPStreams ()

@property HLPInputStream *input;
@property HLPOutputStream *output;

@end



@implementation HLPStreams

@dynamic delegates;

+ (instancetype)streamsWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    HLPInputStream *input = [HLPInputStream.alloc initWithStream:inputStream];
    HLPOutputStream *output = [HLPOutputStream.alloc initWithStream:outputStream];
    HLPStreams *streams = [self.alloc initWithInput:input output:output];
    return streams;
}

+ (instancetype)streamsToHost:(NSString *)host port:(NSInteger)port {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    [NSStream getStreamsToHostWithName:host port:port inputStream:&inputStream outputStream:&outputStream];
    HLPStreams *streams = [self streamsWithInputStream:inputStream outputStream:outputStream];
    return streams;
}

+ (instancetype)streamsWithComponents:(NSURLComponents *)components {
    HLPStreams *streams = [self streamsToHost:components.host port:components.port.integerValue];
    return streams;
}

- (instancetype)initWithInput:(HLPInputStream *)input output:(HLPOutputStream *)output {
    self = super.init;
    if (self) {
        self.input = input;
        self.output = output;
    }
    return self;
}

- (HLPStreamsOpening *)openWithTimeout:(NSTimeInterval)timeout {
    HLPStreamsOpening *opening = [HLPStreamsOpening.alloc initWithTimeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (HLPStreamsOpening *)openWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    HLPStreamsOpening *opening = [self openWithTimeout:timeout];
    opening.completionBlock = completion;
    return opening;
}

@end















































@interface HLPStreamMessage ()

@end



@implementation HLPStreamMessage

- (NSInteger)readFromInput:(NSInputStream *)input {
    NSInteger result = [input read:self.data length:1024 all:NO];
    return result;
}

- (NSInteger)writeToOutput:(NSOutputStream *)output {
    NSInteger result = [output write:self.data all:NO];
    return result;
}

@end










@implementation NSInputStream (HLP)

- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length all:(BOOL)all {
    while (YES) {
        uint8_t buffer[length];
        NSInteger result = [self read:buffer maxLength:length];
        [data appendBytes:buffer length:result];
        if (result > 0) {
            if (all) {
                length -= result;
                if (length == 0) {
                    return result;
                }
            } else {
                return result;
            }
        } else {
            return result;
        }
    }
}

- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator {
    while (YES) {
        NSInteger result = [self read:data length:1 all:YES];
        if (result > 0) {
            if (data.length >= separator.length) {
                NSRange range = NSMakeRange(data.length - separator.length, separator.length);
                range = [data rangeOfData:separator options:0 range:range];
                if (range.location != NSNotFound) {
                    return result;
                }
            }
        } else {
            return result;
        }
    }
}

@end










@implementation NSOutputStream (HLP)

- (NSInteger)write:(NSMutableData *)data all:(BOOL)all {
    while (YES) {
        NSInteger result = [self write:data.bytes maxLength:data.length];
        if (result > 0) {
            NSRange range = NSMakeRange(0, result);
            [data replaceBytesInRange:range withBytes:NULL length:0];
            if (all) {
                if (data.length == 0) {
                    return result;
                }
            } else {
                return result;
            }
        } else {
            return result;
        }
    }
}

@end










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
