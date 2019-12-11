//
//  HLPArray.m
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import "HLPArray.h"
#import "HLPOperation.h"










@interface HLPArray ()

@property NSPointerArray *backingStore;
@property NSMutableSet<NSString *> *exceptions;

@end



@implementation HLPArray

+ (instancetype)weakArray {
    HLPArray *array = [self.alloc initWithBackingStore:NSPointerArray.weakObjectsPointerArray];
    return array;
}

+ (instancetype)strongArray {
    HLPArray *array = [self.alloc initWithBackingStore:NSPointerArray.strongObjectsPointerArray];
    return array;
}

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore {
    self = super.init;
    if (self) {
        self.backingStore = backingStore;
        
        self.exceptions = NSMutableSet.set;
    }
    return self;
}

#pragma mark - Array

- (instancetype)init {
    self = [self initWithBackingStore:NSPointerArray.strongObjectsPointerArray];
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [self initWithBackingStore:NSPointerArray.strongObjectsPointerArray];
    return self;
}

- (NSUInteger)count {
    [self.backingStore compact];
    
    return self.backingStore.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    id object = (__bridge id)[self.backingStore pointerAtIndex:index];
    return object;
}

#pragma mark - Mutable array

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.backingStore insertPointer:pointer atIndex:index];
    
    [self didAddObject:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    [self willRemoveObject:self[index]];
    
    [self.backingStore removePointerAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self.backingStore compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.backingStore addPointer:pointer];
    
    [self didAddObject:anObject];
}

- (void)removeLastObject {
    [self.backingStore compact];
    
    [self willRemoveObject:self.lastObject];
    
    NSUInteger index = self.backingStore.count - 1;
    [self.backingStore removePointerAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.backingStore compact];
    
    [self willRemoveObject:self[index]];
    
    void *pointer = (__bridge void *)anObject;
    [self.backingStore replacePointerAtIndex:index withPointer:pointer];
    
    [self didAddObject:anObject];
}

#pragma mark - Proxy

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (id object in self) {
        if ([object respondsToSelector:anInvocation.selector]) {
            if (self.operationQueue && ![self.exceptions containsObject:NSStringFromSelector(anInvocation.selector)]) {
                [self.operationQueue addOperationWithBlockAndWait:^{
                    [anInvocation invokeWithTarget:object];
                }];
            } else {
                [anInvocation invokeWithTarget:object];
            }
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (signature) {
        return signature;
    }
    
    for (id object in self) {
        signature = [object methodSignatureForSelector:aSelector];
        if (signature) {
            return signature;
        }
    }
    
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    for (id object in self) {
        if ([object respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Helpers

- (void)didAddObject:(id)object {
    if ([object isKindOfClass:self.class]) {
        HLPArray *array = object;
        [array.exceptions unionSet:self.exceptions];
        for (id object in array) {
            [array didAddObject:object];
        }
    }
}

- (void)willRemoveObject:(id)object {
    if ([object isKindOfClass:self.class]) {
        HLPArray *array = object;
        [array.exceptions minusSet:self.exceptions];
        for (id object in array) {
            [array willRemoveObject:object];
        }
    }
}

@end










@implementation NSArray (HLP)

- (HLPArray *)weakArray {
    HLPArray *array = HLPArray.weakArray;
    [array addObjectsFromArray:self];
    return array;
}

- (HLPArray *)strongArray {
    HLPArray *array = HLPArray.strongArray;
    [array addObjectsFromArray:self];
    return array;
}

@end
