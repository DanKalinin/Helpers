//
//  HLPException.m
//  Helpers
//
//  Created by Dan Kalinin on 10/3/18.
//

#import "HLPException.h"



@interface HLPException ()

@property NSError *error;

@end



@implementation HLPException

- (instancetype)initWithError:(NSError *)error {
    self = [super initWithName:@"" reason:nil userInfo:nil];
    if (self) {
        self.error = error;
    }
    return self;
}

+ (instancetype)exceptionWithError:(NSError *)error {
    HLPException *exception = [self.alloc initWithError:error];
    return exception;
}

+ (instancetype)exceptionWithStatus:(OSStatus)status {
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    HLPException *exception = [self.alloc initWithError:error];
    return exception;
}

+ (void)raiseWithError:(NSError *)error {
    if (error) {
        HLPException *exception = [self exceptionWithError:error];
        [exception raise];
    } else {
    }
}

+ (void)raiseWithStatus:(OSStatus)status {
    if (status == noErr) {
    } else {
        HLPException *exception = [self exceptionWithStatus:status];
        [exception raise];
    }
}

@end
