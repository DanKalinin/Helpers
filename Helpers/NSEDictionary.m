//
//  NSEDictionary.m
//  Helpers
//
//  Created by Dan Kalinin on 1/4/19.
//

#import "NSEDictionary.h"










@implementation NSDictionary (NSE)

- (NSEDictionary *)nseWeakToWeakDictionary {
    NSEDictionary *dictionary = NSEDictionary.weakToWeakDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

- (NSEDictionary *)nseWeakToStrongDictionary {
    NSEDictionary *dictionary = NSEDictionary.weakToStrongDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

- (NSEDictionary *)nseStrongToWeakDictionary {
    NSEDictionary *dictionary = NSEDictionary.strongToWeakDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

- (NSEDictionary *)nseStrongToStrongDictionary {
    NSEDictionary *dictionary = NSEDictionary.strongToStrongDictionary;
    [dictionary addEntriesFromDictionary:self];
    return dictionary;
}

@end










@interface NSEDictionary ()

@property NSMapTable *backingStore;

@end



@implementation NSEDictionary

+ (instancetype)weakToWeakDictionary {
    NSEDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.weakToWeakObjectsMapTable];
    return dictionary;
}

+ (instancetype)weakToStrongDictionary {
    NSEDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.weakToStrongObjectsMapTable];
    return dictionary;
}

+ (instancetype)strongToWeakDictionary {
    NSEDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.strongToWeakObjectsMapTable];
    return dictionary;
}

+ (instancetype)strongToStrongDictionary {
    NSEDictionary *dictionary = [self.alloc initWithBackingStore:NSMapTable.strongToStrongObjectsMapTable];
    return dictionary;
}

- (instancetype)initWithBackingStore:(NSMapTable *)backingStore {
    self = super.init;
    
    self.backingStore = backingStore;
    
    return self;
}

#pragma mark - NSDictionary

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

#pragma mark - NSMutableDictionary

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self.backingStore setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self.backingStore removeObjectForKey:aKey];
}

@end
