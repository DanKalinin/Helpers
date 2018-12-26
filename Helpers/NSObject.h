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

@property (weak, readonly) NSObject *object;

- (instancetype)initWithObject:(NSObject *)object;

@end










@interface NSObject (NSE)

@property (readonly) Class operationClass;
@property (readonly) NSObjectOperation *operation;

@end
