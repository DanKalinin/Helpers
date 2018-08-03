//
//  HLPSequence.h
//  Helpers
//
//  Created by Dan Kalinin on 8/3/18.
//

#import <Foundation/Foundation.h>
#import "HLPEnumerator.h"



@interface HLPSequence : HLPEnumerator

@property (readonly) int64_t start;
@property (readonly) int64_t stop;
@property (readonly) int64_t step;
@property (readonly) int64_t value;
@property (readonly) int64_t next;

- (instancetype)initWithStart:(int64_t)start stop:(int64_t)stop step:(int64_t)step;

@end
