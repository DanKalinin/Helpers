//
//  NSObject.m
//  Helpers
//
//  Created by Dan Kalinin on 12/22/18.
//

#import "NSObject.h"










@interface NSObjectOperation ()

@property (weak) NSObject *object;

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










@implementation NSObject (NSE)

- (Class)operationClass {
    return NSObjectOperation.class;
}

- (NSObjectOperation *)operation {
    NSObjectOperation *operation = self.strongDictionary[NSStringFromSelector(@selector(operation))];
    if (operation) {
    } else {
        operation = [self.operationClass.alloc initWithObject:self];
        self.strongDictionary[NSStringFromSelector(@selector(operation))] = operation;
    }
    return operation;
}

@end
