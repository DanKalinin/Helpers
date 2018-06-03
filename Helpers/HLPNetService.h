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
- (void)HLPNetServiceResolutionDidUpdateState:(HLPNetServiceResolution *)resolution;
- (void)HLPNetServiceResolutionDidUpdateProgress:(HLPNetServiceResolution *)resolution;

- (void)HLPNetServiceResolutionDidBegin:(HLPNetServiceResolution *)resolution;
- (void)HLPNetServiceResolutionDidEnd:(HLPNetServiceResolution *)resolution;

@end



@interface HLPNetServiceResolution : HLPOperation <HLPNetServiceResolutionDelegate>

@property (readonly) SurrogateArray<HLPNetServiceResolutionDelegate> *delegates;
@property (readonly) NSNetService *service;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSUInteger limit;

- (instancetype)initWithService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit;

@end










@protocol HLPNetServiceBrowserDelegate <HLPNetServiceResolutionDelegate, NSNetServiceBrowserDelegate>

@end



@interface HLPNetServiceBrowser : HLPOperation <HLPNetServiceBrowserDelegate>

@property (readonly) SurrogateArray<HLPNetServiceBrowserDelegate> *delegates;
@property (readonly) NSNetServiceBrowser *browser;
@property (readonly) NSMutableArray<NSString *> *domains;
@property (readonly) NSMutableDictionary<NSString *, NSNetService *> *services;

- (HLPNetServiceResolution *)resolveService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit;
- (HLPNetServiceResolution *)resolveService:(NSNetService *)service timeout:(NSTimeInterval)timeout limit:(NSUInteger)limit completion:(VoidBlock)completion;

@end










@interface NSNetService (HLP)

@property NSMutableArray<NSURLComponents *> *URLComponents;
@property NSNumber *online;

@end
