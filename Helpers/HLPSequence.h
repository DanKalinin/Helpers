//
//  HLPSequence.h
//  Helpers
//
//  Created by Dan Kalinin on 8/3/18.
//

#import <Foundation/Foundation.h>
#import "HLPObject.h"



@interface HLPSequence : HLPObject

@property (readonly) int64_t start;
@property (readonly) int64_t stop;
@property (readonly) uint64_t step;
@property (readonly) int64_t value;

- (instancetype)initWithStart:(int64_t)start stop:(int64_t)stop step:(uint64_t)step;
- (void)next;

@end
