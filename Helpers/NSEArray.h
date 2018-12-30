//
//  NSEArray.h
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import <Foundation/Foundation.h>



@interface NSEArray : NSMutableArray

@property (readonly) NSPointerArray *backingStore;

+ (instancetype)weakArray;
+ (instancetype)strongArray;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end
