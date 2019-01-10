//
//  NSEOperationQueue.m
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEOperationQueue.h"



@implementation NSOperationQueue (NSE)

- (void)nseAddOperationWithBlock:(NSEBlock)block waitUntilFinished:(BOOL)wait {
    if (block) {
        NSOperationQueue *queue = self.class.currentQueue;
        BOOL current = [self isEqual:queue];
        BOOL serial = (queue.maxConcurrentOperationCount == 1);
        BOOL invoke = (wait && current && serial);
        if (invoke) {
            block();
        } else {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
            [self addOperations:@[operation] waitUntilFinished:wait];
        }
    }
}

@end
