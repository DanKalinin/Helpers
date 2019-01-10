//
//  NSEOrderedSet.m
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import "NSEOrderedSet.h"



@interface NSEOrderedSet ()

@end



@implementation NSEOrderedSet

+ (instancetype)weakOrderedSet {
    return self.weakArray;
}

+ (instancetype)strongOrderedSet {
    return self.strongArray;
}

#pragma mark - NSMutableArray

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    BOOL contains = [self containsObject:anObject];
    if (contains) {
    } else {
        if (index > self.count) {
            index = self.count;
        }
        
        [super insertObject:anObject atIndex:index];
    }
}

- (void)addObject:(id)anObject {
    BOOL contains = [self containsObject:anObject];
    if (contains) {
    } else {
        [super addObject:anObject];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    BOOL contains = [self containsObject:anObject];
    if (contains) {
    } else {
        [super replaceObjectAtIndex:index withObject:anObject];
    }
}

@end
