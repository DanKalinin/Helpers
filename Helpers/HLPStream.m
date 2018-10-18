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
@property HLPTick *tick;

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
    
    self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    
    [self.parent.stream open];
    while (!self.cancelled && (self.parent.stream.streamStatus == NSStreamStatusOpening) && !self.tick.finished) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    if (self.cancelled) {
    } else if (self.tick.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.parent.stream.streamStatus != NSStreamStatusOpen) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.tick cancel];
    
    if (self.cancelled || (self.errors.count > 0)) {
        [self.parent cancel];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStreamReading ()

@property NSMutableData *data;
@property NSUInteger minLength;
@property NSUInteger maxLength;
@property NSTimeInterval timeout;
@property HLPTick *tick;

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
    
    self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    
    while (!self.cancelled && (self.parent.stream.streamStatus == NSStreamStatusOpen) && (self.data.length < self.minLength) && (self.errors.count == 0) && !self.tick.finished) {
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
    } else if (self.tick.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.parent.stream.streamStatus != NSStreamStatusOpen) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.tick cancel];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStreamWriting ()

@property NSMutableData *data;
@property NSTimeInterval timeout;
@property HLPTick *tick;

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
    
    self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    
    while (!self.cancelled && (self.parent.stream.streamStatus == NSStreamStatusOpen) && (self.data.length > 0) && (self.errors.count == 0) && !self.tick.finished) {
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
    } else if (self.tick.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.parent.stream.streamStatus != NSStreamStatusOpen) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.tick cancel];
    
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
        
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)cancel {
    [self.stream close];
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
@property HLPStreamOpening *inputOpening;
@property HLPStreamOpening *outputOpening;

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
    
    self.operation = self.inputOpening = [self.parent.input openWithTimeout:self.timeout];
    [self.inputOpening waitUntilFinished];
    if (self.inputOpening.cancelled) {
    } else if (self.inputOpening.errors.count > 0) {
        [self.errors addObjectsFromArray:self.inputOpening.errors];
    } else {
        [self updateProgress:1];
        
        self.operation = self.outputOpening = [self.parent.output openWithTimeout:self.timeout];
        [self.outputOpening waitUntilFinished];
        if (self.outputOpening.cancelled) {
        } else if (self.outputOpening.errors.count > 0) {
            [self.errors addObjectsFromArray:self.outputOpening.errors];
        } else {
            [self updateProgress:2];
        }
        
        if (self.cancelled || (self.errors.count > 0)) {
            [self.parent.input cancel];
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
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

- (void)cancel {
    [self.input cancel];
    [self.output cancel];
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




















NSErrorDomain const NSEStreamErrorDomain = @"NSEStream";










@interface NSEStreamOpening ()

@property NSTimeInterval timeout;
@property NSETimer *timer;

@end



@implementation NSEStreamOpening

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.parent.opening = self;
    [self.parent.stream open];
    
    self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
    [self.timer waitUntilFinished];
    if (self.timer.isCancelled) {
    } else {
        NSError *error = [NSError errorWithDomain:NSEStreamErrorDomain code:NSEStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.isCancelled || (self.errors.count > 0)) {
        [self.parent close];
    }
    
    [self finish];
}

@end










@interface NSEStream ()

@property NSStream *stream;

@end



@implementation NSEStream

@dynamic delegates;

- (instancetype)initWithStream:(NSStream *)stream {
    self = super.init;
    if (self) {
        self.stream = stream;
        self.stream.delegate = self.delegates;
    }
    return self;
}

- (void)close {
    [self.stream close];
}

#pragma mark - Stream

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventOpenCompleted) {
        [self.opening.timer cancel];
    } else if (eventCode == NSStreamEventErrorOccurred) {
        [self.opening.errors addObject:aStream.streamError];
        [self.opening.timer cancel];
    } else if (eventCode == NSStreamEventEndEncountered) {
        
    }
}

@end
