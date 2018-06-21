//
//  HLPSet.m
//  Helpers
//
//  Created by Dan Kalinin on 6/21/18.
//

#import "HLPSet.h"










@interface HLPSet ()

@property NSHashTable *backingStore;

@end



@implementation HLPSet

+ (instancetype)weakSet {
    HLPSet *set = [self.alloc initWithBackingStore:NSHashTable.weakObjectsHashTable];
    return set;
}

+ (instancetype)strongSet {
    HLPSet *set = [self.alloc initWithBackingStore:NSHashTable.strongObjectsHashTable];
    return set;
}

- (instancetype)initWithBackingStore:(NSHashTable *)backingStore {
    self = super.init;
    if (self) {
        self.backingStore = backingStore;
    }
    return self;
}

#pragma mark - Set

- (instancetype)init {
    self = [self initWithBackingStore:NSHashTable.strongObjectsHashTable];
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [self initWithBackingStore:NSHashTable.strongObjectsHashTable];
    return self;
}

- (NSUInteger)count {
    return self.backingStore.count;
}

- (id)member:(id)object {
    id member = [self.backingStore member:object];
    return member;
}

- (NSEnumerator *)objectEnumerator {
    return self.backingStore.objectEnumerator;
}

#pragma mark - Mutable set

- (void)addObject:(id)object {
    [self.backingStore addObject:object];
}

- (void)removeObject:(id)object {
    [self.backingStore removeObject:object];
}

@end










@implementation NSHashTable (HLP)

+ (NSHashTable *)strongObjectsHashTable {
    NSHashTable *hashTable = [NSHashTable hashTableWithOptions:NSHashTableStrongMemory];
    return hashTable;
}

@end










@implementation HLPSet (HLP)

- (HLPSet *)weakSet {
    HLPSet *set = HLPSet.weakSet;
    [set addObjectsFromArray:self.allObjects];
    return set;
}

- (HLPSet *)strongSet {
    HLPSet *set = HLPSet.strongSet;
    [set addObjectsFromArray:self.allObjects];
    return set;
}

@end
