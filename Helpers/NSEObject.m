//
//  NSEObject.m
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import "NSEObject.h"
#import "NSEDictionary.h"
#import <objc/runtime.h>










@implementation NSObject (NSE)

+ (instancetype)nseShared {
    static NSObject *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

+ (void)nseInvokeBlock:(NSEBlock)block {
    if (block) {
        block();
    }
}

- (Class)nseOperationClass {
    return NSEObjectOperation.class;
}

- (NSEObjectOperation *)nseOperation {
    NSEObjectOperation *operation = self.nseStrongDictionary[NSStringFromSelector(@selector(nseOperation))];
    
    if (operation) {
    } else {
        operation = [self.nseOperationClass.alloc initWithObject:self];
        self.nseStrongDictionary[NSStringFromSelector(@selector(nseOperation))] = operation;
    }
    
    return operation;
}

- (NSEDictionary *)nseWeakDictionary {
    NSEDictionary *dictionary = objc_getAssociatedObject(self, @selector(nseWeakDictionary));
    
    if (dictionary) {
    } else {
        dictionary = NSEDictionary.strongToWeakDictionary;
        objc_setAssociatedObject(self, @selector(nseWeakDictionary), dictionary, OBJC_ASSOCIATION_RETAIN);
    }
    
    return dictionary;
}

- (NSEDictionary *)nseStrongDictionary {
    NSEDictionary *dictionary = objc_getAssociatedObject(self, @selector(nseStrongDictionary));
    
    if (dictionary) {
    } else {
        dictionary = NSEDictionary.strongToStrongDictionary;
        objc_setAssociatedObject(self, @selector(nseStrongDictionary), dictionary, OBJC_ASSOCIATION_RETAIN);
    }
    
    return dictionary;
}

- (instancetype)nseAutorelease {
    __autoreleasing NSObject *object = self;
    return object;
}

- (void)nseInvokeBlock:(NSEBlock)block {
    [self.class nseInvokeBlock:block];
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










@interface NSECFObject ()

@property CFTypeRef object;

@end



@implementation NSECFObject

- (instancetype)initWithObject:(CFTypeRef)object {
    self = super.init;
    
    self.object = object;
    
    return self;
}

- (void)dealloc {
    CFRelease(self.object);
}

@end
