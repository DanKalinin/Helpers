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

extern NSString *const DateFormatRFC1123;
extern NSString *const DateFormatRFC850;
extern NSString *const DateFormatAsctime;

extern NSString *const ErrorKey;

typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL);
typedef void (^ErrorBlock)(NSError *);










#pragma mark - Classes

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










@interface SurrogateContainer : NSObject

@property NSArray *objects;

@end










@interface PasswordTextField : UITextField

@end










@interface FilledButton : UIButton

@end










@interface KeyboardContainerView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end










@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end










#pragma mark - Categories

@interface UIColor (Helpers)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end










@interface NSObject (Helpers)

+ (void)swizzleClassMethod:(SEL)swizzling with:(SEL)original;
+ (void)swizzleInstanceMethod:(SEL)swizzling with:(SEL)original;

@property (class, readonly) NSBundle *bundle;
@property (readonly) NSBundle *bundle;

@end










@interface NSDictionary (Helpers)

@end










@interface NSDateFormatter (Helpers)

+ (instancetype)fixedDateFormatterWithDateFormat:(NSString *)dateFormat;

@end










@interface UIViewController (Helpers)

@property IBInspectable NSUInteger orientations;

- (NSString *)localize:(NSString *)string;

@end
