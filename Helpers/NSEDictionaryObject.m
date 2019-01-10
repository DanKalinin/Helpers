//
//  NSEDictionaryObject.m
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEDictionaryObject.h"



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
