//
//  NSEObject.h
//  Helpers
//
//  Created by Dan Kalinin on 12/30/18.
//

#import <Foundation/Foundation.h>
#import "HLPOperation.h"

@class NSEObject;
@class NSEObjectOperation;

@protocol NSEObjectDelegate;










@interface NSObject (NSE)

@property (readonly) Class nseOperationClass;
@property (readonly) NSEObjectOperation *nseOperation;

@end










@interface NSEObject : NSObject

@end










@protocol NSEObjectDelegate <NSEOperationDelegate>

@end



@interface NSEObjectOperation : NSEOperation <NSEObjectDelegate>

@property (weak, readonly) NSObject *object;

- (instancetype)initWithObject:(NSObject *)object;

@end
