//
//  NSEDictionary.h
//  Helpers
//
//  Created by Dan Kalinin on 1/4/19.
//

#import "NSEObject.h"

@class NSEDictionary;










@interface NSDictionary (NSE)

@property (readonly) NSEDictionary *nseWeakToWeakDictionary;
@property (readonly) NSEDictionary *nseWeakToStrongDictionary;
@property (readonly) NSEDictionary *nseStrongToWeakDictionary;
@property (readonly) NSEDictionary *nseStrongToStrongDictionary;

@end










@interface NSEDictionary : NSMutableDictionary

@property (readonly) NSMapTable *backingStore;

+ (instancetype)weakToWeakDictionary;
+ (instancetype)weakToStrongDictionary;
+ (instancetype)strongToWeakDictionary;
+ (instancetype)strongToStrongDictionary;

- (instancetype)initWithBackingStore:(NSMapTable *)backingStore;

@end
