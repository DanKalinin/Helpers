//
//  Compressor.h
//  Intercom
//
//  Created by Dan Kalinin on 3/24/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <compression.h>
#import "Main.h"

@class Compression, Compressor;

extern NSErrorDomain const CompressionErrorDomain;

NS_ERROR_ENUM(CompressionErrorDomain) {
    CompressionErrorUnknown = 0
};










@interface Compression : Operation

@property (readonly) NSMutableData *srcData;
@property (readonly) NSMutableData *dstData;
@property (readonly) size_t chunk;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm srcData:(NSMutableData *)srcData dstData:(NSMutableData *)dstData chunk:(size_t)chunk;

@end










@interface Compressor : OperationQueue

@property (readonly) compression_stream_operation operation;
@property (readonly) compression_algorithm algorithm;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm;
- (Compression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk;

@end
