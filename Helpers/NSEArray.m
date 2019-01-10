//
//  NSEArray.m
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import "NSEArray.h"



@interface NSEArray ()

@property NSPointerArray *backingStore;
@property NSMutableSet<NSString *> *exceptions;

@end



@implementation NSEArray

+ (instancetype)weakArray {
    NSEArray *array = [self.alloc initWithBackingStore:NSPointerArray.weakObjectsPointerArray];
    return array;
}

+ (instancetype)strongArray {
    NSEArray *array = [self.alloc initWithBackingStore:NSPointerArray.strongObjectsPointerArray];
    return array;
}

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore {
    self = super.init;
    
    self.backingStore = backingStore;
    
    return self;
}

#pragma mark - NSArray

- (NSUInteger)count {
    [self.backingStore compact];
    
    return self.backingStore.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    id object = (__bridge id)[self.backingStore pointerAtIndex:index];
    return object;
}

#pragma mark - NSMutableArray

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    [self.backingStore insertPointer:(__bridge void *)anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    [self.backingStore removePointerAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self.backingStore compact];
    
    [self.backingStore addPointer:(__bridge void *)anObject];
}

- (void)removeLastObject {
    [self.backingStore compact];
    
    NSUInteger index = self.backingStore.count - 1;
    [self.backingStore removePointerAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.backingStore compact];
    
    [self.backingStore replacePointerAtIndex:index withPointer:(__bridge void *)anObject];
}

#pragma mark - NSObject

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (id target in self) {
        BOOL responds = [target respondsToSelector:anInvocation.selector];
        if (responds) {
            BOOL exception = [self.exceptions containsObject:NSStringFromSelector(anInvocation.selector)];
            if (self.queue && !exception) {
                [self.queue nseAddOperationWithBlockAndWait:^{
                    [anInvocation invokeWithTarget:target];
                }];
            } else {
                [anInvocation invokeWithTarget:target];
            }
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if (signature) {
    } else {
        for (id target in self) {
            signature = [target methodSignatureForSelector:aSelector];
            if (signature) {
                break;
            }
        }
    }
    
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL responds = [super respondsToSelector:aSelector];
    
    if (responds) {
    } else {
        for (id target in self) {
            responds = [target respondsToSelector:aSelector];
            if (responds) {
                break;
            }
        }
    }
    
    return responds;
}

@end
