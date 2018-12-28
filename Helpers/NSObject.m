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

- (Class)nseOperationClass {
    return NSObjectOperation.class;
}

- (NSObjectOperation *)nseOperation {
    NSObjectOperation *operation = self.strongDictionary[NSStringFromSelector(@selector(nseOperation))];
    if (operation) {
    } else {
        operation = [self.nseOperationClass.alloc initWithObject:self];
        self.strongDictionary[NSStringFromSelector(@selector(nseOperation))] = operation;
    }
    return operation;
}

@end
