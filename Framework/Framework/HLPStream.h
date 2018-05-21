//
//  HLPStream.h
//  Helpers
//
//  Created by Dan Kalinin on 3/5/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPMain.h"
#import "Operation.h"

@class HLPStreamMessage, HLPStreamLoad, HLPStreamPair, HLPStreamEndpoint, HLPStreamClient, HLPStreamServer;

typedef void (^HLPStreamMessageErrorBlock)(__kindof HLPStreamMessage *message, NSError *error);

extern const OperationState HLPStreamPairStateDidOpen;

extern const OperationState HLPStreamLoadStateDidInit;
extern const OperationState HLPStreamLoadStateDidProcess;

extern NSErrorDomain const HLPStreamErrorDomain;

NS_ERROR_ENUM(HLPStreamErrorDomain) {
    HLPStreamErrorUnknown = 0,
    HLPStreamErrorTimedOut = 1,
    HLPStreamErrorClosed = 2,
    HLPStreamErrorCancelled = 3
};

typedef NS_ENUM(NSUInteger, HLPStreamLoadOperation) {
    HLPStreamLoadOperationUp = 1,
    HLPStreamLoadOperationDown = 2
};










@interface NSStream (HLP)

@end



@interface NSInputStream (HLP)

- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length;
- (NSInteger)readAll:(NSMutableData *)data; // -> + - EOF, -1 - error
- (NSInteger)readLine:(NSMutableData *)data;
- (NSInteger)read:(NSMutableData *)data exactly:(NSUInteger)length;
- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator;

@end



@interface NSOutputStream (HLP)

- (NSInteger)write:(NSMutableData *)data;
- (NSInteger)writeAll:(NSMutableData *)data;
- (NSInteger)writeLines:(NSMutableArray<NSMutableData *> *)lines;
- (NSInteger)writeChunks:(NSMutableArray<NSMutableData *> *)chunks separator:(NSData *)separator;

@end










@interface HLPStreamMessage : NSObject

@property BOOL reply;
@property NSUInteger serial;
@property NSUInteger replySerial;
@property HLPStreamMessageErrorBlock completion;
@property NSTimer *timer;

- (NSInteger)readFromStream:(NSInputStream *)inputStream;
- (NSInteger)writeToStream:(NSOutputStream *)outputStream;

@end










@protocol HLPStreamLoadDelegate <OperationDelegate>

@optional
- (void)loadDidUpdateState:(HLPStreamLoad *)load;
- (void)loadDidUpdateProgress:(HLPStreamLoad *)load;

- (void)loadDidBegin:(HLPStreamLoad *)load;
- (void)loadDidInit:(HLPStreamLoad *)load;
- (void)loadDidProcess:(HLPStreamLoad *)load;
- (void)loadDidEnd:(HLPStreamLoad *)load;

@end



@interface HLPStreamLoad : Operation <HLPStreamLoadDelegate>

@property (readonly) __kindof HLPStreamPair *parent;
@property (readonly) SurrogateArray<HLPStreamLoadDelegate> *delegates;
@property (readonly) HLPStreamLoadOperation operation;
@property (readonly) NSMutableData *data;
@property (readonly) NSString *path;

- (instancetype)initWithOperation:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path;

@end










@protocol HLPStreamPairDelegate <OperationDelegate>

@optional
- (void)pairDidUpdateState:(HLPStreamPair *)pair;

- (void)pairDidBegin:(HLPStreamPair *)pair;
- (void)pairDidOpen:(HLPStreamPair *)pair;
- (void)pairDidEnd:(HLPStreamPair *)pair;

- (void)pair:(HLPStreamPair *)pair didReceiveData:(NSData *)data;
- (void)pair:(HLPStreamPair *)pair didReceiveMessage:(HLPStreamMessage *)message;

@end



@interface HLPStreamPair : Operation <HLPStreamPairDelegate>

@property Class messageClass;
@property NSTimeInterval timeout;
@property Proto protocol;
@property id object;

@property (readonly) HLPStreamEndpoint *parent;
@property (readonly) HLPStreamClient *client;
@property (readonly) HLPStreamServer *server;
@property (readonly) SurrogateArray<HLPStreamPairDelegate> *delegates;
@property (readonly) NSInputStream *inputStream;
@property (readonly) NSOutputStream *outputStream;
@property (readonly) Sequence *sequence;
@property (readonly) NSMutableDictionary<NSNumber *, HLPStreamMessage *> *messages;

@property Class loadClass;
@property NSUInteger loadChunk;
@property NSURL *loadDirectory;

@property (readonly) Sequence *loadSequence;
@property (readonly) NSMutableDictionary<NSNumber *, NSMutableData *> *loadData;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
- (void)writeMessage:(HLPStreamMessage *)message completion:(HLPStreamMessageErrorBlock)completion;
- (__kindof HLPStreamMessage *)writeMessage:(HLPStreamMessage *)message error:(NSError **)error;

- (__kindof HLPStreamLoad *)load:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path;
- (__kindof HLPStreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path;
- (__kindof HLPStreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path;

- (__kindof HLPStreamLoad *)load:(HLPStreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path completion:(VoidBlock)completion;
- (__kindof HLPStreamLoad *)uploadData:(NSMutableData *)data toPath:(NSString *)path completion:(VoidBlock)completion;
- (__kindof HLPStreamLoad *)downloadData:(NSMutableData *)data fromPath:(NSString *)path completion:(VoidBlock)completion;

@end










@interface HLPStreamEndpoint : OperationQueue <HLPStreamPairDelegate>

@property Class pairClass;

@property (readonly) SurrogateArray<HLPStreamPairDelegate> *delegates;

- (instancetype)initWithPair:(Class)pair;
- (__kindof HLPStreamPair *)pairWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

@end










@interface HLPStreamClient : HLPStreamEndpoint

@property (readonly) __kindof HLPStreamPair *operation;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream pair:(Class)pair;
- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair;

@end










@interface HLPStreamServer : HLPStreamEndpoint

@property (readonly, copy) NSArray<__kindof HLPStreamPair *> *operations;

- (instancetype)initWithComponents:(NSURLComponents *)components pair:(Class)pair;

@end
