//
//  Stream.m
//  Intercom
//
//  Created by Dan Kalinin on 3/5/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "Stream.h"
#import <netinet/in.h>

const OperationState StreamPairStateDidOpen = 2;

const OperationState StreamLoadStateDidInit = 2;
const OperationState StreamLoadStateDidProcess = 3;

NSErrorDomain const StreamErrorDomain = @"Stream";










@implementation NSStream (Helpers)

@end



@implementation NSInputStream (Helpers)

- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length {
    uint8_t buffer[length];
    NSInteger result = [self read:buffer maxLength:length];
    if (result > 0) {
        [data appendBytes:buffer length:result];
    }
    return result;
}

- (NSInteger)readAll:(NSMutableData *)data {
    NSInteger length = 0;
    while (YES) {
        NSInteger result = [self read:data length:1024];
        if (result > 0) {
            length += result;
        } else if (result == 0) {
            return length;
        } else {
            return result;
        }
    }
}

- (NSInteger)readLine:(NSMutableData *)data {
    NSData *separator = [StringN dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger result = [self read:data until:separator];
    return result;
}

- (NSInteger)read:(NSMutableData *)data exactly:(NSUInteger)length {
    NSInteger remaining = length;
    while (YES) {
        NSInteger result = [self read:data length:length];
        if (result > 0) {
            remaining -= result;
            if (remaining == 0) {
                return length;
            }
        } else {
            return result;
        }
    }
}

- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator {
    NSInteger length = 0;
    while (YES) {
        NSInteger result = [self read:data length:1];
        if (result > 0) {
            length += result;
            if (data.length >= separator.length) {
                NSUInteger location = data.length - separator.length;
                NSRange range = NSMakeRange(location, separator.length);
                NSData *suffix = [data subdataWithRange:range];
                if ([suffix isEqualToData:separator]) {
                    return length;
                }
            }
        } else {
            return result;
        }
    }
}

@end



@implementation NSOutputStream (Helpers)

- (NSInteger)write:(NSMutableData *)data {
    NSInteger result = [self write:data.bytes maxLength:data.length];
    return result;
}

- (NSInteger)writeAll:(NSMutableData *)data {
    NSInteger length = data.length;
    while (YES) {
        NSInteger result = [self write:data];
        if (result > 0) {
            NSRange range = NSMakeRange(0, result);
            [data replaceBytesInRange:range withBytes:NULL length:0];
            if (data.length == 0) {
                return length;
            }
        } else {
            return result;
        }
    }
}

@end










@interface StreamMessage ()

@end



@implementation StreamMessage

- (NSInteger)readFromStream:(NSInputStream *)inputStream {
    return 0;
}

- (NSInteger)writeToStream:(NSOutputStream *)outputStream {
    return 0;
}

@end










@interface StreamLoad ()

@property StreamLoadOperation operation;
@property NSMutableData *data;
@property NSString *path;

@end



@implementation StreamLoad

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithOperation:(StreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path {
    self = super.init;
    if (self) {
        self.operation = operation;
        self.data = data;
        self.path = path;
        
        self.progress.totalUnitCount = data.length;
    }
    return self;
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates loadDidUpdateState:self];
    if (state == OperationStateDidBegin) {
        [self.delegates loadDidBegin:self];
    } else if (state == StreamLoadStateDidInit) {
        [self.delegates loadDidInit:self];
    } else if (state == StreamLoadStateDidProcess) {
        [self.delegates loadDidProcess:self];
    } else if (state == OperationStateDidEnd) {
        [self.delegates loadDidEnd:self];
    }
}

@end










@interface StreamPair ()

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property Sequence *sequence;
@property NSMutableDictionary<NSNumber *, StreamMessage *> *messages;

@property Sequence *loadSequence;
@property NSMutableDictionary<NSNumber *, NSMutableData *> *loadData;

@end



@implementation StreamPair

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    self = super.init;
    if (self) {
        self.inputStream = inputStream;
        self.outputStream = outputStream;
        
        self.progress.totalUnitCount = -1;
        
        self.timeout = 60.0;
        self.sequence = Sequence.new;
        self.messages = NSMutableDictionary.dictionary;
        
        self.loadChunk = 1024;
        self.loadDirectory = NSFileManager.defaultManager.userDownloadsDirectoryURL;
        self.loadSequence = Sequence.new;
        self.loadData = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)main {
    [self updateState:OperationStateDidBegin];
    
    [self.inputStream open];
    [self.outputStream open];
    
    while (!self.cancelled) {
        if (self.inputStream.streamStatus == NSStreamStatusOpening) {
            continue;
        } else if (self.inputStream.streamStatus == NSStreamStatusOpen) {
            [self updateState:StreamPairStateDidOpen];
            while (!self.cancelled) {
                if (self.inputStream.hasBytesAvailable) {
                    if (self.messageClass) {
                        StreamMessage *message = self.messageClass.new;
                        NSInteger result = [message readFromStream:self.inputStream];
                        if (result > 0) {
                            if (message.replySerial > 0) {
                                StreamMessage *msg = [self.messages popObjectForKey:@(message.replySerial)];
                                [msg.timer invalidate];
                                [self invokeHandler:msg.completion object:message object:nil queue:self.delegates.operationQueue];
                                msg.completion = nil;
                            } else {
                                [self.delegates pair:self didReceiveMessage:message];
                            }
                        } else {
                            NSError *error = (result < 0) ? self.inputStream.streamError : [NSError errorWithDomain:StreamErrorDomain code:StreamErrorClosed userInfo:nil];
                            [self.errors addObject:error];
                            [self completeMessagesWithError:error];
                            break;
                        }
                    } else {
                        NSMutableData *data = NSMutableData.data;
                        NSInteger result = [self.inputStream read:data length:1024];
                        if (result > 0) {
                            [self.delegates pair:self didReceiveData:data];
                        } else {
                            NSError *error = (result < 0) ? self.inputStream.streamError : [NSError errorWithDomain:StreamErrorDomain code:StreamErrorClosed userInfo:nil];
                            [self.errors addObject:error];
                            break;
                        }
                    }
                }
            }
            break;
        } else {
            [self.errors addObject:self.inputStream.streamError];
            break;
        }
    }
    
    if (self.cancelled) {
        NSError *error = [NSError errorWithDomain:StreamErrorDomain code:StreamErrorCancelled userInfo:nil];
        [self completeMessagesWithError:error];
    }
    
    [self.inputStream close];
    [self.outputStream close];
    
    [self updateState:OperationStateDidEnd];
}

- (void)writeMessage:(StreamMessage *)message completion:(StreamMessageErrorBlock)completion {
    message.serial = self.sequence.value;
    [self.sequence increment];
    
    NSInteger result = [message writeToStream:self.outputStream];
    if (result > 0) {
        if (message.reply) {
            message.completion = completion;
            self.messages[@(message.serial)] = message;
            message.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer *timer) {
                self.messages[@(message.serial)] = nil;
                NSError *error = [NSError errorWithDomain:StreamErrorDomain code:StreamErrorTimedOut userInfo:nil];
                [self invokeHandler:completion object:nil object:error queue:self.delegates.operationQueue];
            }];
        } else {
            [self invokeHandler:completion object:message object:nil queue:self.delegates.operationQueue];
        }
    } else if (result == 0) {
        NSError *error = [NSError errorWithDomain:StreamErrorDomain code:StreamErrorClosed userInfo:nil];
        [self invokeHandler:completion object:nil object:error queue:self.delegates.operationQueue];
    } else {
        [self invokeHandler:completion object:nil object:self.outputStream.streamError queue:self.delegates.operationQueue];
    }
}

- (StreamMessage *)writeMessage:(StreamMessage *)message error:(NSError **)error {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    __block StreamMessage *msg;
    __block NSError *err;
    [self writeMessage:message completion:^(StreamMessage *message, NSError *error) {
        msg = message;
        err = error;
        dispatch_group_leave(group);
    }];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    *error = err;
    return msg;
}

- (StreamLoad *)load:(StreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path {
    StreamLoad *load = [self.loadClass.alloc initWithOperation:operation data:data path:path];
    [self addOperation:load];
    return load;
}

- (StreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path {
    StreamLoad *load = [self load:StreamLoadOperationUp data:data path:path];
    return load;
}

- (StreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path {
    StreamLoad *load = [self load:StreamLoadOperationDown data:data path:path];
    return load;
}

#pragma mark - Accessors

- (StreamClient *)client {
    return (StreamClient *)self.parent;
}

- (StreamServer *)server {
    return (StreamServer *)self.parent;
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates pairDidUpdateState:self];
    if (state == OperationStateDidBegin) {
        [self.delegates pairDidBegin:self];
    } else if (state == StreamPairStateDidOpen) {
        [self.delegates pairDidOpen:self];
    } else if (state == OperationStateDidEnd) {
        [self.delegates pairDidEnd:self];
    }
}

- (void)completeMessagesWithError:(NSError *)error {
    for (NSNumber *serial in self.messages.allKeys) {
        StreamMessage *message = [self.messages popObjectForKey:serial];
        [message.timer invalidate];
        [self invokeHandler:message.completion object:nil object:error queue:self.delegates.operationQueue];
        message.completion = nil;
    }
}

@end










@interface StreamEndpoint ()

@end



@implementation StreamEndpoint

@dynamic delegates;

- (instancetype)initWithPair:(Class)pair {
    self = super.init;
    if (self) {
        self.pairClass = pair;
    }
    return self;
}

#pragma mark - Helpers

- (void)startInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    StreamPair *pair = [self.pairClass.alloc initWithInputStream:inputStream outputStream:outputStream];
    [self addOperation:pair];
}

@end










@interface StreamClient ()

@end



@implementation StreamClient

@dynamic operation;

- (instancetype)initWithPair:(Class)pair {
    self = [super initWithPair:pair];
    if (self) {
    }
    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream pair:(Class)pair {
    self = [self initWithPair:pair];
    
    [self startInputStream:inputStream outputStream:outputStream];
    return self;
}

- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    [NSStream getStreamsToHostWithName:components.host port:components.port.integerValue inputStream:&inputStream outputStream:&outputStream];
    
    self = [self initWithInputStream:inputStream outputStream:outputStream pair:pair];
    return self;
}

@end










static void StreamServerAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);



@interface StreamServer ()

@end



@implementation StreamServer

@dynamic operations;

- (instancetype)initWithPair:(Class)pair {
    self = [super initWithPair:pair];
    if (self) {
    }
    return self;
}

- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair {
    self = [self initWithPair:pair];
    
    // Create
    
    CFSocketContext ctx = {0};
    ctx.info = (__bridge void *)self;
    CFSocketRef socket = CFSocketCreate(NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, StreamServerAcceptCallback, &ctx);
    
    // Bind
    
    components.host = HostAny;
    struct sockaddr address = components.address;
    
    NSData *data = [NSData dataWithBytes:&address length:sizeof(address)];
    CFSocketSetAddress(socket, (__bridge CFDataRef)data);
    
    // Listen
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(NULL, socket, 0);
    CFRunLoopAddSource(loop, source, kCFRunLoopDefaultMode);
    
    return self;
}

@end



static void StreamServerAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFSocketNativeHandle handle = CFSocketGetNative(socket);
    CFStreamCreatePairWithSocket(NULL, handle, &readStream, &writeStream);
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    StreamServer *server = (__bridge StreamServer *)info;
    [server startInputStream:inputStream outputStream:outputStream];
}
