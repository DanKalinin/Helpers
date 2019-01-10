//
//  NSEStream.m
//  Helpers
//
//  Created by Dan Kalinin on 1/8/19.
//

#import "NSEStream.h"
#import "NSEOrderedSet.h"










@implementation NSStream (NSE)

@dynamic nseOperation;

- (Class)nseOperationClass {
    return NSEStreamOperation.class;
}

@end










@interface NSEStream ()

@end



@implementation NSEStream

@end










@interface NSEStreamOpening ()

@end



@implementation NSEStreamOpening

@end










@interface NSEStreamOperation ()

@property (weak) NSEStreamOpening *opening;

@end



@implementation NSEStreamOperation

@dynamic delegates;
@dynamic object;

- (instancetype)initWithObject:(NSStream *)object {
    self = [super initWithObject:object];
    
    object.delegate = self;
    
    return self;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventOpenCompleted) {
        [self.delegates nseStreamOpenCompleted:aStream];
    } else if (eventCode == NSStreamEventHasBytesAvailable) {
        [self.delegates nseStreamHasBytesAvailable:aStream];
    } else if (eventCode == NSStreamEventHasSpaceAvailable) {
        [self.delegates nseStreamHasSpaceAvailable:aStream];
    } else if (eventCode == NSStreamEventErrorOccurred) {
        [self.delegates nseStreamErrorOccurred:aStream];
    } else if (eventCode == NSStreamEventEndEncountered) {
        [self.delegates nseStreamEndEncountered:aStream];
    }
}

@end










@implementation NSInputStream (NSE)

@end
