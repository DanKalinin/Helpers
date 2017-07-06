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
extern Key const KeySegue;

typedef NSString * Table NS_STRING_ENUM;
extern Table const TableErrors;
extern Table const TableLocalizable;

typedef NSString * Scheme NS_STRING_ENUM;
extern Scheme const SchemeTraitCollection;
extern Scheme const SchemeKeyPath;
extern Scheme const SchemeDictionary;
extern Scheme const SchemeObject;

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










@interface Reachability : NSObject // Network configuration and host reachability monitor

typedef void (^ReachabilityHandler)(Reachability *reachability);

+ (instancetype)reachability; // Singleton reachability object for zero host name - 0.0.0.0
- (instancetype)initWithHost:(NSString *)host; // Create reachability object for specified host name

@property (readonly) ReachabilityStatus status; // Reachability current status - None | WiFi | WWAN
@property (copy) ReachabilityHandler handler; // Reachability status change handler

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



@interface StreamPair : NSObject <NSInputStreamDelegate, NSOutputStreamDelegate> { // Convenience wrapper for I/O stream pair. In order to receive stream events and write the data to output stream, subclass and override needed methods defined by protocols listed above.
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










@protocol Action <NSObject> // Universal action incorporating UIAlertAction, UIPreviewAction, UITableViewRowAction. Allows to handle all these actions by single handler.

@required
@property (readonly) NSInteger tag; // Common - action identication tag

@optional
@property (readonly) UIViewController *previewViewController; // Preview action - view controller to preview
@property (readonly) NSIndexPath *indexPath; // Row action - row index path

@end



@protocol ActionDelegate <NSObject>

@optional
- (void)didHandleAction:(id <Action>)action; // Universal action handler

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

@interface UIColor (Helpers) // Color helpers

+ (UIColor *)r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a; // - colorWithRed:green:blue:alpha: counterpart for value range of 0 - 255

+ (UIColor *)colorWithRGBAString:(NSString *)rgbaString; // Create the color with human-readable RGBA string. For example - 123,13,255,255.
+ (UIColor *)colorWithHexString:(NSString *)hexString; // Create the color with human-readable HEX string. For example - af5a1b.

@end










@interface NSObject (Helpers)

+ (void)swizzleClassMethod:(SEL)original with:(SEL)swizzled; // Exchange implementations for class methods
+ (void)swizzleInstanceMethod:(SEL)original with:(SEL)swizzled; // Exchange implentations for instance methods

@property (class, readonly) NSArray<NSString *> *propertyKeys; // Get keys for properties of the class
@property (readonly) NSArray<NSString *> *propertyKeys; // Same for instances

@property (class, readonly) NSBundle *bundle; // Get bundle where class in located
@property (readonly) NSBundle *bundle; // Same for instances

@property (class, readonly) UINib *nib; // Instantiate nib object from class bundle matching with class name
@property (readonly) UINib *nib; // Same for instances

@property (readonly) MutableDictionary *kvs; // Runtime attribute storage

+ (instancetype)objectNamed:(NSString *)name inBundle:(NSBundle *)bundle; // Unarchive object from assets catalog
+ (instancetype)objectNamed:(NSString *)name; // Unarchive object from asset catalog located in the main bundle

+ (instancetype)objectWithComponents:(NSURLComponents *)components; // Deserialize object from NSURLComponents. For example - Person?name=John&age=18.

- (void)setValuesForKeyPathsWithDictionary:(NSDictionary<NSString *,id> *)keyedValues; // - setValuesForKeysWithDictionary: counterpart for key paths
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeyPaths:(NSArray<NSString *> *)keyPaths; // - dictionaryWithValuesForKeys: counterpart for key paths

- (UIImage *)imageNamed:(NSString *)name; // Load the image from class bundle for object's trait collection. The object must conform to <UITraitEnvironment> protocol. Useful for loading images for view controllers located outside the main bundle.

+ (void)invokeHandler:(VoidBlock)handler; // Check the passed block for existence and invoke it
- (void)invokeHandler:(VoidBlock)handler; // Same for instances

+ (void)invokeHandler:(ObjectBlock)handler object:(id)object; // Check the passed block for existence and invoke it with the passed object as argument
- (void)invokeHandler:(ObjectBlock)handler object:(id)object; // Same for instances

@end










@interface NSDictionary (Helpers)

- (NSDictionary *)deepCopy; // Immutable copy of the dictionary and all nested objects. The nested objects can be only property list objects.
- (NSMutableDictionary *)deepMutableCopy; // Mutable counterpart

@property (readonly) NSDictionary *swappedDictionary; // Swap keys and values of the dictionary. If the dictionary contains multiple equal values, any of the corresponding keys will be mapped to that value.

@end










@interface NSMutableDictionary (Helpers)

- (void)swap; // @ swappedDictionary mutable counterpart

@end










@interface NSDateFormatter (Helpers)

+ (instancetype)fixedDateFormatterWithDateFormat:(DateFormat)dateFormat; // Create the data formatter with en_US_POSIX locale identifier and 0 offset from GMT

@end










@interface NSDate (Helpers)

+ (instancetype)GCCDate; // Get the compilation date composed using __DATE__ and __TIME__ macros

@end










@protocol ViewControllerDataSource <NSObject>

@end



@interface UIViewController (Helpers) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ActionDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic) IBInspectable UIInterfaceOrientationMask supportedInterfaceOrientations; // Orientations, supported by current container
@property IBInspectable BOOL editableByParent; // YES - child view controller enters to edit mode with it's parent. - setEditing:animated: will be called. NO - otherwise.

@property (readonly) UIAlertController *imagePickerAlertController; // Action sheet alert controller to pick image from Camera or Photo library. Additional actions can be added.
@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActionItems; // Set peek and pop actions for target view controller

@property (weak) id <ViewControllerDataSource> dataSource; // View controller data source. Setting automatically during the segue transition if source view controller conforms to <ViewControllerDataSource> protocol.
@property IBInspectable NSString *segueViewControllerKeyPath; // Key path for segue final destination view controller. If you want to specify the root view controller of navigation controller, the key path will be viewControllers.@index.0.
@property (readonly) __kindof UIViewController *segueViewController; // View controller accessible at @ segueViewControllerKeyPath
@property (weak, readonly) UIViewController *sourceViewController; // Segue source view controller

@property IBInspectable NSString *popoverDismissSegueIdentifier; // Unwind segue to perform instead popover dismissal
@property IBInspectable BOOL invokeAppearanceMethods; // Should the current view controller to invoke appearance methods of presenting view controller in popover presentation

- (NSString *)localize:(NSString *)string; // Programmatic localization of the string from storyboard strings file. If specified key is not found, the value is taken from Localizable.strings file. If there are no localizations found in both files, argument is returned.
- (void)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType; // Present image picker controller for Camera or Photo library. Shows Open Settings alert controller if access to source is denied.

- (void)embedViewController:(UIViewController *)vc toView:(UIView *)view; // Add child view controller to receiver restricting the size with specified view bounds
- (void)removeEmbeddedViewController:(UIViewController *)vc; // Remove child view controller from the receiver

@end










@interface UITableView (Helpers)

@property (readonly) NSInteger numberOfRows; // Get the total number of rows in table view
@property (readonly) NSArray<NSIndexPath *> *indexPaths; // Get index paths for all table view rows

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellAtIndexPath:(NSIndexPath *)indexPath; // Set accessory type for cell at the specified index path

@end










@interface NSBundle (Helpers)

- (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code; // Initialize NSError object from serialized Errors.plist table located in bundle. Error serialization format - domain.code.userInfo.

@end










@interface NSError (Helpers)

- (void)setUserInfoValue:(id)value forKey:(NSString *)key; // Set user info dynamic values for staticly deserialized NSError objects

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

@property (readonly) UIColor *averageColor; // Get average pixel color of the image

- (instancetype)imageInRect:(CGRect)rect; // Resize the image to fit the specified rect
- (UIColor *)colorForPoint:(CGPoint)point; // Get average pixel color at the specified point

- (instancetype)imageByRotatingClockwise:(BOOL)clockwise; // Get the image rotated CW/CCW
- (instancetype)imageWithSize:(CGSize)size;
- (instancetype)imageWithScale:(CGFloat)scale;

- (void)writePNGToURL:(NSURL *)URL; // Synchronously save the image to specified URL in PNG format
- (void)writePNGToURL:(NSURL *)URL completion:(VoidBlock)completion; // Asynchronous counterpart

- (void)writeJPEGToURL:(NSURL *)URL quality:(CGFloat)quality; // Synchronously save the image to specified URL in JPEG format with specified quality. The range of quality is 0 - 1.
- (void)writeJPEGToURL:(NSURL *)URL quality:(CGFloat)quality completion:(VoidBlock)completion; // Asynchronous counterpart

@end










@interface UINavigationBar (Helpers)

@property IBInspectable BOOL bottomLine; // Whether the bottom stroke should appear under the navigation bar

@end










@interface NSFileManager (Helpers)

@property (readonly) NSURL *userDocumentsDirectoryURL; // Quick access to user directories
@property (readonly) NSURL *userCachesDirectoryURL;

@end










@interface UINib (Helpers)

- (id)viewWithTag:(NSInteger)tag; // Get view by tag from instantiated nib file

@end










@interface NSArray (Helpers)

@end










@interface NSData (Helpers)

- (void)writeToURL:(NSURL *)URL completion:(VoidBlock)completion;

- (instancetype)digest:(Digest)digest; // Calculate the digest from the receiver using specified algorythm
@property (readonly) NSString *string; // String representing the receiver in HEX format
@property (readonly) id json; // JSON representation of the receiver
@property (readonly) UIImage *image; // Image representation of the receiver with current screen scale

@end










@interface NSString (Helpers)

- (NSData *)digest:(Digest)digest;

- (BOOL)isEqualToVersion:(NSString *)version; // Compare 2 strings of version numbers. For example - 2.1 and 2.1.5.
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










@interface NSURLComponents (Helpers)

@property NSDictionary<NSString *, NSString *> *queryDictionary;

@end










@interface UIPopoverPresentationController (Helpers)

@property id sender;

@end
