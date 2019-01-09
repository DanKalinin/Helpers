//
//  NSEOrderedSet.h
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import <Foundation/Foundation.h>



@interface NSEOrderedSet : NSMutableOrderedSet

@property (readonly) NSPointerArray *backingStore;

+ (instancetype)weakOrderedSet;
+ (instancetype)strongOrderedSet;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end
