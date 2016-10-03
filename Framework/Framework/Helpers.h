//
//  Helpers.h
//  R4S
//
//  Created by Dan Kalinin on 09/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double HelpersVersionNumber;
FOUNDATION_EXPORT const unsigned char HelpersVersionString[];










@interface UIColor (Helpers)

+ colorWithHexString:(NSString *)hexString;

@end










@interface ImageView : UIImageView

- (void)setHighlighted:(BOOL)highlighted;

@end










@interface Keychain : NSObject

@property NSString *account;
@property NSString *service;
@property NSData *credential;
@property NSString *password;
@property OSStatus status;

@end










@interface NSObject (Helpers)

+ (void)swizzleClassMethod:(SEL)swizzling with:(SEL)original;
+ (void)swizzleInstanceMethod:(SEL)swizzling with:(SEL)original;

@end










@interface NSDictionary (Helpers)

@end










@interface SurrogateContainer : NSObject

@property NSArray *objects;

@end
