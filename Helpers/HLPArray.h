//
//  HLPArray.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>

@class HLPPointerArray, HLPArray, HLPProxyArray;










@interface HLPPointerArray : NSPointerArray

@end










@interface HLPArray<ObjectType> : NSMutableArray<ObjectType>

@property (readonly) HLPPointerArray *backingStore;

@end










@interface HLPProxyArray<ObjectType> : HLPArray<ObjectType>

@end
