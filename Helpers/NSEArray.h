//
//  NSEArray.h
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import <Foundation/Foundation.h>
#import "NSEObject.h"
#import "NSEOperationQueue.h"



@interface NSEArray : NSMutableArray

@property NSOperationQueue *queue;

@property (readonly) NSPointerArray *backingStore;
@property (readonly) NSMutableSet<NSString *> *exceptions;

+ (instancetype)weakArray;
+ (instancetype)strongArray;

- (instancetype)initWithBackingStore:(NSPointerArray *)backingStore;

@end
