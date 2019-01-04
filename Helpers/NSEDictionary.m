//
//  NSEDictionary.m
//  Helpers
//
//  Created by Dan Kalinin on 1/4/19.
//

#import "NSEDictionary.h"



@interface NSEDictionaryObject ()

@property NSDictionary *dictionary;

@end



@implementation NSEDictionaryObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = super.init;
    
    self.dictionary = dictionary;
    
    return self;
}

@end
