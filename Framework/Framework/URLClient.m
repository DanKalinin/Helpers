//
//  URLConnection.m
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import "URLClient.h"










@interface URLClient ()

@property Reachability *reachability;
@property NSURLSession *defaultSesssion;
@property NSURLSession *ephemeralSesssion;
@property NSURLSession *backgroundSession;

@end



@implementation URLClient

@dynamic delegates;

- (instancetype)init {
    self = super.init;
    if (self) {
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        self.defaultSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:self.delegates.operationQueue];
        
        configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        self.ephemeralSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:self.delegates.operationQueue];
        
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.bundle.bundleIdentifier];
        self.backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:self.delegates.operationQueue];
    }
    return self;
}

- (void)cancelAllOperations {
    [self.defaultSesssion invalidateAndCancel];
    [self.ephemeralSesssion invalidateAndCancel];
    [self.backgroundSession invalidateAndCancel];
}

- (void)setConfiguration:(NSURLSessionConfiguration *)configuration forSession:(NSURLSession *)session {
    [session invalidateAndCancel];
    
    if ([session isEqual:self.defaultSesssion]) {
        self.defaultSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:self.delegates.operationQueue];
    } else if ([session isEqual:self.ephemeralSesssion]) {
        self.ephemeralSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:self.delegates.operationQueue];
    } else {
        self.backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:self.delegates.operationQueue];
    }
}

#pragma mark - Reachability

#pragma mark - Session delegate



@end

//@interface URLConnection ()
//
//@property NSMutableArray<NSURLComponents *> *URLs;
//@property NSMutableArray<_Reachability *> *reachabilities;
//
//@property NSMutableArray<NSURLComponents *> *URLHistory;
//
//@end
//
//
//
//@implementation URLConnection
//
//- (instancetype)init {
//    self = super.init;
//    if (self) {
//        self.URLHistorySize = 10;
//        
//        self.URLs = NSMutableArray.array;
//        self.reachabilities = NSMutableArray.array;
//        
//        self.URLHistory = NSMutableArray.array;
//    }
//    return self;
//}
//
//- (NSURLComponents *)URL {
//    return nil;
//}
//
//@end
