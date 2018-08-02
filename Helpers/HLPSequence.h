//
//  HLPSequence.h
//  Helpers
//
//  Created by Dan Kalinin on 8/3/18.
//

#import <Foundation/Foundation.h>
#import "HLPEnumerator.h"



@interface HLPSequence : HLPEnumerator

@property (readonly) int64_t minValue;
@property (readonly) int64_t maxValue;
@property (readonly) int64_t start;
@property (readonly) int64_t incr;
@property (readonly) int64_t curVal;
@property (readonly) int64_t nextVal;

@end
