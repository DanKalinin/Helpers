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

typedef NSString * DateFormat NS_STRING_ENUM;
extern DateFormat const DateFormatRFC1123;
extern DateFormat const DateFormatRFC850;
extern DateFormat const DateFormatAsctime;
extern DateFormat const DateFormatGCCDate;
extern DateFormat const DateFormatGCCTime;

typedef NSString * LocaleIdentifier NS_STRING_ENUM;
extern LocaleIdentifier const LocaleIdentifierPosix;

typedef NSString * Extension NS_STRING_ENUM;
extern Extension const ExtensionPlist;
extern Extension const ExtensionStrings;
extern Extension const ExtensionXML;
extern Extension const ExtensionJSON;

typedef NSString * Key NS_STRING_ENUM;
extern Key const KeyError;
extern Key const KeyObject;

typedef NSString * Table NS_STRING_ENUM;
extern Table const TableErrors;
extern Table const TableLocalizable;

typedef NSString * Scheme NS_STRING_ENUM;
extern Scheme const SchemeTraitCollection;

typedef NSString * QueryItem NS_STRING_ENUM;
extern QueryItem const QueryItemDisplayScale;
extern QueryItem const QueryItemHorizontalSizeClass;
extern QueryItem const QueryItemUserInterfaceIdiom;
extern QueryItem const QueryItemVerticalSizeClass;
extern QueryItem const QueryItemForceTouchCapability;
extern QueryItem const QueryItemDisplayGamut;
extern QueryItem const QueryItemLayoutDirection;
extern QueryItem const QueryItemPreferredContentSizeCategory;
extern QueryItem const QueryItemUserInterfaceStyle;

extern bool CGFloatInRange(CGFloat value, UIFloatRange range);
extern CGFloat CGFloatClampToRange(CGFloat value, UIFloatRange range);
extern CGFloat CGFloatRound(CGFloat value, NSInteger precision);
extern CGFloat CGFloatSign(CGFloat value);

extern CGPoint CGPointAdd(CGPoint pointLeft, CGPoint pointRight);
extern CGPoint CGPointSubtract(CGPoint pointLeft, CGPoint pointRight);
extern CGPoint CGPointMultiply(CGPoint point, CGFloat value);
extern CGFloat CGPointDistance(CGPoint pointStart, CGPoint pointEnd);
extern CGPoint CGPointClampToRect(CGPoint point, CGRect rect);

extern CGPoint CGRectGetMidXMidY(CGRect rect);

extern NSUInteger DateToMinutes(NSDate *date);
extern NSString *MinutesToHHmm(NSUInteger minutes, NSString *separator);
extern NSUInteger HHmmToMinutes(NSString *HHmm, NSString *separator);
extern NSString *DaysToEE(NSArray *days, NSString *separator);

typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL);
typedef void (^FloatBlock)(float);
typedef void (^DoubleBlock)(double);
typedef void (^ObjectBlock)(id);
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

typedef NS_ENUM(NSUInteger, ReachabilityStatus) {
    ReachabilityStatusNone,
    ReachabilityStatusWiFi,
    ReachabilityStatusWWAN
};










#pragma mark - Classes

@interface MutableDictionary : NSMutableDictionary

@end










@interface ImageView : UIImageView

@property IBInspectable UIColor *defaultBackgroundColor;
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










@interface Button : UIButton

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *subbuttons;

@property (weak, nonatomic) IBOutlet Button *button1;
@property (weak, nonatomic) IBOutlet Button *button2;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet ImageView *imageView1;

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










@interface Reachability : NSObject

typedef void (^ReachabilityHandler)(Reachability *reachability);

+ (instancetype)reachability;
- (instancetype)initWithHost:(NSString *)host;

@property (readonly) ReachabilityStatus status;
@property (copy) ReachabilityHandler handler;

@end










@protocol NSInputStreamDelegate <NSStreamDelegate>

@optional
- (void)inputStreamOpenCompleted:(NSInputStream *)inputStream;
- (void)inputStreamHasBytesAvailable:(NSInputStream *)inputStream;
- (void)inputStreamErrorOccurred:(NSInputStream *)inputStream;
- (void)inputStreamEndEncountered:(NSInputStream *)inputStream;
- (void)inputStream:(NSInputStream *)inputStream didReceiveData:(NSData *)data;

@end



@protocol NSOutputStreamDelegate <NSStreamDelegate>

@optional
- (void)outputStreamOpenCompleted:(NSOutputStream *)outputStream;
- (void)outputStreamHasSpaceAvailable:(NSOutputStream *)outputStream;
- (void)outputStreamErrorOccurred:(NSOutputStream *)outputStream;
- (void)outputStreamEndEncountered:(NSOutputStream *)outputStream;

@end



@interface StreamPair : NSObject <NSInputStreamDelegate, NSOutputStreamDelegate> {
    @private
    SurrogateContainer *_inputStreamDelegates;
    SurrogateContainer *_outputStreamDelegates;
    NSMutableData *_inputStreamData;
}

@property (readonly) NSString *host;
@property (readonly) NSUInteger port;

@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;

@property (weak, nonatomic) id<NSInputStreamDelegate> inputStreamDelegate;
@property (weak, nonatomic) id<NSOutputStreamDelegate> outputStreamDelegate;

+ (instancetype)streamPairWithHost:(NSString *)host port:(NSUInteger)port;

- (void)inputStreamOpenCompleted:(NSInputStream *)inputStream;
- (void)inputStreamHasBytesAvailable:(NSInputStream *)inputStream;
- (void)inputStreamErrorOccurred:(NSInputStream *)inputStream;
- (void)inputStreamEndEncountered:(NSInputStream *)inputStream;
- (void)inputStream:(NSInputStream *)inputStream didReceiveData:(NSData *)data;

- (void)outputStreamOpenCompleted:(NSOutputStream *)outputStream;
- (void)outputStreamHasSpaceAvailable:(NSOutputStream *)outputStream;
- (void)outputStreamErrorOccurred:(NSOutputStream *)outputStream;
- (void)outputStreamEndEncountered:(NSOutputStream *)outputStream;

@end










@protocol Action <NSObject>

@required
@property (readonly) NSInteger tag; // Common - action identication tag

@optional
@property (readonly) UIViewController *previewViewController; // Preview action - view controller to preview
@property (readonly) NSIndexPath *indexPath; // Row action - row index path

@end



@protocol ActionDelegate <NSObject>

@optional
- (void)didHandleAction:(id <Action>)action;

@end



@interface AlertAction : UIAlertAction <Action>

@property (readonly) NSInteger tag;
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style delegate:(id <ActionDelegate>)delegate tag:(NSInteger)tag;

@end



@interface PreviewAction : UIPreviewAction <Action>

@property (readonly) NSInteger tag;
@property (readonly) UIViewController *previewViewController;
+ (instancetype)actionWithTitle:(NSString *)title style:(UIPreviewActionStyle)style delegate:(id <ActionDelegate>)delegate tag:(NSInteger)tag;

@end



@interface TableViewRowAction : UITableViewRowAction <Action>

@property (readonly) NSInteger tag;
@property (readonly) NSIndexPath *indexPath;
+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style title:(NSString *)title delegate:(id <ActionDelegate>)delegate tag:(NSInteger)tag;

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

@property (readonly) MutableDictionary *kvs;

+ (instancetype)objectNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (instancetype)objectNamed:(NSString *)name;

+ (instancetype)objectWithComponents:(NSURLComponents *)components; // Person://?name=John&age=18
- (void)setValuesForKeyPathsWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems;
- (NSArray<NSURLQueryItem *> *)queryItemsForKeyPaths:(NSArray<NSString *> *)keyPaths;

- (void)setValuesForKeyPathsWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeyPaths:(NSArray<NSString *> *)keyPaths;

- (UIImage *)imageNamed:(NSString *)name;

+ (void)invokeHandler:(VoidBlock)handler;
- (void)invokeHandler:(VoidBlock)handler;

+ (void)invokeHandler:(ObjectBlock)handler object:(id)object;
- (void)invokeHandler:(ObjectBlock)handler object:(id)object;

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










@protocol ViewControllerDataSource <NSObject>

@end



@interface UIViewController (Helpers) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ActionDelegate>

@property (nonatomic) IBInspectable UIInterfaceOrientationMask supportedInterfaceOrientations;
@property IBInspectable BOOL editableByParent;

@property (readonly) UIAlertController *imagePickerAlertController;
@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActionItems;

@property (weak) id <ViewControllerDataSource> dataSource;
@property IBInspectable NSString *segueViewControllerKeyPath;
@property (readonly) __kindof UIViewController *segueViewController;

- (NSString *)localize:(NSString *)string;
- (void)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType;

- (void)embedViewController:(UIViewController *)vc toView:(UIView *)view;
- (void)removeEmbeddedViewController:(UIViewController *)vc;

@end










@interface UITableView (Helpers)

@property (readonly) NSInteger numberOfRows;
@property (readonly) NSArray<NSIndexPath *> *indexPaths;

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
@property (nonatomic) IBInspectable CGSize intrinsicContentSize;
@property (readonly) UIImage *renderedLayer;
- (id)copyWithZone:(NSZone *)zone;
- (void)moveToView:(UIView *)view;
- (__kindof UIView *)subviewWithTag:(NSInteger)tag;
- (void)removeSubviews:(NSArray<UIView *> *)views;
- (void)removeAllSubviews;

@end










@interface UIStackView (Helpers)

@property (readonly) NSArray<UIView *> *visibleArrangedSubviews;
- (void)removeArrangedSubviews:(NSArray<UIView *> *)views;
- (void)removeAllArrangedSubviews;

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
@property (readonly) id json;
@property (readonly) UIImage *image;

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










@interface UITraitCollection (Helpers)

+ (instancetype)traitCollectionWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems;

@end
