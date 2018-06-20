//
//  HLPArray.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>










@interface HLPPointerArray : NSPointerArray

@end










@interface HLPArray<ObjectType> : NSMutableArray<ObjectType>

@property (readonly) HLPPointerArray *array;

@end
