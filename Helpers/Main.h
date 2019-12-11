//
//  HLPMain.h
//  Helpers
//
//  Created by Dan Kalinin on 3/11/18.
//

#import <UIKit/UIKit.h>
#import "HLPDictionary.h"

@class _Reachability;

extern NSErrorDomain const HelpersErrorDomainDataCorrupted;

typedef NSString * DateFormat NS_STRING_ENUM;
extern DateFormat const DateFormatISO8601;
extern DateFormat const DateFormatISO8601Short;
extern DateFormat const DateFormatRFC1123;
extern DateFormat const DateFormatRFC850;
extern DateFormat const DateFormatAsctime;
extern DateFormat const DateFormatGCCDate;
extern DateFormat const DateFormatGCCTime;

typedef NSString * LocaleIdentifier NS_STRING_ENUM;
extern LocaleIdentifier const LocaleIdentifierPosix;

typedef NSString * Pattern NS_STRING_ENUM;
extern Pattern const PatternIP;

typedef NSString * Extension NS_STRING_ENUM;
extern Extension const ExtensionPlist;
extern Extension const ExtensionStrings;
extern Extension const ExtensionXML;
extern Extension const ExtensionJSON;
extern Extension const ExtensionMOMD;

typedef NSString * Key NS_STRING_ENUM;
extern Key const KeyRet;
extern Key const KeyPair;
extern Key const KeyState;
extern Key const KeyError;
extern Key const KeyObject;
extern Key const KeyEntity;
extern Key const KeyCompletion;
extern Key const KeyScheme;
extern Key const KeyHost;
extern Key const KeyPort;
extern Key const KeyUser;
extern Key const KeyPassword;
extern Key const KeyFragment;
extern Key const kCFBundleShortVersionStringKey;

typedef NSString * Table NS_STRING_ENUM;
extern Table const TableErrors;
extern Table const TableLocalizable;

// Runtime attributes
// ------------------------------------------------------------------------------------------------------------------------------------
// | Key path                                                                   | Type    | Value                                     |
// ------------------------------------------------------------------------------------------------------------------------------------
// | tc://lblTitle.text?hsc=2                                                   | String  | Regular                                   |
// | sg://destinationViewController.btnDone.hidden?id=Settings                  | Boolean | YES                                       |
// | kp://btnDone.enabled                                                       | String  | parentViewController.itemSelected         |
// ------------------------------------------------------------------------------------------------------------------------------------
// | sg://sourceViewController.vcSettings?id=Settings&kp=1                      | String  | destinationViewController                 |
// ------------------------------------------------------------------------------------------------------------------------------------
// | tc://destinationViewController.modalTransitionStyle?hsc=2&sg=Settings      | Number  | 0                                         |
// | tc://destinationViewController.view.backgroundColor?hsc=2&sg=Settings&kp=1 | String  | sourceViewController.vRed.backgroundColor |
// ------------------------------------------------------------------------------------------------------------------------------------
typedef NSString * Scheme NS_STRING_ENUM;
extern Scheme const SchemeTraitCollection;
extern Scheme const SchemeSegue;
extern Scheme const SchemeKeyPath;

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
extern QueryItem const QueryItemIdentifier;

typedef NSString * Interface NS_STRING_ENUM;
extern Interface const InterfaceEn0;

typedef NSString * String NS_STRING_ENUM;
extern String const StringEmpty;
extern String const StringSpace;
extern String const StringColon;
extern String const StringDot;
extern String const StringRN;
extern String const StringN;

typedef NSString * Host NS_STRING_ENUM;
extern Host const HostAny;
extern Host const HostLoopback;
extern Host const HostBroadcast;

typedef NSString * Proto NS_STRING_ENUM;
extern Proto const ProtoBT;
extern Proto const ProtoTCP;

extern NSInteger NSIntegerCarry(NSInteger value, NSInteger max);

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

extern UIEdgeInsets UIEdgeInsetsInvert(UIEdgeInsets insets);
extern CGRect UIEdgeInsetsOutsetRect(CGRect rect, UIEdgeInsets insets);

extern NSUInteger DateToMinutes(NSDate *date);
extern NSString *MinutesToHHmm(NSUInteger minutes, NSString *separator);
extern NSUInteger HHmmToMinutes(NSString *HHmm, NSString *separator);
extern NSString *DaysToEE(NSArray *days, NSString *separator);

OBJC_EXTERN SecCertificateRef SecCertificateCreateWithString(CFAllocatorRef allocator, NSString *string);
OBJC_EXTERN SecKeyRef SecKeyCreateWithString(NSString *string, NSDictionary<NSString *, id> *attributes);

typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL);
typedef void (^FloatBlock)(float);
typedef void (^DoubleBlock)(double);
typedef void (^ObjectBlock)(id);
typedef void (^Object2Block)(id, id);
typedef void (^ErrorBlock)(NSError *);
typedef void (^ArrayBlock)(NSArray *);
typedef void (^DataBlock)(NSData *);
typedef void (^ImageBlock)(UIImage *);
typedef void (^StoryboardSegueBlock)(UIStoryboardSegue *);
typedef void (^BackgroundFetchResultBlock)(UIBackgroundFetchResult);

typedef NS_ENUM(NSUInteger, Digest) {
    DigestMD5,
    DigestSHA1,
    DigestSHA224,
    DigestSHA256,
    DigestSHA384,
    DigestSHA512
};

typedef NS_ENUM(NSUInteger, _ReachabilityStatus) {
    _ReachabilityStatusNone,
    _ReachabilityStatusWiFi,
    _ReachabilityStatusWWAN
};










#pragma mark - Classes

@interface DefaultDictionary : NSMutableDictionary

@end










@interface Codable : NSObject <NSCoding>

@end










@interface Credential : Codable // Base for credentials can be stored in keychain

@end










@interface Keychain : NSObject // Convenient wrapper around Security.framework keychain services

@property NSString *account;
@property NSString *service;
@property NSData *credential;
@property NSString *password;
@property id <NSCoding> object;
@property OSStatus status;

@end










@interface WeakArray : NSMutableArray

@end










@interface SurrogateArray : WeakArray

@property NSOperationQueue *operationQueue;

@property (readonly) id lastReturnValue;

@end










@interface Sequence : NSObject

@property NSUInteger minimum;
@property NSUInteger maximum;
@property NSUInteger value;

- (NSUInteger)increment;
- (NSUInteger)decrement;

@end










@protocol _ReachabilityDelegate

@required
- (void)reachabilityDidUpdateStatus:(_Reachability *)reachability;

@end



@interface _Reachability : NSObject <_ReachabilityDelegate> // Network configuration and host reachability monitor

typedef void (^ReachabilityHandler)(_Reachability *reachability);

+ (instancetype)reachability; // Singleton reachability object for zero host name - 0.0.0.0
- (instancetype)initWithHost:(Host)host; // Create reachability object for specified host name

@property (readonly) _ReachabilityStatus status; // Reachability current status - None | WiFi | WWAN

@property (readonly) SurrogateArray<_ReachabilityDelegate> *delegates;
@property (copy) ReachabilityHandler handler; // Reachability status change handler

@end










@interface NetworkInfo : NSObject

@property (readonly) NSDictionary *dictionary;
@property (readonly) NSString *bssid;
@property (readonly) NSString *ssid;
@property (readonly) NSData *ssidData;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)infoForInterface:(Interface)interface;

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



@interface AsyncStreamPair : NSObject <NSInputStreamDelegate, NSOutputStreamDelegate> { // Convenience wrapper for I/O stream pair. In order to receive stream events and write the data to output stream, subclass and override needed methods defined by protocols listed above.
@private
    NSMutableData *_inputStreamData;
}

@property (readonly) NSString *host;
@property (readonly) NSUInteger port;

@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;

@property (readonly) SurrogateArray<NSInputStreamDelegate> *inputStreamDelegates;
@property (readonly) SurrogateArray<NSOutputStreamDelegate> *outputStreamDelegates;

- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port;

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
@property (readonly) NSString *title;

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

+ (UIColor *)colorWithColors:(NSArray<UIColor *> *)colors; // Mix multiple colors into single average color

@end










@protocol NotificationDelegate <NSObject>

@optional

#pragma mark - Keyboard

- (void)keyboardWillShowNotification:(NSNotification *)note;
- (void)keyboardDidShowNotification:(NSNotification *)note;
- (void)keyboardWillHideNotification:(NSNotification *)note;
- (void)keyboardDidHideNotification:(NSNotification *)note;

- (void)keyboardWillChangeFrameNotification:(NSNotification *)note;
- (void)keyboardDidChangeFrameNotification:(NSNotification *)note;

@end



@interface NSObject (Helpers) <NotificationDelegate>

+ (void)swizzleClassMethod:(SEL)original with:(SEL)swizzled; // Exchange implementations for class methods
+ (void)swizzleInstanceMethod:(SEL)original with:(SEL)swizzled; // Exchange implentations for instance methods

@property (nonatomic) IBInspectable BOOL keyboardWillShowNotification; // Notification observing
@property (nonatomic) IBInspectable BOOL keyboardDidShowNotification;
@property (nonatomic) IBInspectable BOOL keyboardWillHideNotification;
@property (nonatomic) IBInspectable BOOL keyboardDidHideNotification;

@property (nonatomic) IBInspectable BOOL keyboardWillChangeFrameNotification;
@property (nonatomic) IBInspectable BOOL keyboardDidChangeFrameNotification;

@property (class, readonly) NSArray<NSString *> *propertyKeys; // Get keys for properties of the class
@property (readonly) NSArray<NSString *> *propertyKeys; // Same for instances

@property (class, readonly) NSBundle *bundle; // Get bundle where class in located
@property (readonly) NSBundle *bundle; // Same for instances

@property (class, readonly) UINib *nib; // Instantiate nib object from class bundle matching with class name
@property (readonly) UINib *nib; // Same for instances

@property (readonly) DefaultDictionary *kvs; // Runtime attribute storage

+ (instancetype)objectNamed:(NSString *)name inBundle:(NSBundle *)bundle; // Unarchive object from assets catalog
+ (instancetype)objectNamed:(NSString *)name; // Unarchive object from asset catalog located in the main bundle

+ (instancetype)objectWithComponents:(NSURLComponents *)components; // Deserialize object from NSURLComponents. For example - Person?name=John&age=18.

- (void)setValuesForKeyPathsWithDictionary:(NSDictionary<NSString *,id> *)keyedValues; // - setValuesForKeysWithDictionary: counterpart for key paths
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeyPaths:(NSArray<NSString *> *)keyPaths; // - dictionaryWithValuesForKeys: counterpart for key paths

- (UIImage *)imageNamed:(NSString *)name; // Load the image from class bundle for object's trait collection. The object must conform to <UITraitEnvironment> protocol. Useful for loading images for view controllers located outside the main bundle.

- (id)performSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 withObject:(id)object3;

+ (void)invokeHandler:(VoidBlock)handler; // Check the passed block for existence and invoke it
- (void)invokeHandler:(VoidBlock)handler; // Same for instances

+ (void)invokeHandler:(ObjectBlock)handler object:(id)object; // Check the passed block for existence and invoke it with the passed object as argument
- (void)invokeHandler:(ObjectBlock)handler object:(id)object; // Same for instances

+ (void)invokeHandler:(Object2Block)handler object:(id)object1 object:(id)object2;
- (void)invokeHandler:(Object2Block)handler object:(id)object1 object:(id)object2;

+ (void)invokeHandler:(VoidBlock)handler queue:(NSOperationQueue *)queue;
- (void)invokeHandler:(VoidBlock)handler queue:(NSOperationQueue *)queue;

+ (void)invokeHandler:(ObjectBlock)handler object:(id)object queue:(NSOperationQueue *)queue;
- (void)invokeHandler:(ObjectBlock)handler object:(id)object queue:(NSOperationQueue *)queue;

+ (void)invokeHandler:(Object2Block)handler object:(id)object1 object:(id)object2 queue:(NSOperationQueue *)queue;
- (void)invokeHandler:(Object2Block)handler object:(id)object1 object:(id)object2 queue:(NSOperationQueue *)queue;

+ (void)setPointer:(id *)pointer toObject:(id)object;
- (void)setPointer:(id *)pointer toObject:(id)object;

@end










@interface NSDictionary (Helpers)

- (NSDictionary *)deepCopy; // Immutable copy of the dictionary and all nested objects. The nested objects can be only property list objects.
- (NSMutableDictionary *)deepMutableCopy; // Mutable counterpart

@property (readonly) NSDictionary *swappedDictionary; // Swap keys and values of the dictionary. If the dictionary contains multiple equal values, any of the corresponding keys will be mapped to that value.

@end










@interface NSMutableDictionary<KeyType, ObjectType> (Helpers)

- (void)swap; // @ swappedDictionary mutable counterpart
- (ObjectType)popObjectForKey:(KeyType)key;

@end










@interface NSDateFormatter (Helpers)

+ (instancetype)fixedDateFormatterWithDateFormat:(DateFormat)dateFormat; // Create the data formatter with en_US_POSIX locale identifier and 0 offset from GMT

@end










@interface NSDate (Helpers)

+ (instancetype)GCCDate; // Get the compilation date composed using __DATE__ and __TIME__ macros

@end










//@interface NSOperationQueue (Helpers)
//
//- (void)addOperationAndWait:(NSOperation *)operation;
//- (void)addOperationWithBlockAndWait:(VoidBlock)block;
//
//- (__kindof NSOperation *)operationWithName:(NSString *)name;
//
//@end










@interface UIViewController (Helpers) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ActionDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic) IBInspectable UIInterfaceOrientationMask supportedInterfaceOrientations; // Orientations, supported by current container
@property IBInspectable BOOL editableByParent; // YES - child view controller enters to edit mode with it's parent. - setEditing:animated: will be called. NO - otherwise.

@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActionItems; // Set peek and pop actions for target view controller

@property IBInspectable NSString *segueViewControllerKeyPath; // Key path for segue final destination view controller. If you want to specify the root view controller of navigation controller, the key path will be viewControllers.@index.0.
@property (readonly) __kindof UIViewController *segueViewController; // View controller accessible at @ segueViewControllerKeyPath
@property (weak, readonly) UIViewController *sourceViewController; // Segue source view controller

@property IBInspectable NSString *popoverDismissSegueIdentifier; // Unwind segue to perform instead popover dismissal
@property IBInspectable BOOL invokeAppearanceMethods; // Should the current view controller to invoke appearance methods of presenting view controller in popover presentation

@property (readonly) BOOL beingLoaded;
@property (readonly) BOOL beingUnloaded;

- (NSString *)localize:(NSString *)string; // Programmatic localization of the string from storyboard strings file. If specified key is not found, the value is taken from Localizable.strings file. If there are no localizations found in both files, argument is returned.

- (void)embedViewController:(UIViewController *)vc toView:(UIView *)view; // Add child view controller to receiver restricting the size with specified view bounds
- (void)removeEmbeddedViewController:(UIViewController *)vc; // Remove child view controller from the receiver
- (__kindof UIViewController *)childViewControllerInView:(UIView *)view;

- (void)performSegueWithIdentifier:(NSString *)identifier preparation:(StoryboardSegueBlock)preparation; // - prepareForSegue:sender: inline implementation
- (void)performSegueWithIdentifier:(NSString *)identifier animated:(BOOL)animated preparation:(StoryboardSegueBlock)preparation;

- (UIAlertController *)alertControllerImagePicker; // Action sheet alert controller to pick image from Camera or Photo library. Additional actions can be added.
- (void)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType; // Present image picker controller for Camera or Photo library. Shows Open Settings alert controller if access to source is denied.

@end










@interface UITableView (Helpers)

@property (readonly) NSInteger numberOfRows; // Get the total number of rows in table view
@property (readonly) NSArray<NSIndexPath *> *indexPaths; // Get index paths for all table view rows

- (NSArray<UITableViewCell *> *)cellsForSection:(NSInteger)section; // Visible cells in specified section
- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellAtIndexPath:(NSIndexPath *)indexPath; // Set accessory type for cell at the specified index path
- (void)selectCell:(UITableViewCell *)cell animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

@end










@interface UICollectionView (Helpers)

@property UICollectionViewFlowLayout *flowLayout;

@end










@interface UICollectionViewController (Helpers) <UICollectionViewDelegateFlowLayout>

@end










@interface NSBundle (Helpers)

@property (readonly) NSString *versionBuild;

- (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code; // Initialize NSError object from serialized Errors.plist table located in bundle. Error serialization format - domain.code.userInfo.

@end










@interface NSError (Helpers)

- (void)setUserInfoValue:(id)value forKey:(NSString *)key; // Set user info dynamic values for staticly deserialized NSError objects

@end










@interface UIWindow (Helpers)

@end










@interface UIView (Helpers) <NSCopying>

@property IBInspectable UIColor *borderColor; // @ layer.borderColor wrapper. Uses UIColor instead CGColor.
@property IBInspectable UIColor *shadowColor; // @ layer.shadowColor wrapper. Uses UIColor instead CGColor.
@property (nonatomic) IBInspectable CGSize intrinsicContentSize; // Setter used to provide intrinsic content size using Interface builder of external implementation instead overriding - intrinsicContentSize
@property (readonly) UIImage *renderedLayer; // Capture the layer shapshot into UIImage object
- (id)copyWithZone:(NSZone *)zone; // Copy the view into new object
- (void)moveToView:(UIView *)view; // Add the receiver to specified view as subview and center it
- (__kindof UIView *)subviewWithTag:(NSInteger)tag; // - viewWithTag: behavior excluding returning the receiver
+ (void)removeSubviews:(NSArray<UIView *> *)views; // Remove multiple subviews from their superviews
- (void)removeAllSubviews; // Remove all subviews from receiver

@end










@interface UIStackView (Helpers)

@property (readonly) NSArray<UIView *> *visibleArrangedSubviews; // Get not hidden arranged subviews
- (void)removeArrangedSubviews:(NSArray<UIView *> *)views; // Remove multiple arranged subviews from receiver
- (void)removeAllArrangedSubviews; // Remove all arranged subviews from receiver

@end










@interface NSNetService (Helpers)

+ (NSError *)errorFromErrorDictionary:(NSDictionary<NSString *, NSNumber *> *)dictionary;
+ (NSURLComponents *)URLComponentsFromAddressData:(NSData *)data; // Get the IP address URL representation

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
@property (readonly) NSURL *userDownloadsDirectoryURL;

@end










@interface UINib (Helpers)

- (id)viewWithTag:(NSInteger)tag; // Get view by tag from instantiated nib file

@end










@interface NSArray (Helpers)

- (void)setValues:(NSArray *)values forKey:(NSString *)key;
- (void)setValues:(NSArray *)values forKeyPath:(NSString *)keyPath; // Set values for key paths for corresponding objects of receiver

- (id)objectWithOffset:(NSInteger)offset fromObject:(id)object recursively:(BOOL)recursively;

@end










@interface NSData (Helpers)

- (void)writeToURL:(NSURL *)URL completion:(VoidBlock)completion;

- (instancetype)digest:(Digest)digest; // Calculate the digest from the receiver using specified algorythm
@property (readonly) NSString *string; // String representing the receiver in HEX format
@property (readonly) id json; // JSON representation of the receiver
@property (readonly) UIImage *image; // Image representation of the receiver with current screen scale

@end










@interface NSMutableData (Helpers)

- (NSData *)popRange:(NSRange)range;
- (NSData *)popLengthFromBegin:(NSUInteger)length;
- (NSData *)popLengthFromEnd:(NSUInteger)length;

@end










@interface NSString (Helpers)

@property (readonly) NSString *normalizedAddress;

- (NSData *)digest:(Digest)digest;

- (BOOL)isEqualToVersion:(NSString *)version; // Compare 2 strings of version numbers. For example - 2.1 and 2.1.5.
- (BOOL)isGreaterThanVersion:(NSString *)version;
- (BOOL)isLessThanVersion:(NSString *)version;
- (BOOL)isGreaterThanOrEqualToVersion:(NSString *)version;
- (BOOL)isLessThanOrEqualToVersion:(NSString *)version;

@end










@interface UILabel (Helpers)

@property (readonly) CGSize textSize; // Receiver's text bounding size

@end










@interface UITraitCollection (Helpers)

+ (instancetype)traitCollectionWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems;

@end










@interface NSURLComponents (Helpers) <NSCoding>

@property NSDictionary<NSString *, NSString *> *queryDictionary;

@end










@interface CAGradientLayer (Helpers)

@property NSArray<UIColor *> *uiColors;

@end










@interface NSInvocation (Helpers)

@property (readonly) id returnValue;

@end










@interface NSUndoManager (Helpers)

- (void)endGroupingAndUndo;

@end
