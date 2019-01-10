//
//  NSEOrderedSet.m
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import "NSEOrderedSet.h"



@interface NSEOrderedSet ()

@property NSPointerArray *backingStore;

@end



@implementation NSEOrderedSet

+ (instancetype)weakOrderedSet {
    NSEOrderedSet *orderedSet = [self.alloc initWithBackingStore:NSPointerArray.weakObjectsPointerArray];
    return orderedSet;
}

+ (instancetype)strongOrderedSet {
    NSEOrderedSet *orderedSet = [self.alloc initWithBackingStore:NSPointerArray.strongObjectsPointerArray];
    return orderedSet;
}

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore {
    self = super.init;
    
    self.backingStore = backingStore;
    
    return self;
}

#pragma mark - NSOrderedSet

- (NSUInteger)count {
    [self.backingStore compact];
    
    NSSet *set = [NSSet setWithArray:self.backingStore.allObjects];
    
    return set.count;
}

- (id)objectAtIndex:(NSUInteger)idx {
    [self.backingStore compact];
    
    id object = (__bridge id)[self.backingStore pointerAtIndex:idx];
    return object;
}

- (NSUInteger)indexOfObject:(id)object {
    [self.backingStore compact];
    
    NSUInteger idx = [self.backingStore.allObjects indexOfObject:object];
    return idx;
}

//@property (readonly) NSUInteger count;
//- (ObjectType)objectAtIndex:(NSUInteger)idx;
//- (NSUInteger)indexOfObject:(ObjectType)object;

#pragma mark - NSMutableOrderedSet

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
    [self.backingStore compact];
    
    [self.backingStore insertPointer:(__bridge void *)object atIndex:idx];
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    [self.backingStore compact];
    
    [self.backingStore removePointerAtIndex:idx];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
    [self.backingStore compact];
    
    [self.backingStore replacePointerAtIndex:idx withPointer:(__bridge void *)object];
}

//- (void)insertObject:(ObjectType)object atIndex:(NSUInteger)idx;
//- (void)removeObjectAtIndex:(NSUInteger)idx;
//- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(ObjectType)object;

//#pragma mark - NSOrderedSet
//
//- (NSUInteger)count {
//    [self.backingStore compact];
//
//    return self.backingStore.count;
//}
//
////- (id)objectAtIndex:(NSUInteger)idx {
////    [self.backingStore compact];
////
////    id object = (__bridge id)[self.backingStore pointerAtIndex:idx];
////    return object;
////}
//
//#pragma mark - NSMutableOrderedSet
//
//- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
//    [self.backingStore compact];
//
//    [self.backingStore insertPointer:(__bridge void *)object atIndex:idx];
//}
//
//- (void)removeObjectAtIndex:(NSUInteger)idx {
//    [self.backingStore compact];
//
//    [self.backingStore removePointerAtIndex:idx];
//}
//
//- (void)addObject:(id)object {
//    [self.backingStore compact];
//
//    [self.backingStore addPointer:(__bridge void *)object];
//}
//
////- (void)removeLastObject {
////    [self.backingStore compact];
////
////    NSUInteger index = self.backingStore.count - 1;
////    [self.backingStore removePointerAtIndex:index];
////}
//
//- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
//    [self.backingStore compact];
//
//    [self.backingStore replacePointerAtIndex:idx withPointer:(__bridge void *)object];
//}
//
////
//
//- (BOOL)containsObject:(id)object {
//    return YES;
//}

//#pragma mark - NSObject
//
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    id target = [super forwardingTargetForSelector:aSelector];
//
//    if (target) {
//    } else {
//        for (target in self) {
//            BOOL responds = [target respondsToSelector:aSelector];
//            if (responds) {
//                break;
//            }
//        }
//    }
//
//    return target;
//}
//
//- (BOOL)respondsToSelector:(SEL)aSelector {
//    BOOL responds = [super respondsToSelector:aSelector];
//
//    if (responds) {
//    } else {
//        for (id target in self) {
//            responds = [target respondsToSelector:aSelector];
//            if (responds) {
//                break;
//            }
//        }
//    }
//
//    return responds;
//}

@end
