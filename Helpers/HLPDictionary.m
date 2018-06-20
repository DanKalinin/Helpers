//
//  HLPDictionary.m
//  Helpers
//
//  Created by Dan Kalinin on 4/24/18.
//

#import "HLPDictionary.h"



@interface HLPDictionary ()

@property NSMapTable *backingStore;

@end



@implementation HLPDictionary

+ (instancetype)weakToWeakDictionary {
    HLPDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.weakToWeakObjectsMapTable];
    return dictionary;
}

+ (instancetype)weakToStrongDictionary {
    HLPDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.weakToStrongObjectsMapTable];
    return dictionary;
}

+ (instancetype)strongToWeakDictionary {
    HLPDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.strongToWeakObjectsMapTable];
    return dictionary;
}

+ (instancetype)strongToStrongDictionary {
    HLPDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.strongToStrongObjectsMapTable];
    return dictionary;
}

- (instancetype)initWithBackingStore:(NSMapTable *)backingStore {
    self = super.init;
    if (self) {
        self.backingStore = backingStore;
    }
    return self;
}

#pragma mark - Dictionary

- (instancetype)init {
    self = [self initWithBackingStore:NSMapTable.strongToStrongObjectsMapTable];
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [self initWithBackingStore:NSMapTable.strongToStrongObjectsMapTable];
    return self;
}

- (NSUInteger)count {
    return self.backingStore.count;
}

- (id)objectForKey:(id)aKey {
    id object = [self.backingStore objectForKey:aKey];
    return object;
}

- (NSEnumerator *)keyEnumerator {
    return self.backingStore.keyEnumerator;
}

#pragma mark - Mutable dictionary

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self.backingStore setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self.backingStore removeObjectForKey:aKey];
}

@end










@implementation NSDictionary (HLP)

- (HLPDictionary *)weakToWeakDictionary {
    HLPDictionary *dictionary = HLPDictionary.weakToWeakDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

- (HLPDictionary *)weakToStrongDictionary {
    HLPDictionary *dictionary = HLPDictionary.weakToStrongDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

- (HLPDictionary *)strongToWeakDictionary {
    HLPDictionary *dictionary = HLPDictionary.strongToWeakDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

- (HLPDictionary *)strongToStrongDictionary {
    HLPDictionary *dictionary = HLPDictionary.strongToStrongDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

@end
