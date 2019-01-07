//
//  NSEInputStream.m
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import "NSEInputStream.h"










@implementation NSInputStream (NSE)

@dynamic nseOperation;

- (Class)nseOperationClass {
    return NSEInputStreamOperation.class;
}

@end










@interface NSEInputStream ()

@end



@implementation NSEInputStream

@end










@interface NSEInputStreamOperation ()

@end



@implementation NSEInputStreamOperation

@dynamic object;

@end
