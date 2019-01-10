//
//  NSEArray.h
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import "NSEObject.h"

@class NSEArray;










@interface NSArray (NSE)

@property (readonly) NSEArray *nseWeakArray;
@property (readonly) NSEArray *nseStrongArray;

@end










@interface NSEArray : NSMutableArray

@property NSOperationQueue *queue;

@property (readonly) NSPointerArray *backingStore;
@property (readonly) NSMutableSet<NSString *> *exceptions;

+ (instancetype)weakArray;
+ (instancetype)strongArray;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end
