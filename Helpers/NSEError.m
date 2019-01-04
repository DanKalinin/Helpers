//
//  NSEError.m
//  Helpers
//
//  Created by Dan Kalinin on 11/4/18.
//

#import "NSEError.h"



@implementation NSError (NSE)

+ (NSError *)nseThreadError {
    NSError *error = NSThread.currentThread.threadDictionary[NSStringFromSelector(@selector(nseThreadError))];
    return error;
}

+ (void)setNseThreadError:(NSError *)nseThreadError {
    NSThread.currentThread.threadDictionary[NSStringFromSelector(@selector(nseThreadError))] = nseThreadError;
}

@end
