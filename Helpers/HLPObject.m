//
//  HLPObject.m
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import "HLPObject.h"
#import "HLPDictionary.h"










@interface HLPObject ()

@end



@implementation HLPObject

@end










@implementation NSObject (HLP)

- (HLPDictionary *)weakDictionary {
    HLPDictionary *dictionary = objc_getAssociatedObject(self, @selector(weakDictionary));
    if (dictionary) {
    } else {
        dictionary = HLPDictionary.strongToWeakDictionary;
        objc_setAssociatedObject(self, @selector(weakDictionary), dictionary, OBJC_ASSOCIATION_RETAIN);
    }
    return dictionary;
}

- (HLPDictionary *)strongDictionary {
    HLPDictionary *dictionary = objc_getAssociatedObject(self, @selector(strongDictionary));
    if (dictionary) {
    } else {
        dictionary = HLPDictionary.strongToStrongDictionary;
        objc_setAssociatedObject(self, @selector(strongDictionary), dictionary, OBJC_ASSOCIATION_RETAIN);
    }
    return dictionary;
}

@end
