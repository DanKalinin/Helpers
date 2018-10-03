//
//  HLPException.h
//  Helpers
//
//  Created by Dan Kalinin on 10/3/18.
//

#import <Foundation/Foundation.h>

@class HLPException;



@interface HLPException : NSException

@property (readonly) NSError *error;

- (instancetype)initWithError:(NSError *)error;

+ (instancetype)exceptionWithError:(NSError *)error;
+ (instancetype)exceptionWithStatus:(OSStatus)status;

+ (void)raiseWithError:(NSError *)error;
+ (void)raiseWithStatus:(OSStatus)status;

@end
