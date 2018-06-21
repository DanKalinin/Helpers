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

+ (instancetype)weakArray;
+ (instancetype)strongArray;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end










@interface NSArray (HLP)

@property (readonly) HLPArray *weakArray;
@property (readonly) HLPArray *strongArray;

@end
