//
//  Compressor.m
//  Intercom
//
//  Created by Dan Kalinin on 3/24/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "Compressor.h"

const OperationState CompressionStateDidInit = 2;
const OperationState CompressionStateDidProcess = 3;

NSErrorDomain const CompressionErrorDomain = @"Compression";










@interface Compression ()

@property NSMutableData *srcData;
@property NSMutableData *dstData;
@property size_t chunk;

@end



@implementation Compression

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithSrcData:(NSMutableData *)srcData dstData:(NSMutableData *)dstData chunk:(size_t)chunk {
    self = super.init;
    if (self) {
        self.srcData = srcData;
        self.dstData = dstData;
        self.chunk = chunk;
        
        self.progress.totalUnitCount = srcData.length;
    }
    return self;
}

- (void)main {
    [self updateState:OperationStateDidBegin];
    [self updateProgress:0];
    
    compression_stream stream;
    compression_status status = compression_stream_init(&stream, self.parent.op, self.parent.algorithm);
    if (status == COMPRESSION_STATUS_OK) {
        [self updateState:CompressionStateDidInit];
        
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
                    NSError *error = [NSError errorWithDomain:CompressionErrorDomain code:CompressionErrorUnknown userInfo:nil];
                    [self.errors addObject:error];
                    break;
                }
            }
        }
        
        free(dstBuffer);
        
        [self updateState:CompressionStateDidProcess];
        
        status = compression_stream_destroy(&stream);
        if (status == COMPRESSION_STATUS_OK) {
        } else {
            NSError *error = [NSError errorWithDomain:CompressionErrorDomain code:CompressionErrorUnknown userInfo:nil];
            [self.errors addObject:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:CompressionErrorDomain code:CompressionErrorUnknown userInfo:nil];
        [self.errors addObject:error];
    }
    
    [self updateState:OperationStateDidEnd];
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates compressionDidUpdateState:self];
    if (state == OperationStateDidBegin) {
        [self.delegates compressionDidBegin:self];
    } else if (state == CompressionStateDidInit) {
        [self.delegates compressionDidInit:self];
    } else if (state == CompressionStateDidProcess) {
        [self.delegates compressionDidUpdateProgress:self];
    } else if (state == OperationStateDidEnd) {
        [self.delegates compressionDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates compressionDidUpdateProgress:self];
}

@end










@interface Compressor ()

@property compression_stream_operation op;
@property compression_algorithm algorithm;

@end



@implementation Compressor

@dynamic delegates;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm {
    self = super.init;
    if (self) {
        self.op = operation;
        self.algorithm = algorithm;
    }
    return self;
}

- (Compression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk {
    Compression *compression = [Compression.alloc initWithSrcData:srcData dstData:dstData chunk:chunk];
    [self addOperation:compression];
    return compression;
}

@end
