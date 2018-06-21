//
//  HLPSet.h
//  Helpers
//
//  Created by Dan Kalinin on 6/21/18.
//

#import <Foundation/Foundation.h>

@class HLPSet;










@interface HLPSet<ObjectType> : NSMutableSet<ObjectType>

@property (readonly) NSHashTable *backingStore;

+ (instancetype)weakSet;
+ (instancetype)strongSet;

- (instancetype)initWithBackingStore:(NSHashTable *)backingStore;

@end










@interface NSHashTable<ObjectType> (HLP)

+ (NSHashTable *)strongObjectsHashTable;

@end










@interface NSSet<ObjectType> (HLP)

@property (readonly) HLPSet *weakSet;
@property (readonly) HLPSet *strongSet;

@end
