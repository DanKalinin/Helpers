//
//  HLPCompression.h
//  Helpers
//
//  Created by Dan Kalinin on 3/24/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <compression.h>
#import "HLPMain.h"
#import "HLPOperation.h"

@class HLPCompression, HLPCompressor;

extern const HLPOperationState HLPCompressionStateDidInit;
extern const HLPOperationState HLPCompressionStateDidProcess;

extern NSErrorDomain const HLPCompressionErrorDomain;

NS_ERROR_ENUM(HLPCompressionErrorDomain) {
    HLPCompressionErrorUnknown = 0
};










@protocol HLPCompressionDelegate <HLPOperationDelegate>

@optional
- (void)compressionDidUpdateState:(HLPCompression *)compression;
- (void)compressionDidUpdateProgress:(HLPCompression *)compression;

- (void)compressionDidBegin:(HLPCompression *)compression;
- (void)compressionDidInit:(HLPCompression *)compression;
- (void)compressionDidProcess:(HLPCompression *)compression;
- (void)compressionDidEnd:(HLPCompression *)compression;

@end



@interface HLPCompression : HLPOperation <HLPCompressionDelegate>

@property (readonly) HLPCompressor *parent;
@property (readonly) SurrogateArray<HLPCompressionDelegate> *delegates;
@property (readonly) NSMutableData *srcData;
@property (readonly) NSMutableData *dstData;
@property (readonly) size_t chunk;

- (instancetype)initWithSrcData:(NSMutableData *)srcData dstData:(NSMutableData *)dstData chunk:(size_t)chunk;

@end










@interface HLPCompressor : HLPOperationQueue <HLPCompressionDelegate>

@property (readonly) SurrogateArray<HLPCompressionDelegate> *delegates;
@property (readonly) compression_stream_operation op;
@property (readonly) compression_algorithm algorithm;

- (instancetype)initWithOperation:(compression_stream_operation)operation algorithm:(compression_algorithm)algorithm;
- (HLPCompression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk;
- (HLPCompression *)compress:(NSMutableData *)srcData to:(NSMutableData *)dstData chunk:(size_t)chunk completion:(VoidBlock)completion;

@end
