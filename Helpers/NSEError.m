//
//  NSEError.m
//  Helpers
//
//  Created by Dan Kalinin on 11/4/18.
//

#import "NSEError.h"



@implementation NSError (NSE)

+ (NSError *)threadError {
    return NSThread.currentThread.threadDictionary[NSStringFromSelector(@selector(threadError))];
}

+ (void)setThreadError:(NSError *)threadError {
    NSThread.currentThread.threadDictionary[NSStringFromSelector(@selector(threadError))] = threadError;
}

@end
