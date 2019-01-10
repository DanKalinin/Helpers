//
//  NSEOrderedSet.h
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import <Foundation/Foundation.h>
#import "NSEArray.h"



@interface NSEOrderedSet : NSEArray

+ (instancetype)weakOrderedSet;
+ (instancetype)strongOrderedSet;

@end
