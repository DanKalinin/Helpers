//
//  HLPDictionary.m
//  Helpers
//
//  Created by Dan Kalinin on 4/24/18.
//

#import "HLPDictionary.h"










@interface HLPWeakDictionary ()

@property NSMapTable *mapTable;

@end



@implementation HLPWeakDictionary

#pragma mark - Dictionary

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = super.init;
    if (self) {
        self.mapTable = NSMapTable.strongToWeakObjectsMapTable;
    }
    return self;
}

- (NSUInteger)count {
    return self.mapTable.count;
}

- (id)objectForKey:(id)aKey {
    id object = [self.mapTable objectForKey:aKey];
    return object;
}

- (NSEnumerator *)keyEnumerator {
    return self.mapTable.keyEnumerator;
}

#pragma mark - Mutable dictionary

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self.mapTable setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self.mapTable removeObjectForKey:aKey];
}

@end
