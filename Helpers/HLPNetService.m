//
//  HLPNetService.m
//  Helpers
//
//  Created by Dan Kalinin on 5/14/18.
//

#import "HLPNetService.h"

HLPNetServiceDomain const HLPNetServiceDomainLocal = @"local";










@interface HLPNetServiceResolution ()

@property NSNetService *service;
@property NSTimeInterval timeout;
@property NSUInteger limit;

@end



@implementation HLPNetServiceResolution

@dynamic delegates;

- (instancetype)initWithService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit {
    self = super.init;
    if (self) {
        self.service = service;
        self.timeout = timeout;
        self.limit = limit;
        
        service.URLComponents = NSMutableArray.array;
    }
    return self;
}

- (void)main {
    self.progress.totalUnitCount = self.limit;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    dispatch_group_enter(self.group);
    self.service.delegate = self.delegates;
    [self.service resolveWithTimeout:self.timeout];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.service stop];
}

#pragma mark - Net service

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSError *error = [NSNetService errorFromErrorDictionary:errorDict];
    [self.errors addObject:error];
    
    dispatch_group_leave(self.group);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSURLComponents *address = [NSNetService URLComponentsFromAddressData:sender.addresses.lastObject];
    [sender.URLComponents addObject:address];
    
    self.progress.completedUnitCount = sender.addresses.count;
    
    if (sender.addresses.count == self.limit) {
        [sender stop];
    }
}

- (void)netServiceDidStop:(NSNetService *)sender {
    dispatch_group_leave(self.group);
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates HLPNetServiceResolutionDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates HLPNetServiceResolutionDidBegin:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates HLPNetServiceResolutionDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates HLPNetServiceResolutionDidUpdateProgress:self];
}

@end










@interface HLPNetServiceBrowser ()

@property NSNetServiceBrowser *browser;
@property NSMutableArray<NSString *> *domains;
@property NSMutableDictionary<NSString *, NSNetService *> *services;

@end



@implementation HLPNetServiceBrowser

@dynamic delegates;

- (instancetype)init {
    self = super.init;
    if (self) {
        self.browser = NSNetServiceBrowser.new;
        self.browser.delegate = self.delegates;
        
        self.domains = NSMutableArray.array;
        self.services = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)cancel {
    [self.browser stop];
}

- (HLPNetServiceResolution *)resolveService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit {
    HLPNetServiceResolution *resolution = [HLPNetServiceResolution.alloc initWithService:service timeout:timeout limit:limit];
    [self addOperation:resolution];
    return resolution;
}

- (HLPNetServiceResolution *)resolveService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit completion:(HLPVoidBlock)completion {
    HLPNetServiceResolution *resolution = [self resolveService:service timeout:timeout limit:limit];
    resolution.completionBlock = completion;
    return resolution;
}

#pragma mark - Net service browser

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    [self.domains addObject:domainString];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    [self.domains removeObject:domainString];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    self.services[service.name] = service;
    
    service.online = @YES;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    self.services[service.name] = nil;
    
    service.online = @NO;
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    [self.states removeAllObjects];
    [self.errors removeAllObjects];
    
    [self.domains removeAllObjects];
    [self.services removeAllObjects];
    
    [self updateState:HLPOperationStateDidBegin];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSError *error = [NSNetService errorFromErrorDictionary:errorDict];
    [self.errors addObject:error];
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    [self updateState:HLPOperationStateDidEnd];
}

@end










@implementation NSNetService (HLP)

#pragma mark - Accessors

- (NSMutableArray<NSURLComponents *> *)URLComponents {
    return self.strongDictionary[NSStringFromSelector(@selector(URLComponents))];
}

- (void)setURLComponents:(NSMutableArray<NSURLComponents *> *)URLComponents {
    self.strongDictionary[NSStringFromSelector(@selector(URLComponents))] = URLComponents;
}

- (NSNumber *)online {
    return self.strongDictionary[NSStringFromSelector(@selector(online))];
}

- (void)setOnline:(NSNumber *)online {
    self.strongDictionary[NSStringFromSelector(@selector(online))] = online;
}

@end
