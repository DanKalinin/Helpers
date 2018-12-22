//
//  NSObject.h
//  Helpers
//
//  Created by Dan Kalinin on 12/22/18.
//

#import <Foundation/Foundation.h>
#import "HLPOperation.h"

@class NSObjectOperation;

@protocol NSObjectOperationDelegate;



@protocol NSObjectOperationDelegate <NSEOperationDelegate>

@end



@interface NSObjectOperation : NSEOperation <NSObjectOperationDelegate>

@property (readonly) NSObject *object;

@property (weak, readonly) NSObject *weakObject;

- (instancetype)initWithObject:(NSObject *)object;
- (instancetype)initWithWeakObject:(NSObject *)weakObject;

@end
