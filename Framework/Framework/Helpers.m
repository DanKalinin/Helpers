//
//  Helpers.m
//  R4S
//
//  Created by Dan Kalinin on 09/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "Helpers.h"
#import <objc/runtime.h>
#import <arpa/inet.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <GLKit/GLKit.h>

NSString *const DateFormatRFC1123 = @"E, dd MMM yyyy HH:mm:ss 'GMT'";
NSString *const DateFormatRFC850 = @"EEEE, dd-MMM-yy HH:mm:ss 'GMT'";
NSString *const DateFormatAsctime = @"E MMM dd HH:mm:ss yyyy";

NSString *const PlistExtension = @"plist";
NSString *const XMLExtension = @"xml";
NSString *const JSONExtension = @"json";

NSString *const ErrorKey = @"error";
NSString *const ObjectKey = @"object";

CGFloat CGPointDistance(CGPoint p1, CGPoint p2) {
    GLKVector2 v1 = GLKVector2Make(p1.x, p1.y);
    GLKVector2 v2 = GLKVector2Make(p2.x, p2.y);
    CGFloat distance = GLKVector2Distance(v1, v2);
    return distance;
}

static NSString *const ErrorsTable = @"Errors";

static NSString *const NSLocaleIdentifierPosix = @"en_US_POSIX";










#pragma mark - Classes

@implementation ImageView

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = self.tintColor;
}

@end










@interface Keychain ()

@property NSMutableDictionary *query;

@end



@implementation Keychain

#pragma mark - Setup

- (instancetype)init {
    self = [super init];
    if (self) {
        self.query = [NSMutableDictionary dictionary];
        self.query[(id)kSecClass] = (id)kSecClassGenericPassword;
    }
    return self;
}

- (void)setAccount:(NSString *)account {
    self.query[(id)kSecAttrAccount] = account;
}

- (NSString *)account {
    return self.query[(id)kSecAttrAccount];
}

- (void)setService:(NSString *)service {
    self.query[(id)kSecAttrService] = service;
}

- (NSString *)service {
    return self.query[(id)kSecAttrService];
}

#pragma mark - Password

- (void)setCredential:(NSData *)credential {
    NSData *c = [self credential];
    if (self.status == errSecSuccess) {
        if (credential) {
            if (![credential isEqual:c]) {
                [self updateCredential:credential];
            }
        } else {
            [self deleteCredential];
        }
    } else if (self.status == errSecItemNotFound) {
        if (credential) {
            [self addCredential:credential];
        }
    }
}

- (NSData *)credential {
    
    NSMutableDictionary *query = self.query.mutableCopy;
    query[(id)kSecReturnData] = @YES;
    
    CFDataRef data = NULL;
    self.status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&data);
    
    NSData *credential = nil;
    if (self.status == errSecSuccess) {
        credential = (__bridge NSData *)data;
    }
    return credential;
}

- (void)setPassword:(NSString *)password {
    NSData *credential = [password dataUsingEncoding:NSUTF8StringEncoding];
    [self setCredential:credential];
}

- (NSString *)password {
    NSData *credential = [self credential];
    NSString *password = [[NSString alloc] initWithData:credential encoding:NSUTF8StringEncoding];
    return password;
}

#pragma mark - Helpers

- (void)addCredential:(NSData *)credential {
    
    NSMutableDictionary *query = self.query.mutableCopy;
    query[(id)kSecValueData] = credential;
    
    self.status = SecItemAdd((CFDictionaryRef)query, NULL);
}

- (void)updateCredential:(NSData *)credential {
    
    NSMutableDictionary *update = [NSMutableDictionary dictionary];
    update[(id)kSecValueData] = credential;
    
    self.status = SecItemUpdate((CFDictionaryRef)self.query, (CFDictionaryRef)update);
}

- (void)deleteCredential {
    self.status = SecItemDelete((CFDictionaryRef)self.query);
}

@end










@interface SurrogateContainer ()

@property NSPointerArray *pointers;

@end



@implementation SurrogateContainer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pointers = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark - Accessors

- (void)setObjects:(NSArray *)objects {
    self.pointers.count = 0;
    for (id object in objects) {
        void *pointer = (__bridge void *)object;
        [self.pointers addPointer:pointer];
    }
}

- (NSArray *)objects {
    return self.pointers.allObjects;
}

#pragma mark - Message forwarding

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [self.pointers compact];
    for (id object in self.pointers) {
        if ([object respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:object];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        [self.pointers compact];
        for (id object in self.pointers) {
            signature = [object methodSignatureForSelector:aSelector];
            if (signature) break;
        }
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    [self.pointers compact];
    for (id object in self.pointers) {
        if ([object respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return NO;
}

@end










@interface TextFieldDelegate : NSObject <UITextFieldDelegate>

@end



@implementation TextFieldDelegate

- (BOOL)textField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.maxLength > 0 && text.length > textField.maxLength) {
        text = [text substringToIndex:textField.maxLength];
    }
    textField.text = text;
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    return NO;
}

@end










@interface TextField ()

@property SurrogateContainer *delegates;
@property TextFieldDelegate *textFieldDelegate;

@end



@implementation TextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegates = [SurrogateContainer new];
        self.textFieldDelegate = [TextFieldDelegate new];
        self.delegates.objects = @[self.textFieldDelegate];
        [super setDelegate:(id)self.delegates];
    }
    return self;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    self.delegates.objects = @[self.textFieldDelegate, delegate];
}

- (void)setRightView:(UIButton *)btnEye {
    [super setRightView:btnEye];
    if (self.secureTextEntry) {
        [btnEye addTarget:self action:@selector(onEye:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)onEye:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.secureTextEntry = !sender.selected;
}

@end










@interface FilledButton ()

@property UIColor *defaultBackgroundColor;
@property UIColor *defaultBorderColor;

@end



@implementation FilledButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.defaultBackgroundColor = self.backgroundColor;
    self.defaultBorderColor = self.borderColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = self.highlightedBackgroundColor;
        self.borderColor = self.highlightedBorderColor;
    } else {
        self.backgroundColor = self.defaultBackgroundColor;
        self.borderColor = self.defaultBorderColor;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = self.selectedBackgroundColor;
        self.borderColor = self.selectedBorderColor;
    } else {
        self.backgroundColor = self.defaultBackgroundColor;
        self.borderColor = self.defaultBorderColor;
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        self.backgroundColor = self.defaultBackgroundColor;
        self.borderColor = self.defaultBorderColor;
    } else {
        self.backgroundColor = self.disabledBackgroundColor;
        self.borderColor = self.disabledBorderColor;
    }
}

@end










@interface KeyboardContainerView ()

@end



@implementation KeyboardContainerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tgr];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willChangeKeyboardFrame:(NSNotification *)note {
    BOOL isLocalKeyboard = [note.userInfo[UIKeyboardIsLocalUserInfoKey] boolValue];
    if (isLocalKeyboard) {
        NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve curve = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        BOOL shown = endFrame.origin.y < self.window.frame.size.height;
        self.bottomConstraint.constant = shown ? endFrame.size.height : 0.0;
        [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
            [self.superview layoutIfNeeded];
        } completion:nil];
    }
}

- (void)onTap:(UITapGestureRecognizer *)tgr {
    [self endEditing:YES];
}

@end










@implementation TableViewController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = self.cells[indexPath.row];
    CGFloat height = cell.frame.size.height * !cell.hidden;
    return height;
}

@end










@interface TableViewCell ()

@property UITableViewCellAccessoryType defaultAccessoryType;

@end



@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.defaultAccessoryType = self.accessoryType;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? self.selectedAccessoryType : self.defaultAccessoryType;
}

@end










@implementation ShapeLayerView

@dynamic layer;

+ (Class)layerClass {
    return CAShapeLayer.class;
}

@end










@implementation GradientLayerView

@dynamic layer;

+ (Class)layerClass {
    return CAGradientLayer.class;
}

@end










#pragma mark - Categories

@implementation UIColor (Helpers)

+ (UIColor *)r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a {
    r /= 255.0;
    g /= 255.0;
    b /= 255.0;
    UIColor *color = [self colorWithRed:r green:g blue:b alpha:a];
    return color;
}

+ (UIColor *)colorWithRGBAString:(NSString *)rgbaString {
    NSArray *components = [rgbaString componentsSeparatedByString:@","];
    NSString *r = components[0];
    NSString *g = components[1];
    NSString *b = components[2];
    NSString *a = components[3];
    UIColor *color = [self r:r.doubleValue g:g.doubleValue b:b.doubleValue a:a.doubleValue];
    return color;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned int n, r, g, b;
    CGFloat k, red, green, blue;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&n];
    
    r = (n & 0xffffff) >> 16;
    g = (n & 0x00ffff) >> 8;
    b = n & 0x0000ff;
    
    k = 1.0 / 255.0;
    red = k * r;
    green = k * g;
    blue = k * b;
    
    UIColor *color = [self colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

@end










@implementation NSObject (Helpers)

+ (void)swizzleClassMethod:(SEL)original with:(SEL)swizzled {
    Method originalMethod = class_getClassMethod(self, original);
    Method swizzledMethod = class_getClassMethod(self, swizzled);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)swizzleInstanceMethod:(SEL)original with:(SEL)swizzled {
    Method originalMethod = class_getInstanceMethod(self, original);
    Method swizzledMethod = class_getInstanceMethod(self, swizzled);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (NSBundle *)bundle {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    return bundle;
}

- (NSBundle *)bundle {
    NSBundle *bundle = self.class.bundle;
    return bundle;
}

+ (UINib *)nib {
    NSString *name = NSStringFromClass(self);
    UINib *nib = [UINib nibWithNibName:name bundle:self.bundle];
    return nib;
}

- (UINib *)nib {
    UINib *nib = self.class.nib;
    return nib;
}

+ (instancetype)objectNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    NSDataAsset *asset = [NSDataAsset.alloc initWithName:name bundle:bundle];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:asset.data];
    return object;
}

+ (instancetype)objectNamed:(NSString *)name {
    id object = [self objectNamed:name inBundle:nil];
    return object;
}

+ (void)invokeHandler:(ErrorBlock)handler error:(NSError *)error {
    if (handler) {
        handler(error);
    }
}

- (void)invokeHandler:(ErrorBlock)handler error:(NSError *)error {
    [self.class invokeHandler:handler error:error];
}

@end










@implementation NSDictionary (Helpers)

+ (void)load {
    SEL original = @selector(objectForKeyedSubscript:);
    SEL swizzled = @selector(swizzledObjectForKeyedSubscript:);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (id)swizzledObjectForKeyedSubscript:(id)key {
    id object = [self swizzledObjectForKeyedSubscript:key];
    if ([object isKindOfClass:[NSNull class]]) {
        object = nil;
    }
    return object;
}

- (NSDictionary *)deepCopy {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return dictionary;
}

- (NSMutableDictionary *)deepMutableCopy {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:nil];
    return dictionary;
}

- (NSDictionary *)swappedDictionary {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:self.allKeys forKeys:self.allValues];
    return dictionary;
}

@end










@implementation NSMutableDictionary (Helpers)

- (void)swap {
    NSDictionary *dictionary = [self swappedDictionary];
    [self setDictionary:dictionary];
}

@end










@implementation NSDateFormatter (Helpers)

+ (instancetype)fixedDateFormatterWithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = dateFormat;
    df.locale = [NSLocale localeWithLocaleIdentifier:NSLocaleIdentifierPosix];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return df;
}

@end










@implementation UIViewController (Helpers)

+ (void)load {
    SEL original = @selector(supportedInterfaceOrientations);
    SEL swizzled = @selector(swizzledSupportedInterfaceOrientations);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (void)setOrientations:(NSUInteger)orientations {
    objc_setAssociatedObject(self, @selector(orientations), @(orientations), OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)orientations {
    NSNumber *orientations = objc_getAssociatedObject(self, @selector(orientations));
    if (orientations) {
        return orientations.unsignedIntegerValue;
    }
    return NSNotFound;
}

- (UIInterfaceOrientationMask)swizzledSupportedInterfaceOrientations {
    UIInterfaceOrientationMask orientations = self.orientations;
    if (orientations != NSNotFound) {
        return orientations;
    }
    
    orientations = [self swizzledSupportedInterfaceOrientations];
    return orientations;
}

- (NSString *)localize:(NSString *)string {
    NSString *table = [self.storyboard valueForKey:@"name"];
    string = [self.bundle localizedStringForKey:string value:string table:table];
    return string;
}

- (void)embedViewController:(UIViewController *)vc toFrame:(CGRect)frame {
    [self addChildViewController:vc];
    vc.view.frame = frame;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

- (void)removeEmbeddedViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

#pragma mark - Image picker controller

- (UIAlertController *)imagePickerAlertController {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Camera
    
    BOOL addAction = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (addAction) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:[self localize:@"Take a picture"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self presentImagePickerControllerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
        [ac addAction:cameraAction];
    }
    
    // Photos
    
    addAction = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    if (addAction) {
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:[self localize:@"Choose from gallery"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self presentImagePickerControllerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        }];
        [ac addAction:photoAction];
    }
    
    // Cancel
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self localize:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:cancelAction];
    
    return ac;
}

- (void)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    BOOL denied = [self isDeniedImagePickerControllerSourceType:sourceType];
    if (denied) return;
    
    UIImagePickerController *cameraController = [UIImagePickerController new];
    cameraController.sourceType = sourceType;
    cameraController.allowsEditing = NO;
    cameraController.delegate = self;
    
    [self presentViewController:cameraController animated:YES completion:nil];
}

- (BOOL)isDeniedImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType {
    BOOL denied = NO;
    
    BOOL cameraSourceType = (sourceType == UIImagePickerControllerSourceTypeCamera);
    if (cameraSourceType) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        denied = (status == AVAuthorizationStatusDenied);
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        denied = (status == PHAuthorizationStatusDenied);
    }
    
    if (denied) {
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:[self localize:@"Open Settings"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication openURL:settingsURL];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self localize:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
        
        NSString *title, *message;
        if (cameraSourceType) {
            title = [self localize:@"Camera access denied"];
            message = [self localize:@"You can allow access to camera in Settings"];
        } else {
            title = [self localize:@"Photos access denied"];
            message = [self localize:@"You can allow access to photos in Settings"];
        }
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:settingsAction];
        [ac addAction:cancelAction];
        
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    return denied;
}

@end










@interface TableViewDataSource : NSObject <UITableViewDataSource>

@end



@implementation TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    SurrogateContainer *dataSources = tableView.dataSource;
    id <UITableViewDataSource> dataSource = dataSources.objects.firstObject;
    NSInteger sections = [dataSource numberOfSectionsInTableView:tableView];
    if (tableView.emptyView) {
        BOOL show = (sections == 0);
        if (sections == 1) {
            NSInteger rows = [dataSource tableView:tableView numberOfRowsInSection:0];
            show = (rows == 0);
        }
        tableView.backgroundView = show ? tableView.emptyView : nil;
    }
    return sections;
}

@end










@implementation UITableViewController (Helpers)

@end










@interface UITableView (HelpersSelectors)

@property SurrogateContainer *dataSources;
@property TableViewDataSource *tableViewDataSource;

@end



@implementation UITableView (Helpers)

+ (void)load {
    SEL original = @selector(setDataSource:);
    SEL swizzled = @selector(swizzledSetDataSource:);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (void)swizzledSetDataSource:(id<UITableViewDataSource>)dataSource {
    NSString *a = NSStringFromClass(self.class);
    NSString *b = NSStringFromClass(UITableView.class);
    if ([a isEqualToString:b]) {
        self.dataSources = [SurrogateContainer new];
        self.tableViewDataSource = [TableViewDataSource new];
        self.dataSources.objects = @[dataSource, self.tableViewDataSource];
        [self swizzledSetDataSource:(id)self.dataSources];
    } else {
        [self swizzledSetDataSource:dataSource];
    }
}

- (void)setEmptyView:(UIView *)emptyView {
    objc_setAssociatedObject(self, @selector(emptyView), emptyView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)emptyView {
    return objc_getAssociatedObject(self, @selector(emptyView));
}

- (void)setDataSources:(SurrogateContainer *)dataSources {
    objc_setAssociatedObject(self, @selector(dataSources), dataSources, OBJC_ASSOCIATION_RETAIN);
}

- (SurrogateContainer *)dataSources {
    return objc_getAssociatedObject(self, @selector(dataSources));
}

- (void)setTableViewDataSource:(TableViewDataSource *)tableViewDataSource {
    objc_setAssociatedObject(self, @selector(tableViewDataSource), tableViewDataSource, OBJC_ASSOCIATION_RETAIN);
}

- (TableViewDataSource *)tableViewDataSource {
    return objc_getAssociatedObject(self, @selector(tableViewDataSource));
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    cell.accessoryType = accessoryType;
}

@end










@interface NSBundle (HelpersSelectors)

@property NSDictionary *errorUserInfos;

@end



@implementation NSBundle (Helpers)

- (void)setErrorUserInfos:(NSDictionary *)errorUserInfos {
    objc_setAssociatedObject(self, @selector(errorUserInfos), errorUserInfos, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)errorUserInfos {
    NSDictionary *userInfos = objc_getAssociatedObject(self, @selector(errorUserInfos));
    if (userInfos) return userInfos;
    
    NSURL *URL = [self URLForResource:ErrorsTable withExtension:PlistExtension];
    NSDictionary *errorUserInfos = [NSDictionary dictionaryWithContentsOfURL:URL];
    self.errorUserInfos = errorUserInfos;
    return errorUserInfos;
}

- (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code {
    NSDictionary *userInfo = self.errorUserInfos[domain][@(code).stringValue];
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}

@end










@implementation NSError (Helpers)

- (void)setUserInfoValue:(id)value forKey:(NSString *)key {
    NSString *userInfoKey = NSStringFromSelector(@selector(userInfo));
    NSMutableDictionary *userInfo = self.userInfo.mutableCopy;
    userInfo[key] = value;
    [self setValue:userInfo forKey:userInfoKey];
}

@end










@implementation UIView (Helpers)

+ (void)load {
    SEL original = @selector(intrinsicContentSize);
    SEL swizzled = @selector(swizzledIntrinsicContentSize);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    UIColor *color = [UIColor colorWithCGColor:self.layer.borderColor];
    return color;
}

- (void)setIntrinsicContentSize:(CGSize)intrinsicContentSize {
    NSValue *size = [NSValue valueWithCGSize:intrinsicContentSize];
    objc_setAssociatedObject(self, @selector(intrinsicContentSize), size, OBJC_ASSOCIATION_RETAIN);
    [self invalidateIntrinsicContentSize];
}

- (CGSize)swizzledIntrinsicContentSize {
    NSValue *size = objc_getAssociatedObject(self, @selector(intrinsicContentSize));
    if (size) {
        return size.CGSizeValue;
    } else {
        return [self swizzledIntrinsicContentSize];
    }
}

- (UIImage *)renderedLayer {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (id)copyWithZone:(NSZone *)zone {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    id copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return copy;
}

@end










@implementation NSNetService (Helpers)

+ (NSString *)stringFromAddressData:(NSData *)data {
    struct sockaddr_in *addressStruct = (struct sockaddr_in *)data.bytes;
    char *addressChars = inet_ntoa(addressStruct->sin_addr);
    NSString *addressString = [NSString stringWithUTF8String:addressChars];
    return addressString;
}

@end










@implementation UIImage (Helpers)

- (instancetype)imageByRotatingClockwise:(BOOL)clockwise {
    
    UIImageOrientation orientation = self.imageOrientation;
    if (orientation == UIImageOrientationUp) {
        orientation = clockwise ? UIImageOrientationRight : UIImageOrientationLeft;
    } else if (orientation == UIImageOrientationDown) {
        orientation = clockwise ? UIImageOrientationLeft : UIImageOrientationRight;
    } else if (orientation == UIImageOrientationLeft) {
        orientation = clockwise ? UIImageOrientationUp : UIImageOrientationDown;
    } else if (orientation == UIImageOrientationRight) {
        orientation = clockwise ? UIImageOrientationDown : UIImageOrientationUp;
    }
    
    UIImage *image = [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:orientation];
    return image;
}

- (instancetype)imageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    CGRect rect = {CGPointZero, size};
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (instancetype)imageWithScale:(CGFloat)scale {
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CGSize size = CGSizeApplyAffineTransform(self.size, transform);
    UIImage *image = [self imageWithSize:size];
    return image;
}

- (BOOL)writePNGToURL:(NSURL *)URL error:(NSError **)error {
    NSData *data = UIImagePNGRepresentation(self);
    BOOL success = [data writeToURL:URL error:error];
    return success;
}

- (void)writePNGToURL:(NSURL *)URL completion:(ErrorBlock)completion {
    NSData *data = UIImagePNGRepresentation(self);
    [data writeToURL:URL completion:completion];
}

@end










@implementation NSFileManager (Helpers)

- (NSURL *)userDocumentsDirectoryURL {
    NSArray *URLs = [self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return URLs.firstObject;
}

@end










@implementation UINib (Helpers)

- (id)viewWithTag:(NSInteger)tag {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag = %i", (int)tag];
    
    NSArray *objects = [self instantiateWithOwner:nil options:nil];
    id object = [objects filteredArrayUsingPredicate:predicate].firstObject;
    return object;
}

@end










@implementation NSArray (Helpers)

- (id)_indexForKeyPath:(NSString *)keypath {
    NSInteger index = keypath.integerValue;
    if (index < 0) return nil;
    if (index >= self.count) return nil;
    
    id object = self[index];
    return object;
}

@end










@implementation NSData (Helpers)

- (BOOL)writeToURL:(NSURL *)URL error:(NSError **)error {
    BOOL success = [self writeToURL:URL options:NSDataWritingAtomic error:error];
    return success;
}

- (void)writeToURL:(NSURL *)URL completion:(ErrorBlock)completion {
    [NSOperationQueue.new addOperationWithBlock:^{
        NSError *error = nil;
        [self writeToURL:URL options:NSDataWritingAtomic error:&error];
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self invokeHandler:completion error:error];
        }];
    }];
}

@end
