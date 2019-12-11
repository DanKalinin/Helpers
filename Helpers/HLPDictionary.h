//
//  HLPDictionary.h
//  Helpers
//
//  Created by Dan Kalinin on 4/24/18.
//

#import <Foundation/Foundation.h>
#import "HLPObject.h"

@class HLPDictionary;










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










@interface HLPDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

@property (readonly) NSMapTable *backingStore;

+ (instancetype)weakToWeakDictionary;
+ (instancetype)weakToStrongDictionary;
+ (instancetype)strongToWeakDictionary;
+ (instancetype)strongToStrongDictionary;

- (instancetype)initWithBackingStore:(NSMapTable *)backingStore;

@end










@interface NSDictionary<KeyType, ObjectType> (HLP)

@property (readonly) HLPDictionary *weakToWeakDictionary;
@property (readonly) HLPDictionary *weakToStrongDictionary;
@property (readonly) HLPDictionary *strongToWeakDictionary;
@property (readonly) HLPDictionary *strongToStrongDictionary;

@end
