//
//  HLPArray.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>

@class HLPArray, HLPProxyArray;










@interface HLPArray<ObjectType> : NSMutableArray<ObjectType>

@property (readonly) NSPointerArray *backingStore;

+ (instancetype)weakArray;
+ (instancetype)strongArray;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end










@interface HLPProxyArray<ObjectType> : HLPArray<ObjectType>

@end










@interface NSArray (HLP)

@property (readonly) HLPArray *weakArray;
@property (readonly) HLPArray *strongArray;
@property (readonly) HLPProxyArray *weakProxyArray;
@property (readonly) HLPProxyArray *strongProxyArray;

@end
