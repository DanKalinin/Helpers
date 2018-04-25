//
//  URLConnection.m
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import "URLClient.h"










@interface URLLoad ()

@property NSArray<NSURLSessionTask *> *tasks;

@end



@implementation URLLoad

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
    [self updateState:OperationStateDidBegin];
    [self updateProgress:0];
    
    for (NSURLSessionTask *task in self.tasks) {
        dispatch_group_enter(self.group);
        
        task.strongDictionary[KeyData] = NSMutableData.data;
        task.weakDictionary[KeyLoad] = self;
        [task resume];
    }
    
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    [self updateState:OperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    for (NSURLSessionTask *task in self.tasks) {
        [task cancel];
    }
}

#pragma mark - Helpers

- (void)updateState:(OperationState)state {
    [super updateState:state];
    
    [self.delegates loadDidUpdateState:self];
    if (state == OperationStateDidBegin) {
        [self.delegates loadDidBegin:self];
    } else if (state == OperationStateDidEnd) {
        [self.delegates loadDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates loadDidUpdateProgress:self];
}

- (void)task:(NSURLSessionTask *)task completeWithError:(NSError *)error {
    dispatch_group_leave(self.group);
    
    if (error) {
        if (self.errors.count == 0) {
            [self.errors addObject:error];
            
            for (NSURLSessionTask *task in self.tasks) {
                [task cancel];
            }
        }
    } else {
        uint64_t completedUnitCount = self.progress.completedUnitCount + 1;
        [self updateProgress:completedUnitCount];
    }
}

@end










@interface URLClient ()

@property NSURLComponents *localComponents;
@property NSURLComponents *remoteComponents;
@property Reachability *reachability;
@property NSURLSession *defaultSesssion;
@property NSURLSession *ephemeralSesssion;
@property NSURLSession *backgroundSession;

@end



@implementation URLClient

@dynamic delegates;

- (instancetype)initWithLocalComponents:(NSURLComponents *)localComponents remoteComponents:(NSURLComponents *)remoteComponents {
    self = super.init;
    if (self) {
        self.localComponents = localComponents;
        self.remoteComponents = remoteComponents;
        
        self.reachability = [Reachability.alloc initWithLocalComponents:localComponents remoteComponents:remoteComponents];
        
        self.defaultConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
        self.ephemeralConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        self.backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.bundle.bundleIdentifier];
    }
    return self;
}

- (URLLoad *)loadWithTasks:(NSArray<NSURLSessionTask *> *)tasks {
    URLLoad *load = [URLLoad.alloc initWithTasks:tasks];
    [self addOperation:load];
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
    [dataTask.strongDictionary[KeyData] appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [task.weakDictionary[KeyLoad] task:task completeWithError:error];
}

@end
