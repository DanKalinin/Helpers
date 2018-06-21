//
//  HLPSet.h
//  Helpers
//
//  Created by Dan Kalinin on 6/21/18.
//

#import <Foundation/Foundation.h>










@interface HLPSet : NSMutableSet

@property (readonly) NSHashTable *backingStore;

+ (instancetype)weakSet;
+ (instancetype)strongSet;

- (instancetype)initWithBackingStore:(NSHashTable *)backingStore;

@end










@interface NSHashTable (HLP)

+ (NSHashTable *)strongObjectsHashTable;

@end










@interface NSSet (HLP)

@property (readonly) HLPSet *weakSet;
@property (readonly) HLPSet *strongSet;

@end
