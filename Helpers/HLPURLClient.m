//
//  HLPURLClient.m
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import "HLPURLClient.h"

NSErrorDomain const HLPURLHTTPErrorDomain = @"HLPURLHTTP";










@interface HLPURLLoad ()

@property NSArray<NSURLSessionTask *> *tasks;

@end



@implementation HLPURLLoad

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithTasks:(NSArray<NSURLSessionTask *> *)tasks {
    self = super.init;
    if (self) {
        self.tasks = tasks;
        
        self.progress.totalUnitCount = tasks.count;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    for (NSURLSessionTask *task in self.tasks) {
        dispatch_group_enter(self.group);
        
        task.data = NSMutableData.data;
        task.load = self;
        [task resume];
    }
    
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self cancelAllTasks];
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates HLPURLLoadDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates HLPURLLoadDidBegin:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates HLPURLLoadDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates HLPURLLoadDidUpdateProgress:self];
}

- (void)endTask:(NSURLSessionTask *)task {
    dispatch_group_leave(self.group);
    
    NSError *error = nil;
    if (task.error) {
        error = task.error;
    } else {
        if ([task.response isKindOfClass:NSHTTPURLResponse.class]) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if (response.statusCode >= HLPURLHTTPStatusCodeBadRequest) {
                error = [NSError errorWithDomain:HLPURLHTTPErrorDomain code:response.statusCode userInfo:nil];
            }
        }
    }
    
    if (error) {
        if (self.errors.count == 0) {
            if (self.cancelled) {
            } else {
                [self.errors addObject:error];
                [self cancelAllTasks];
            }
        }
    } else {
        uint64_t completedUnitCount = self.progress.completedUnitCount + 1;
        [self updateProgress:completedUnitCount];
        
        [self.delegates HLPURLLoad:self didEndTask:task];
    }
}

- (void)cancelAllTasks {
    for (NSURLSessionTask *task in self.tasks) {
        [task cancel];
    }
}

@end










@interface HLPURLClient ()

@property HLPReachability *reachability;
@property NSURLSession *defaultSesssion;
@property NSURLSession *ephemeralSesssion;
@property NSURLSession *backgroundSession;

@end



@implementation HLPURLClient

@dynamic delegates;

- (instancetype)init {
    self = super.init;
    if (self) {
        self.defaultConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
        self.ephemeralConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        self.backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.bundle.bundleIdentifier];
    }
    return self;
}

- (HLPURLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks {
    HLPURLLoad *load = [HLPURLLoad.alloc initWithTasks:tasks];
    [self addOperation:load];
    return load;
}

- (HLPURLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks completion:(HLPVoidBlock)completion {
    HLPURLLoad *load = [self loadWithTasks:tasks];
    load.completionBlock = completion;
    return load;
}

- (void)cancelAllOperations {
    [self.defaultSesssion invalidateAndCancel];
    [self.ephemeralSesssion invalidateAndCancel];
    [self.backgroundSession invalidateAndCancel];
}

#pragma mark - Accessors

- (void)setDefaultConfiguration:(NSURLSessionConfiguration *)defaultConfiguration {
    [self.defaultSesssion invalidateAndCancel];
    self.defaultSesssion = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self.delegates delegateQueue:nil];
}

- (NSURLSessionConfiguration *)defaultConfiguration {
    return self.defaultSesssion.configuration;
}

- (void)setEphemeralConfiguration:(NSURLSessionConfiguration *)ephemeralConfiguration {
    [self.ephemeralSesssion invalidateAndCancel];
    self.ephemeralSesssion = [NSURLSession sessionWithConfiguration:ephemeralConfiguration delegate:self.delegates delegateQueue:nil];
}

- (NSURLSessionConfiguration *)ephemeralConfiguration {
    return self.ephemeralSesssion.configuration;
}

- (void)setBackgroundConfiguration:(NSURLSessionConfiguration *)backgroundConfiguration {
    [self.backgroundSession invalidateAndCancel];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self.delegates delegateQueue:nil];
}

- (NSURLSessionConfiguration *)backgroundConfiguration {
    return self.backgroundSession.configuration;
}

#pragma mark - Reachability

#pragma mark - URL session

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [dataTask.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [task.load endTask:task];
}

@end










@interface HLPURLClientManager ()

@end



@implementation HLPURLClientManager

@dynamic delegates;

- (HLPURLClient *)client {
    return self.localClient;
}

@end










@implementation NSURLSessionTask (HLP)

#pragma mark - Accessors

- (HLPURLLoad *)load {
    return self.weakDictionary[NSStringFromSelector(@selector(load))];
}

- (void)setLoad:(HLPURLLoad *)load {
    self.weakDictionary[NSStringFromSelector(@selector(load))] = load;
}

- (NSMutableData *)data {
    return self.strongDictionary[NSStringFromSelector(@selector(data))];
}

- (void)setData:(NSMutableData *)data {
    self.strongDictionary[NSStringFromSelector(@selector(data))] = data;
}

@end
