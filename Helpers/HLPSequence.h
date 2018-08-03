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
@property (readonly) int64_t step;
@property (readonly) int64_t value;
@property (readonly) int64_t nextValue;

- (instancetype)initWithMinValue:(int64_t)minValue maxValue:(int64_t)maxValue step:(int64_t)step;

@end
