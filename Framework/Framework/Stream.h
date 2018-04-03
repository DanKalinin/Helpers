//
//  Stream.h
//  Intercom
//
//  Created by Dan Kalinin on 3/5/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Main.h"
#import "Operation.h"

@class StreamMessage, StreamLoad, StreamPair, StreamEndpoint, StreamClient, StreamServer;

typedef void (^StreamMessageErrorBlock)(__kindof StreamMessage *message, NSError *error);

extern const OperationState StreamPairStateDidOpen;

extern NSErrorDomain const StreamErrorDomain;

NS_ERROR_ENUM(StreamErrorDomain) {
    StreamErrorUnknown = 0,
    StreamErrorTimedOut = 1,
    StreamErrorClosed = 2
};

typedef NS_ENUM(NSUInteger, StreamLoadOperation) {
    StreamLoadOperationUp = 1,
    StreamLoadOperationDown = 2
};










@interface NSStream (Helpers)

@end



@interface NSInputStream (Helpers)

- (NSInteger)read:(NSMutableData *)data length:(NSUInteger)length;
- (NSInteger)readAll:(NSMutableData *)data; // -> + - EOF, -1 - error
- (NSInteger)readLine:(NSMutableData *)data;
- (NSInteger)read:(NSMutableData *)data exactly:(NSUInteger)length;
- (NSInteger)read:(NSMutableData *)data until:(NSData *)separator;

@end



@interface NSOutputStream (Helpers)

- (NSInteger)write:(NSMutableData *)data;
- (NSInteger)writeAll:(NSMutableData *)data;
- (NSInteger)writeLines:(NSMutableArray<NSMutableData *> *)lines;
- (NSInteger)writeChunks:(NSMutableArray<NSMutableData *> *)chunks separator:(NSData *)separator;

@end










@interface StreamMessage : NSObject

@property BOOL reply;
@property NSUInteger serial;
@property NSUInteger replySerial;
@property StreamMessageErrorBlock completion;
@property NSTimer *timer;

- (NSInteger)readFromStream:(NSInputStream *)inputStream;
- (NSInteger)writeToStream:(NSOutputStream *)outputStream;

@end










@protocol StreamLoadDelegate <OperationDelegate>

@optional
- (void)loadDidUpdateState:(StreamLoad *)load;
- (void)loadDidUpdateProgress:(StreamLoad *)load;

@end



@interface StreamLoad : Operation <StreamLoadDelegate>

@property (readonly) StreamLoadOperation operation;
@property (readonly) NSMutableData *data;
@property (readonly) NSURL *file;
@property (readonly) NSURL *path;

- (instancetype)initWithOperation:(StreamLoadOperation)operation data:(NSMutableData *)data path:(NSString *)path;
- (instancetype)initWithOperation:(StreamLoadOperation)operation file:(NSURL *)file path:(NSString *)path;

@end










@protocol StreamPairDelegate <OperationDelegate>

@optional
- (void)pairDidUpdateState:(StreamPair *)pair;

- (void)pairDidBegin:(StreamPair *)pair;
- (void)pairDidOpen:(StreamPair *)pair;
- (void)pairDidEnd:(StreamPair *)pair;

- (void)pair:(StreamPair *)pair didReceiveData:(NSData *)data;
- (void)pair:(StreamPair *)pair didReceiveMessage:(StreamMessage *)message;

@end



@interface StreamPair : Operation <StreamPairDelegate>

@property Class messageClass;
@property NSTimeInterval timeout;
@property Proto protocol;
@property id object;

@property (readonly) StreamEndpoint *parent;
@property (readonly) StreamClient *client;
@property (readonly) StreamServer *server;
@property (readonly) SurrogateArray<StreamPairDelegate> *delegates;
@property (readonly) NSInputStream *inputStream;
@property (readonly) NSOutputStream *outputStream;
@property (readonly) Sequence *sequence;
@property (readonly) NSMutableDictionary<NSNumber *, StreamMessage *> *messages;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
- (void)writeMessage:(StreamMessage *)message completion:(StreamMessageErrorBlock)completion;
- (__kindof StreamMessage *)writeMessage:(StreamMessage *)message error:(NSError **)error;

@end










@interface StreamEndpoint : OperationQueue <StreamPairDelegate>

@property Class pairClass;

@property (readonly) SurrogateArray<StreamPairDelegate> *delegates;

- (instancetype)initWithPair:(Class)pair;
- (void)startInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

@end










@interface StreamClient : StreamEndpoint

@property (readonly) __kindof StreamPair *pair;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream pair:(Class)pair;
- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port pair:(Class)pair;

@end










@interface StreamServer : StreamEndpoint

@property (readonly) NSArray<__kindof StreamPair *> *pairs;

- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port pair:(Class)pair;

@end
