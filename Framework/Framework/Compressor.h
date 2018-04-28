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

extern const OperationState CompressionStateDidInit;
extern const OperationState CompressionStateDidProcess;

extern NSErrorDomain const CompressionErrorDomain;

NS_ERROR_ENUM(CompressionErrorDomain) {
    CompressionErrorUnknown = 0
};










@protocol CompressionDelegate <OperationDelegate>

@optional
- (void)compressionDidUpdateState:(Compression *)compression;
- (void)compressionDidUpdateProgress:(Compression *)compression;

- (void)compressionDidBegin:(Compression *)compression;
- (void)compressionDidInit:(Compression *)compression;
- (void)compressionDidProcess:(Compression *)compression;
- (void)compressionDidEnd:(Compression *)compression;

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
@property (readonly) compression_stream_operation op;
@property (readonly) compression_algorithm algorithm;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm;
- (Compression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk;
- (Compression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk completion:(VoidBlock)completion;

@end
