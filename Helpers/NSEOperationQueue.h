//
//  NSEOperationQueue.h
//  Helpers
//
//  Created by Dan Kalinin on 1/10/19.
//

#import "NSEObject.h"



@interface NSOperationQueue (NSE)

- (void)nseAddOperationWithBlockAndWait:(NSEBlock)block;

@end
