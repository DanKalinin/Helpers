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
#import "Operation.h"

@class Compression, Compressor;

extern NSErrorDomain const CompressionErrorDomain;

NS_ERROR_ENUM(CompressionErrorDomain) {
    CompressionErrorUnknown = 0
};










@protocol CompressionDelegate <OperationDelegate>

@end



@interface Compression : Operation <CompressionDelegate>

@property (readonly) Compressor *parent;
@property (readonly) SurrogateArray<CompressionDelegate> *delegates;
@property (readonly) NSMutableData *srcData;
@property (readonly) NSMutableData *dstData;
@property (readonly) size_t chunk;

- (instancetype)initWithSrcData:(NSMutableData *)srcData dstData:(NSMutableData *)dstData chunk:(size_t)chunk;

@end










@interface Compressor : OperationQueue <CompressionDelegate>

@property (readonly) SurrogateArray<CompressionDelegate> *delegates;
@property (readonly) compression_stream_operation operation;
@property (readonly) compression_algorithm algorithm;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm;
- (Compression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk;

@end
