//
//  NSEOperationQueue.m
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEOperationQueue.h"



@implementation NSOperationQueue (NSE)

- (void)nseAddOperationWithBlockAndWait:(NSEBlock)block {
    BOOL current = [self isEqual:NSOperationQueue.currentQueue];
    if (current) {
        block();
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
        [self addOperation:operation];
        [operation waitUntilFinished];
    }
}

@end
