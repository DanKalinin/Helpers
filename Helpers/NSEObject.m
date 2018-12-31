//
//  NSEObject.m
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import "NSEObject.h"










@implementation NSObject (NSE)

- (Class)nseOperationClass {
    return NSEObjectOperation.class;
}

- (NSEObjectOperation *)nseOperation {
    NSEObjectOperation *operation = self.strongDictionary[NSStringFromSelector(@selector(nseOperation))];
    
    if (operation) {
    } else {
        operation = [self.nseOperationClass.alloc initWithObject:self];
        self.strongDictionary[NSStringFromSelector(@selector(nseOperation))] = operation;
    }
    
    return operation;
}

- (instancetype)nseAutorelease {
    __autoreleasing NSObject *object = self;
    return object;
}

@end










@interface NSEObject ()

@end



@implementation NSEObject

@end










@interface NSEObjectOperation ()

@property (weak) NSObject *object;

@end



@implementation NSEObjectOperation

- (instancetype)initWithObject:(NSObject *)object {
    self = super.init;
    
    self.object = object;
    
    return self;
}

@end
