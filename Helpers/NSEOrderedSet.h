//
//  NSEOrderedSet.h
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import "NSEArray.h"

@class NSEOrderedSet;



@interface NSEOrderedSet : NSEArray

+ (instancetype)weakOrderedSet;
+ (instancetype)strongOrderedSet;

@end
