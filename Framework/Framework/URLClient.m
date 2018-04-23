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
        self.defaultSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:nil];
        
        configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        self.ephemeralSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:nil];
        
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.bundle.bundleIdentifier];
        self.backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:nil];
    }
    return self;
}

- (void)cancelAllOperations {
    [self.defaultSesssion invalidateAndCancel];
    [self.ephemeralSesssion invalidateAndCancel];
    [self.backgroundSession invalidateAndCancel];
}

- (void)session:(NSURLSession *)session setConfiguration:(NSURLSessionConfiguration *)configuration {
    [session invalidateAndCancel];
    
    if ([session isEqual:self.defaultSesssion]) {
        self.defaultSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:nil];
    } else if ([session isEqual:self.ephemeralSesssion]) {
        self.ephemeralSesssion = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:nil];
    } else {
        self.backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self.delegates delegateQueue:nil];
    }
}

#pragma mark - Reachability

#pragma mark - Session delegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
}

@end
