//
//  HLPSequence.m
//  Helpers
//
//  Created by Dan Kalinin on 8/3/18.
//

#import "HLPSequence.h"



@interface HLPSequence ()

@property int64_t minValue;
@property int64_t maxValue;
@property int64_t step;
@property int64_t value;

@end



@implementation HLPSequence

- (instancetype)initWithMinValue:(int64_t)minValue maxValue:(int64_t)maxValue step:(int64_t)step {
    self = super.init;
    if (self) {
        self.minValue = minValue;
        self.maxValue = maxValue;
        self.step = step;
        
        self.value = self.minValue;
    }
    return self;
}

- (int64_t)nextValue {
    return self.value;
}

@end
