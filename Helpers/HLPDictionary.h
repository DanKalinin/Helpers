//
//  HLPDictionary.h
//  Helpers
//
//  Created by Dan Kalinin on 4/24/18.
//

#import <Foundation/Foundation.h>
#import "HLPObject.h"

@class HLPWeakDictionary;










@protocol HLPDictionaryEncodable <HLPObject>

@optional
- (void)toDictionary:(NSMutableDictionary *)dictionary;

@end



@protocol HLPDictionaryDecodable <HLPObject>

@optional
- (void)fromDictionary:(NSMutableDictionary *)dictionary;

@end



@protocol HLPDictionaryCodable <HLPDictionaryEncodable, HLPDictionaryDecodable>

@end










@interface HLPWeakDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

@end
