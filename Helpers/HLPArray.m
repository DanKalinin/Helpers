//
//  HLPArray.m
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import "HLPArray.h"










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

@end
