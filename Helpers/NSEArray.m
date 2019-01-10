//
//  NSEArray.m
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import "NSEArray.h"
#import "NSEOperationQueue.h"










@implementation NSArray (NSE)

- (NSEArray *)nseWeakArray {
    NSEArray *array = NSEArray.weakArray;
    [array addObjectsFromArray:self];
    return array;
}

- (NSEArray *)nseStrongArray {
    NSEArray *array = NSEArray.strongArray;
    [array addObjectsFromArray:self];
    return array;
}

@end










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
    
    self.exceptions = NSMutableSet.set;
    
    return self;
}

- (void)didAddObject:(id)object {
    BOOL kind = [object isKindOfClass:self.class];
    if (kind) {
        NSEArray *array = object;
        [array.exceptions unionSet:self.exceptions];
        for (object in array) {
            [array didAddObject:object];
        }
    }
}

- (void)willRemoveObject:(id)object {
    BOOL kind = [object isKindOfClass:self.class];
    if (kind) {
        NSEArray *array = object;
        [array.exceptions minusSet:self.exceptions];
        for (object in array) {
            [array willRemoveObject:object];
        }
    }
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
    
    [self didAddObject:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.backingStore compact];
    
    id object = self[index];
    [self willRemoveObject:object];
    
    [self.backingStore removePointerAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self.backingStore compact];
    
    [self.backingStore addPointer:(__bridge void *)anObject];
    
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
    
    id object = self[index];
    [self willRemoveObject:object];
    
    [self.backingStore replacePointerAtIndex:index withPointer:(__bridge void *)anObject];
    
    [self didAddObject:anObject];
}

#pragma mark - NSObject

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (id target in self) {
        BOOL responds = [target respondsToSelector:anInvocation.selector];
        if (responds) {
            BOOL exception = [self.exceptions containsObject:NSStringFromSelector(anInvocation.selector)];
            if (self.queue && !exception) {
                [self.queue nseAddOperationWithBlock:^{
                    [anInvocation invokeWithTarget:target];
                } waitUntilFinished:YES];
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
