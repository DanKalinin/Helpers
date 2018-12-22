//
//  NSObject.m
//  Helpers
//
//  Created by Dan Kalinin on 12/22/18.
//

#import "NSObject.h"



@interface NSObjectOperation ()

@property NSObject *object;

@end



@implementation NSObjectOperation

- (instancetype)initWithObject:(NSObject *)object {
    self = super.init;
    if (self) {
        self.object = object;
    }
    return self;
}

@end
