//
//  Dictionary.h
//  Helpers
//
//  Created by Dan Kalinin on 4/24/18.
//

#import <Foundation/Foundation.h>

@class WeakDictionary;










@protocol DictionaryEncodable <NSObject>

@optional
- (void)toDictionary:(NSMutableDictionary *)dictionary;

@end



@protocol DictionaryDecodable <NSObject>

@optional
- (void)fromDictionary:(NSMutableDictionary *)dictionary;

@end



@interface DictionaryCodable <DictionaryEncodable, DictionaryDecodable>

@end










@interface WeakDictionary : NSMutableDictionary

@end
