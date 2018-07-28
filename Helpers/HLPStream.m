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
    } else if (self.timer.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.parent.stream.streamStatus != NSStreamStatusOpen) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorNotOpen userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self.timer cancel];
    
    if (self.cancelled || (self.errors.count > 0)) {
        [self.parent.stream close];
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
    } else if (self.timer.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.parent.stream.streamStatus != NSStreamStatusOpen) {
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
    } else if (self.timer.finished) {
        NSError *error = [NSError errorWithDomain:HLPStreamErrorDomain code:HLPStreamErrorTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.parent.stream.streamStatus == NSStreamStatusError) {
        [self.errors addObject:self.parent.stream.streamError];
    } else if (self.parent.stream.streamStatus != NSStreamStatusOpen) {
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
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface HLPStreamsClosing ()

@property HLPStreamClosing *inputClosing;
@property HLPStreamClosing *outputClosing;

@end



@implementation HLPStreamsClosing

@dynamic parent;
@dynamic delegates;

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    self.inputClosing = [self.parent.input close];
    [self.inputClosing waitUntilFinished];
    [self updateProgress:1];
    
    self.outputClosing = [self.parent.output close];
    [self.outputClosing waitUntilFinished];
    [self updateProgress:2];
    
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

- (HLPStreamsClosing *)close {
    HLPStreamsClosing *closing = HLPStreamsClosing.new;
    [self addOperation:closing];
    return closing;
}

- (HLPStreamsClosing *)closeWithCompletion:(HLPVoidBlock)completion {
    HLPStreamsClosing *closing = [self close];
    closing.completionBlock = completion;
    return closing;
}

@end
