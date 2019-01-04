//
//  NSEDictionary.h
//  Helpers
//
//  Created by Dan Kalinin on 1/4/19.
//

#import <Foundation/Foundation.h>
#import "NSEObject.h"



@interface NSEDictionaryObject : NSEObject

@property (readonly) NSDictionary *dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
