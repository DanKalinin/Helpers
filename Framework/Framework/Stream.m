//
//  Stream.m
//  Intercom
//
//  Created by Dan Kalinin on 3/5/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "Stream.h"
#import <netinet/in.h>










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










@interface StreamPair ()

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property SurrogateArray<StreamPairDelegate> *delegates;
@property NSMutableDictionary<NSNumber *, StreamMessage *> *messages;
@property NSUInteger serial;

@end



@implementation StreamPair

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    self = super.init;
    if (self) {
        self.inputStream = inputStream;
        self.outputStream = outputStream;
        
        self.delegates = (id)SurrogateArray.new;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
        
        self.messages = NSMutableDictionary.dictionary;
        
        self.serial = 1;
        
        self.timeout = 60.0;
    }
    return self;
}

- (void)writeMessage:(StreamMessage *)message completion:(StreamMessageErrorBlock)completion {
    message.serial = self.serial;
    self.serial++;
    
    if (self.serial == 0) {
        self.serial = 1;
    }
    
    NSInteger result = [message writeToStream:self.outputStream];
    if (result > 0) {
        if (message.reply) {
            message.completion = completion;
            self.messages[@(message.serial)] = message;
            message.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer *timer) {
                self.messages[@(message.serial)] = nil;
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
                [self invokeHandler:completion object:nil object:error queue:self.delegates.operationQueue];
            }];
        } else {
            [self invokeHandler:completion object:message object:nil queue:self.delegates.operationQueue];
        }
    } else if (result == 0) {
    } else {
        [self invokeHandler:completion object:nil object:self.outputStream.streamError queue:self.delegates.operationQueue];
    }
}

#pragma mark - Accessors

- (StreamEndpoint *)endpoint {
    return self.delegates[1][0];
}

- (StreamClient *)client {
    return self.delegates[1][0];
}

- (StreamServer *)server {
    return self.delegates[1][0];
}

- (void)main {
    [self.inputStream open];
    [self.outputStream open];
    
    while (!self.cancelled) {
        if (self.inputStream.streamStatus == NSStreamStatusOpening) {
            continue;
        } else if (self.inputStream.streamStatus == NSStreamStatusOpen) {
            [self.delegates pairDidOpen:self];
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
                            } else {
                                [self.delegates pair:self didReceiveMessage:message];
                            }
                        } else {
                            [self.delegates pairDidClose:self];
                            break;
                        }
                    } else {
                        NSMutableData *data = NSMutableData.data;
                        NSInteger result = [self.inputStream read:data length:1024];
                        if (result > 0) {
                            [self.delegates pair:self didReceiveData:data];
                        } else {
                            [self.delegates pairDidClose:self];
                            break;
                        }
                    }
                }
            }
            break;
        } else {
            [self.delegates pairDidClose:self];
            break;
        }
    }
    
    [self.inputStream close];
    [self.outputStream close];
}

#pragma mark - Pair

- (void)pairDidOpen:(StreamPair *)pair {
    
}

- (void)pairDidClose:(StreamPair *)pair {
    
}

- (void)pair:(StreamPair *)pair didReceiveData:(NSData *)data {
    
}

- (void)pair:(StreamPair *)pair didReceiveMessage:(StreamMessage *)message {
    
}

@end










@interface StreamEndpoint ()

@property SurrogateArray<StreamPairDelegate> *delegates;

@end



@implementation StreamEndpoint

- (instancetype)initWithPair:(Class)pair {
    self = super.init;
    if (self) {
        self.pairClass = pair;
        
        self.delegates = (id)SurrogateArray.new;
        self.delegates.operationQueue = NSOperationQueue.mainQueue;
        [self.delegates addObject:self];
    }
    return self;
}

#pragma mark - Pair

- (void)pairDidOpen:(StreamPair *)pair {
    
}

- (void)pairDidClose:(StreamPair *)pair {
    
}

- (void)pair:(StreamPair *)pair didReceiveData:(NSData *)data {
    
}

- (void)pair:(StreamPair *)pair didReceiveMessage:(StreamMessage *)message {
    
}

#pragma mark - Helpers

- (void)startInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    StreamPair *pair = [self.pairClass.alloc initWithInputStream:inputStream outputStream:outputStream];
    pair.delegates.operationQueue = self.delegates.operationQueue;
    [pair.delegates addObject:self.delegates];
    [self addOperation:pair];
}

@end










@interface StreamClient ()

@end



@implementation StreamClient

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

- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port pair:(Class)pair {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    [NSStream getStreamsToHostWithName:host port:port inputStream:&inputStream outputStream:&outputStream];
    
    self = [self initWithInputStream:inputStream outputStream:outputStream pair:pair];
    return self;
}

- (StreamPair *)pair {
    return self.operations.firstObject;
}

@end










static void StreamServerAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);



@interface StreamServer ()

@end



@implementation StreamServer

- (instancetype)initWithPair:(Class)pair {
    self = [super initWithPair:pair];
    if (self) {
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port pair:(Class)pair {
    self = [self initWithPair:pair];
    
    // Create
    
    CFSocketContext ctx = {0};
    ctx.info = (__bridge void *)self;
    CFSocketRef socket = CFSocketCreate(NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, StreamServerAcceptCallback, &ctx);
    
    // Bind
    
    struct sockaddr_in address = {0};
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = INADDR_ANY;
    
    NSData *data = [NSData dataWithBytes:&address length:sizeof(address)];
    CFSocketSetAddress(socket, (__bridge CFDataRef)data);
    
    // Listen
    
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(NULL, socket, 0);
    CFRunLoopAddSource(loop, source, kCFRunLoopDefaultMode);
    
    return self;
}

- (NSArray<StreamPair *> *)pairs {
    return self.operations;
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
