//
//  HLPNetService.h
//  Helpers
//
//  Created by Dan Kalinin on 5/14/18.
//

#import <Foundation/Foundation.h>
#import "HLPOperation.h"

@class HLPNetServiceResolution, HLPNetServiceBrowser;

typedef NSString * HLPNetServiceDomain NS_STRING_ENUM;
extern HLPNetServiceDomain const HLPNetServiceDomainLocal;










@protocol HLPNetServiceResolutionDelegate <HLPOperationDelegate, NSNetServiceDelegate>

@optional
- (void)resolutionDidUpdateState:(HLPNetServiceResolution *)resolution;
- (void)resolutionDidUpdateProgress:(HLPNetServiceResolution *)resolution;

- (void)resolutionDidBegin:(HLPNetServiceResolution *)resolution;
- (void)resolutionDidEnd:(HLPNetServiceResolution *)resolution;

@end



@interface HLPNetServiceResolution : HLPOperation <HLPNetServiceResolutionDelegate>

@property (readonly) SurrogateArray<HLPNetServiceResolutionDelegate> *delegates;
@property (readonly) NSNetService *service;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSUInteger limit;
@property (readonly) NSMutableArray<NSURLComponents *> *addresses;

- (instancetype)initWithService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit;

@end










@protocol HLPNetServiceBrowserDelegate <HLPOperationDelegate, NSNetServiceBrowserDelegate>

@end



@interface HLPNetServiceBrowser : HLPOperation <HLPNetServiceBrowserDelegate>

@property (readonly) SurrogateArray<HLPNetServiceBrowserDelegate> *delegates;
@property (readonly) NSNetServiceBrowser *browser;
@property (readonly) NSMutableArray<NSString *> *domains;
@property (readonly) NSMutableDictionary<NSString *, NSNetService *> *services;

- (HLPNetServiceResolution *)resolveService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit;
- (HLPNetServiceResolution *)resolveService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit completion:(VoidBlock)completion;

@end
