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

extern NSString *const PlistExtension;
extern NSString *const XMLExtension;
extern NSString *const JSONExtension;

extern NSString *const ErrorKey;
extern NSString *const ObjectKey;

typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL);
typedef void (^FloatBlock)(float);
typedef void (^DoubleBlock)(double);
typedef void (^ErrorBlock)(NSError *);
typedef void (^BackgroundFetchResultBlock)(UIBackgroundFetchResult);










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

@property IBInspectable UIColor *highlightedBackgroundColor;
@property IBInspectable UIColor *selectedBackgroundColor;
@property IBInspectable UIColor *disabledBackgroundColor;

@property IBInspectable UIColor *highlightedBorderColor;
@property IBInspectable UIColor *selectedBorderColor;
@property IBInspectable UIColor *disabledBorderColor;

@end










@interface KeyboardContainerView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end










@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@end










#pragma mark - Categories

@interface UIColor (Helpers)

+ (UIColor *)r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a;

+ (UIColor *)colorWithRGBAString:(NSString *)rgbaString;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end










@interface NSObject (Helpers)

+ (void)swizzleClassMethod:(SEL)original with:(SEL)swizzled;
+ (void)swizzleInstanceMethod:(SEL)original with:(SEL)swizzled;

@property (class, readonly) NSBundle *bundle;
@property (readonly) NSBundle *bundle;

@end










@interface NSDictionary (Helpers)

- (NSDictionary *)deepCopy;
- (NSMutableDictionary *)deepMutableCopy;

@end










@interface NSDateFormatter (Helpers)

+ (instancetype)fixedDateFormatterWithDateFormat:(NSString *)dateFormat;

@end










@interface UIViewController (Helpers)

@property IBInspectable NSUInteger orientations;

- (NSString *)localize:(NSString *)string;

@end










@interface UITableView (Helpers)

@property (strong, nonatomic) IBOutlet UIView *emptyView;

@end










@interface NSBundle (Helpers)

- (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code;

@end










@interface NSError (Helpers)

- (void)setUserInfoValue:(id)value forKey:(NSString *)key;

@end










@interface UIView (Helpers)

@property IBInspectable UIColor *borderColor;

@end










@interface NSNetService (Helpers)

+ (NSString *)stringFromAddressData:(NSData *)data;

@end
