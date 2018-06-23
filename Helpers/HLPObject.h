//
//  HLPObject.h
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import <Foundation/Foundation.h>

@class HLPObject;
@class HLPDictionary;










@protocol HLPObject <NSObject>

@end



@interface HLPObject : NSObject <HLPObject>

@end










@interface NSObject (HLP)

@property (readonly) HLPDictionary *weakDictionary;
@property (readonly) HLPDictionary *strongDictionary;

@end
