//
//  HLPCompression.m
//  Helpers
//
//  Created by Dan Kalinin on 3/24/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "HLPCompression.h"

const HLPOperationState HLPCompressionStateDidInit = 6;
const HLPOperationState HLPCompressionStateDidProcess = 7;

NSErrorDomain const HLPCompressionErrorDomain = @"HLPCompression";










@interface HLPCompression ()

@property NSMutableData *srcData;
@property NSMutableData *dstData;
@property size_t chunk;

@end



@implementation HLPCompression

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithSrcData:(NSMutableData *)srcData dstData:(NSMutableData *)dstData chunk:(size_t)chunk {
    self = super.init;
    if (self) {
        self.srcData = srcData;
        self.dstData = dstData;
        self.chunk = chunk;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = self.srcData.length;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    compression_stream stream;
    compression_status status = compression_stream_init(&stream, self.parent.op, self.parent.algorithm);
    if (status == COMPRESSION_STATUS_OK) {
        [self updateState:HLPCompressionStateDidInit];
        
        size_t dstSize = 2 * self.chunk;
        uint8_t *dstBuffer = malloc(dstSize);
        
        while (!self.cancelled) {
            if ((self.srcData.length == 0) && (stream.dst_size == dstSize)) {
                [self updateProgress:self.progress.totalUnitCount];
                break;
            } else {
                size_t srcSize = (self.srcData.length > self.chunk) ? self.chunk : self.srcData.length;
                compression_stream_flags flags = (self.srcData.length > self.chunk) ? 0 : COMPRESSION_STREAM_FINALIZE;
                
                stream.src_ptr = self.srcData.bytes;
                stream.src_size = srcSize;
                stream.dst_ptr = dstBuffer;
                stream.dst_size = dstSize;
                
                status = compression_stream_process(&stream, flags);
                if ((status == COMPRESSION_STATUS_OK) || status == COMPRESSION_STATUS_END) {
                    NSUInteger consumedLength = srcSize - stream.src_size;
                    NSRange range = NSMakeRange(0, consumedLength);
                    [self.srcData replaceBytesInRange:range withBytes:NULL length:0];

                    NSUInteger producedLength = dstSize - stream.dst_size;
                    [self.dstData appendBytes:dstBuffer length:producedLength];
                    
                    int64_t completedUnitCount = self.progress.totalUnitCount - self.srcData.length;
                    [self updateProgress:completedUnitCount];
                } else {
                    NSError *error = [NSError errorWithDomain:HLPCompressionErrorDomain code:HLPCompressionErrorUnknown userInfo:nil];
                    [self.errors addObject:error];
                    break;
                }
            }
        }
        
        free(dstBuffer);
        
        [self updateState:HLPCompressionStateDidProcess];
        
        status = compression_stream_destroy(&stream);
        if (status == COMPRESSION_STATUS_OK) {
        } else {
            NSError *error = [NSError errorWithDomain:HLPCompressionErrorDomain code:HLPCompressionErrorUnknown userInfo:nil];
            [self.errors addObject:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:HLPCompressionErrorDomain code:HLPCompressionErrorUnknown userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates HLPCompressionDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates HLPCompressionDidBegin:self];
    } else if (state == HLPCompressionStateDidInit) {
        [self.delegates HLPCompressionDidInit:self];
    } else if (state == HLPCompressionStateDidProcess) {
        [self.delegates HLPCompressionDidUpdateProgress:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates HLPCompressionDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates HLPCompressionDidUpdateProgress:self];
}

@end










@interface HLPCompressor ()

@property compression_stream_operation op;
@property compression_algorithm algorithm;

@end



@implementation HLPCompressor

@dynamic delegates;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm {
    self = super.init;
    if (self) {
        self.op = operation;
        self.algorithm = algorithm;
    }
    return self;
}

- (HLPCompression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk {
    HLPCompression *compression = [HLPCompression.alloc initWithSrcData:srcData dstData:dstData chunk:chunk];
    [self addOperation:compression];
    return compression;
}

- (HLPCompression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk completion:(HLPVoidBlock)completion {
    HLPCompression *compression = [self compress:srcData to:dstData chunk:chunk];
    compression.completionBlock = completion;
    return compression;
}

@end
