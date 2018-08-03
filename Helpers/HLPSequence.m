//
//  HLPSequence.m
//  Helpers
//
//  Created by Dan Kalinin on 8/3/18.
//

#import "HLPSequence.h"



@interface HLPSequence ()

@property int64_t start;
@property int64_t stop;
@property uint32_t step;
@property int64_t value;

@end



@implementation HLPSequence

- (instancetype)initWithStart:(int64_t)start stop:(int64_t)stop step:(uint32_t)step {
    self = super.init;
    if (self) {
        self.start = start;
        self.stop = stop;
        self.step = step;
        
        self.value = self.start;
    }
    return self;
}

- (void)next {
    if (self.stop > self.start) {
        self.value += self.step;
        if (self.value > self.stop) {
            self.value = self.start;
        }
    } else {
        self.value -= self.step;
        if (self.value < self.stop) {
            self.value = self.start;
        }
    }
}

@end
