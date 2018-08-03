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
@property int64_t step;
@property int64_t value;

@end



@implementation HLPSequence

- (instancetype)initWithStart:(int64_t)start stop:(int64_t)stop step:(int64_t)step {
    self = super.init;
    if (self) {
        self.start = start;
        self.stop = stop;
        self.step = step;
        
        self.value = self.start;
    }
    return self;
}

- (int64_t)next {
    int64_t value = self.value;
    self.value += self.step;
    if (self.step > 0) {
        if (self.value > self.stop) {
            self.value = self.start;
        }
    } else {
        if (self.value < self.stop) {
            self.value = self.start;
        }
    }
    return value;
}

#pragma mark - Enumerator

- (id)nextObject {
    int64_t value = self.value;
    self.value += self.step;
    if (self.step > 0) {
        if (self.value > self.stop) {
            return nil;
        }
    } else {
        if (self.value < self.stop) {
            return nil;
        }
    }
    return @(value);
}

@end
