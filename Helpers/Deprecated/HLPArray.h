//
//  HLPArray.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>

@class HLPArray;










@interface HLPArray<ObjectType> : NSMutableArray<ObjectType>

@property NSOperationQueue *operationQueue;

@property (readonly) NSPointerArray *backingStore;
@property (readonly) NSMutableSet<NSString *> *exceptions;

+ (instancetype)weakArray;
+ (instancetype)strongArray;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end










@interface NSArray<ObjectType> (HLP)

@property (readonly) HLPArray *weakArray;
@property (readonly) HLPArray *strongArray;

@end
