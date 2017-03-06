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
extern NSString *const DateFormatGCCDate;
extern NSString *const DateFormatGCCTime;

extern NSString *const PlistExtension;
extern NSString *const StringsExtension;
extern NSString *const XMLExtension;
extern NSString *const JSONExtension;

extern NSString *const ErrorKey;
extern NSString *const ObjectKey;

extern CGFloat CGFloatClampToRange(CGFloat value, UIFloatRange range);
extern CGFloat CGFloatSign(CGFloat value);

extern CGPoint CGPointAdd(CGPoint pointLeft, CGPoint pointRight);
extern CGPoint CGPointSubtract(CGPoint pointLeft, CGPoint pointRight);
extern CGPoint CGPointMultiply(CGPoint point, CGFloat value);
extern CGFloat CGPointDistance(CGPoint pointStart, CGPoint pointEnd);
extern CGPoint CGPointClampToRect(CGPoint point, CGRect rect);

extern CGPoint CGRectGetMidXMidY(CGRect rect);

typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL);
typedef void (^FloatBlock)(float);
typedef void (^DoubleBlock)(double);
typedef void (^ErrorBlock)(NSError *);
typedef void (^ArrayBlock)(NSArray *);
typedef void (^DataBlock)(NSData *);
typedef void (^ImageBlock)(UIImage *);
typedef void (^BackgroundFetchResultBlock)(UIBackgroundFetchResult);

typedef NS_ENUM(NSUInteger, Digest) {
    DigestMD5,
    DigestSHA1,
    DigestSHA224,
    DigestSHA256,
    DigestSHA384,
    DigestSHA512
};










#pragma mark - Classes

@interface ImageView : UIImageView

@property IBInspectable UIColor *highlightedBackgroundColor;

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










@interface TextField : UITextField

@property IBInspectable NSUInteger maxLength;

@end










@interface FilledButton : UIButton

@property IBInspectable UIColor *defaultBackgroundColor;
@property IBInspectable UIColor *highlightedBackgroundColor;
@property IBInspectable UIColor *selectedBackgroundColor;
@property IBInspectable UIColor *disabledBackgroundColor;

@property IBInspectable UIColor *defaultBorderColor;
@property IBInspectable UIColor *highlightedBorderColor;
@property IBInspectable UIColor *selectedBorderColor;
@property IBInspectable UIColor *disabledBorderColor;

@property IBInspectable BOOL toggle;

@end










@interface KeyboardContainerView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end










@interface TableViewController : UITableViewController

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;

@end










@interface ShapeLayerView : UIView

@property (class, readonly) Class layerClass;
@property (readonly) CAShapeLayer *layer;

@end










@interface GradientLayerView : UIView

@property (class, readonly) Class layerClass;
@property (readonly) CAGradientLayer *layer;

@end










@interface EmitterCellImageView : UIImageView

@property (readonly) CAEmitterCell *cell;

@end










@interface EmitterLayerView : UIView

@property (strong, nonatomic) IBOutletCollection(EmitterCellImageView) NSArray *cells;

@property (class, readonly) Class layerClass;
@property (readonly) CAEmitterLayer *layer;

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

@property (class, readonly) NSArray<NSString *> *propertyKeys;
@property (readonly) NSArray<NSString *> *propertyKeys;

@property (class, readonly) NSBundle *bundle;
@property (readonly) NSBundle *bundle;

@property (class, readonly) UINib *nib;
@property (readonly) UINib *nib;

+ (instancetype)objectNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (instancetype)objectNamed:(NSString *)name;

- (UIImage *)imageNamed:(NSString *)name;

+ (void)invokeHandler:(VoidBlock)handler;
- (void)invokeHandler:(VoidBlock)handler;

+ (void)invokeHandler:(ErrorBlock)handler error:(NSError *)error;
- (void)invokeHandler:(ErrorBlock)handler error:(NSError *)error;

+ (void)invokeHandler:(DataBlock)handler data:(NSData *)data;
- (void)invokeHandler:(DataBlock)handler data:(NSData *)data;

+ (void)invokeHandler:(ImageBlock)handler image:(UIImage *)image;
- (void)invokeHandler:(ImageBlock)handler image:(UIImage *)image;

@end










@interface NSDictionary (Helpers)

- (NSDictionary *)deepCopy;
- (NSMutableDictionary *)deepMutableCopy;

@property (readonly) NSDictionary *swappedDictionary;

@end










@interface NSMutableDictionary (Helpers)

- (void)swap;

@end










@interface NSDateFormatter (Helpers)

+ (instancetype)fixedDateFormatterWithDateFormat:(NSString *)dateFormat;

@end










@interface NSDate (Helpers)

+ (instancetype)GCCDate;

@end










@interface UIViewController (Helpers) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property IBInspectable NSUInteger orientations;
@property (readonly) UIAlertController *imagePickerAlertController;

- (NSString *)localize:(NSString *)string;
- (void)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType;

- (void)embedViewController:(UIViewController *)vc toView:(UIView *)view;
- (void)removeEmbeddedViewController:(UIViewController *)vc;

@end










@interface UITableViewController (Helpers)

@end










@interface UITableView (Helpers)

@property IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *emptyView;

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellAtIndexPath:(NSIndexPath *)indexPath;

@end










@interface NSBundle (Helpers)

- (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code;

@end










@interface NSError (Helpers)

- (void)setUserInfoValue:(id)value forKey:(NSString *)key;

@end










@interface UIView (Helpers) <NSCopying>

@property IBInspectable UIColor *borderColor;
@property IBInspectable UIColor *shadowColor;
@property IBInspectable CGSize intrinsicContentSize;
@property (readonly) UIImage *renderedLayer;
- (id)copyWithZone:(NSZone *)zone;
- (void)moveToView:(UIView *)view;
- (__kindof UIView *)subviewWithTag:(NSInteger)tag;

@end










@interface UIStackView (Helpers)

@property (readonly) NSArray<UIView *> *visibleArrangedSubviews;

@end










@interface NSNetService (Helpers)

+ (NSString *)stringFromAddressData:(NSData *)data;

@end










@interface UIImage (Helpers)

@property (readonly) UIColor *averageColor;

- (instancetype)imageInRect:(CGRect)rect;
- (UIColor *)colorForPoint:(CGPoint)point;

- (instancetype)imageByRotatingClockwise:(BOOL)clockwise;
- (instancetype)imageWithSize:(CGSize)size;
- (instancetype)imageWithScale:(CGFloat)scale;

- (void)writePNGToURL:(NSURL *)URL;
- (void)writePNGToURL:(NSURL *)URL completion:(VoidBlock)completion;

- (void)writeJPEGToURL:(NSURL *)URL quality:(CGFloat)quality;
- (void)writeJPEGToURL:(NSURL *)URL quality:(CGFloat)quality completion:(VoidBlock)completion;

@end










@interface UINavigationBar (Helpers)

@property IBInspectable BOOL bottomLine;

@end










@interface NSFileManager (Helpers)

@property (readonly) NSURL *userDocumentsDirectoryURL;
@property (readonly) NSURL *userCachesDirectoryURL;

@end










@interface UINib (Helpers)

- (id)viewWithTag:(NSInteger)tag;

@end










@interface NSArray (Helpers)

@end










@interface NSData (Helpers)

- (void)writeToURL:(NSURL *)URL completion:(VoidBlock)completion;

- (instancetype)digest:(Digest)digest;
@property (readonly) NSString *string;

@end










@interface NSString (Helpers)

- (NSData *)digest:(Digest)digest;

- (BOOL)isEqualToVersion:(NSString *)version;
- (BOOL)isGreaterThanVersion:(NSString *)version;
- (BOOL)isLessThanVersion:(NSString *)version;
- (BOOL)isGreaterThanOrEqualToVersion:(NSString *)version;
- (BOOL)isLessThanOrEqualToVersion:(NSString *)version;

@end










@interface UILabel (Helpers)

@property (readonly) CGSize textSize;

@end
