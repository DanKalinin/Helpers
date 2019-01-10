//
//  NSEDictionaryObject.h
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEObject.h"

@class NSEDictionaryObject;



@interface NSEDictionaryObject : NSEObject

@property (readonly) NSDictionary *dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
