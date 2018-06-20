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
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    [self.backingStore removePointerAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self.backingStore compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.backingStore addPointer:pointer];
}

- (void)removeLastObject {
    [self.backingStore compact];
    
    NSUInteger index = self.backingStore.count - 1;
    [self.backingStore removePointerAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.backingStore compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.backingStore replacePointerAtIndex:index withPointer:pointer];
}

@end










@interface HLPProxyArray ()

@end



@implementation HLPProxyArray

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (id object in self) {
        if ([object respondsToSelector:anInvocation.selector]) {
            if (self.operationQueue) {
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

- (HLPProxyArray *)weakProxyArray {
    HLPProxyArray *array = HLPProxyArray.weakArray;
    [array addObjectsFromArray:self];
    return array;
}

- (HLPProxyArray *)strongProxyArray {
    HLPProxyArray *array = HLPProxyArray.strongArray;
    [array addObjectsFromArray:self];
    return array;
}

@end
