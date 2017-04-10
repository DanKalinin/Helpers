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
#import <CommonCrypto/CommonCrypto.h>

NSString *const DateFormatRFC1123 = @"E, dd MMM yyyy HH:mm:ss 'GMT'";
NSString *const DateFormatRFC850 = @"EEEE, dd-MMM-yy HH:mm:ss 'GMT'";
NSString *const DateFormatAsctime = @"E MMM dd HH:mm:ss yyyy";
NSString *const DateFormatGCCDate = @"MMM d yyyy";
NSString *const DateFormatGCCTime = @"HH:mm:ss";

NSString *const NSLocaleIdentifierPosix = @"en_US_POSIX";

NSString *const PlistExtension = @"plist";
NSString *const StringsExtension = @"strings";
NSString *const XMLExtension = @"xml";
NSString *const JSONExtension = @"json";

NSString *const ErrorKey = @"error";
NSString *const ObjectKey = @"object";

NSString *const ErrorsTable = @"Errors";
NSString *const LocalizableTable = @"Localizable";

bool CGFloatInRange(CGFloat value, UIFloatRange range) {
    bool inRange = ((value >= range.minimum) && (value <= range.maximum));
    return inRange;
}

CGFloat CGFloatClampToRange(CGFloat value, UIFloatRange range) {
    value = fmax(value, range.minimum);
    value = fmin(value, range.maximum);
    return value;
}

CGFloat CGFloatRound(CGFloat value, NSInteger precision) {
    CGFloat k = pow(10.0, precision);
    value = round(k * value) / k;
    return value;
}

CGFloat CGFloatSign(CGFloat value) {
    value /= fabs(value);
    return value;
}

CGPoint CGPointAdd(CGPoint pointLeft, CGPoint pointRight) {
    GLKVector2 vectorLeft = GLKVector2Make(pointLeft.x, pointLeft.y);
    GLKVector2 vectorRight = GLKVector2Make(pointRight.x, pointRight.y);
    GLKVector2 vector = GLKVector2Add(vectorLeft, vectorRight);
    CGPoint point = CGPointMake(vector.x, vector.y);
    return point;
}

CGPoint CGPointSubtract(CGPoint pointLeft, CGPoint pointRight) {
    GLKVector2 vectorLeft = GLKVector2Make(pointLeft.x, pointLeft.y);
    GLKVector2 vectorRight = GLKVector2Make(pointRight.x, pointRight.y);
    GLKVector2 vector = GLKVector2Subtract(vectorLeft, vectorRight);
    CGPoint point = CGPointMake(vector.x, vector.y);
    return point;
}

CGPoint CGPointMultiply(CGPoint point, CGFloat value) {
    GLKVector2 vector = GLKVector2Make(point.x, point.y);
    vector = GLKVector2MultiplyScalar(vector, value);
    point = CGPointMake(vector.x, vector.y);
    return point;
}

CGFloat CGPointDistance(CGPoint pointStart, CGPoint pointEnd) {
    GLKVector2 vectorStart = GLKVector2Make(pointStart.x, pointStart.y);
    GLKVector2 vectorEnd = GLKVector2Make(pointEnd.x, pointEnd.y);
    CGFloat distance = GLKVector2Distance(vectorStart, vectorEnd);
    return distance;
}

CGPoint CGPointClampToRect(CGPoint point, CGRect rect) {
    
    CGFloat minimum = CGRectGetMinX(rect);
    CGFloat maximum = CGRectGetMaxX(rect);
    UIFloatRange range = UIFloatRangeMake(minimum, maximum);
    point.x = CGFloatClampToRange(point.x, range);
    
    minimum = CGRectGetMinY(rect);
    maximum = CGRectGetMaxY(rect);
    range = UIFloatRangeMake(minimum, maximum);
    point.y = CGFloatClampToRange(point.y, range);
    
    return point;
}

CGPoint CGRectGetMidXMidY(CGRect rect) {
    CGFloat x = CGRectGetMidX(rect);
    CGFloat y = CGRectGetMidY(rect);
    CGPoint point = CGPointMake(x, y);
    return point;
}

NSUInteger DateToMinutes(NSDate *date) {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger hours = [calendar component:NSCalendarUnitHour fromDate:date];
    NSUInteger minutes = [calendar component:NSCalendarUnitMinute fromDate:date];
    minutes = 60 * hours + minutes;
    return minutes;
}

NSString *MinutesToHHmm(NSUInteger minutes, NSString *separator) {
    NSUInteger HH = minutes / 60;
    NSUInteger mm = minutes % 60;
    NSString *HHmm = [NSString stringWithFormat:@"%02i%@%02i", (int)HH, separator, (int)mm];
    return HHmm;
}

NSUInteger HHmmToMinutes(NSString *HHmm, NSString *separator) {
    NSUInteger minutes = NSNotFound;
    
    NSArray *components = [HHmm componentsSeparatedByString:separator];
    if (components.count == 2) {
        NSUInteger HH = [components.firstObject intValue];
        NSUInteger mm = [components.lastObject intValue];
        minutes = 60 * HH + mm;
    }
    
    return minutes;
}

NSString *DaysToEE(NSArray *days, NSString *separator) {
    NSMutableArray *components = [NSMutableArray array];
    for (NSNumber *day in days) {
        NSString *component = [NSString stringWithFormat:@"Day%@", day];
        component = [NSBundle.mainBundle localizedStringForKey:component value:component table:LocalizableTable];
        [components addObject:component];
    }
    
    NSString *EE = [components componentsJoinedByString:separator];
    EE = [NSBundle.mainBundle localizedStringForKey:EE value:EE table:LocalizableTable];
    return EE;
}










#pragma mark - Classes

@interface MutableDictionary ()

@property NSMutableDictionary *dictionary;

@end



@implementation MutableDictionary

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary.alloc initWithCapacity:numItems];
    }
    return self;
}

- (NSUInteger)count {
    NSUInteger count = self.dictionary.count;
    return count;
}

- (id)objectForKey:(id)aKey {
    id object = [self.dictionary objectForKey:aKey];
    if (!object) {
        object = [MutableDictionary dictionary];
        [self setObject:object forKey:aKey];
    }
    return object;
}

- (NSEnumerator *)keyEnumerator {
    NSEnumerator *enumerator = self.dictionary.keyEnumerator;
    return enumerator;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self.dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self.dictionary removeObjectForKey:aKey];
}

@end










@interface ImageView ()

@property UIColor *defaultBackgroundColor;

@end



@implementation ImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.defaultBackgroundColor = self.backgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else {
        self.backgroundColor = self.defaultBackgroundColor;
    }
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
    NSString *password = [NSString.alloc initWithData:credential encoding:NSUTF8StringEncoding];
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










@interface Button ()

@end



@implementation Button

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateState];
    
    if (self.toggle) {
        [self addTarget:self action:@selector(onToggle) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self.subbuttons setValue:@(highlighted) forKey:@"highlighted"];
    [self updateState];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self.subbuttons setValue:@(selected) forKey:@"selected"];
    [self updateState];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.subbuttons setValue:@(enabled) forKey:@"enabled"];
    [self updateState];
}

#pragma mark - Actions

- (void)onToggle {
    self.selected = !self.selected;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Helpers

- (void)updateState {
    
    if (self.state == UIControlStateHighlighted) {
        self.backgroundColor = self.highlightedBackgroundColor;
        self.borderColor = self.highlightedBorderColor;
    } else if (self.state == UIControlStateDisabled) {
        self.backgroundColor = self.disabledBackgroundColor;
        self.borderColor = self.disabledBorderColor;
    } else if (self.state == UIControlStateSelected) {
        self.backgroundColor = self.selectedBackgroundColor;
        self.borderColor = self.selectedBorderColor;
    } else {
        self.backgroundColor = self.defaultBackgroundColor;
        self.borderColor = self.defaultBorderColor;
    }
    
    [self setNeedsDisplay];
}

@end










@interface KeyboardContainerView ()

@end



@implementation KeyboardContainerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        UITapGestureRecognizer *tgr = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTap:)];
        tgr.cancelsTouchesInView = NO;
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
        [self.superview layoutIfNeeded];
        [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
            self.bottomConstraint.constant = shown ? endFrame.size.height : 0.0;
            [self.superview layoutIfNeeded];
        } completion:nil];
    }
}

- (void)onTap:(UITapGestureRecognizer *)tgr {
    [self endEditing:YES];
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










@interface EmitterCellImageView ()

@property CAEmitterCell *cell;

@end



@implementation EmitterCellImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cell = [CAEmitterCell emitterCell];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cell.contents = (id)self.image.CGImage;
}

@end










@implementation EmitterLayerView

@dynamic layer;

+ (Class)layerClass {
    return CAEmitterLayer.class;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.emitterCells = [self.cells valueForKey:@"cell"];
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










@interface NSObject (HelpersSelectors) <UITraitEnvironment>

@property MutableDictionary *kvs;

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

+ (NSArray<NSString *> *)propertyKeys {
    NSMutableArray *names = [NSMutableArray array];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for (unsigned int index = 0; index < count; index++) {
        objc_property_t property = properties[index];
        const char *n = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:n];
        [names addObject:name];
    }
    return names;
}

- (NSArray<NSString *> *)propertyKeys {
    NSArray *keys = self.class.propertyKeys;
    return keys;
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

- (UIImage *)imageNamed:(NSString *)name {
    id <UITraitEnvironment> object = self;
    UIImage *image = [UIImage imageNamed:name inBundle:self.bundle compatibleWithTraitCollection:object.traitCollection];
    return image;
}

+ (void)invokeHandler:(VoidBlock)handler {
    if (handler) {
        handler();
    }
}

- (void)invokeHandler:(VoidBlock)handler {
    [self.class invokeHandler:handler];
}

+ (void)invokeHandler:(ErrorBlock)handler error:(NSError *)error {
    if (handler) {
        handler(error);
    }
}

- (void)invokeHandler:(ErrorBlock)handler error:(NSError *)error {
    [self.class invokeHandler:handler error:error];
}

+ (void)invokeHandler:(DataBlock)handler data:(NSData *)data {
    if (handler) {
        handler(data);
    }
}

- (void)invokeHandler:(DataBlock)handler data:(NSData *)data {
    [self.class invokeHandler:handler data:data];
}

+ (void)invokeHandler:(ImageBlock)handler image:(UIImage *)image {
    if (handler) {
        handler(image);
    }
}

- (void)invokeHandler:(ImageBlock)handler image:(UIImage *)image {
    [self.class invokeHandler:handler image:image];
}

#pragma mark - Accessors

- (void)setKvs:(MutableDictionary *)kvs {
    objc_setAssociatedObject(self, @selector(kvs), kvs, OBJC_ASSOCIATION_RETAIN);
}

- (MutableDictionary *)kvs {
    MutableDictionary *kvs = objc_getAssociatedObject(self, @selector(kvs));
    if (!kvs) {
        kvs = [MutableDictionary dictionary];
        self.kvs = kvs;
    }
    return kvs;
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










@implementation NSDate (Helpers)

+ (instancetype)GCCDate {
    NSString *string = [NSString stringWithFormat:@"%s %s", __DATE__, __TIME__];
    NSString *format = [NSString stringWithFormat:@"%@ %@", DateFormatGCCDate, DateFormatGCCTime];
    NSDateFormatter *df = [NSDateFormatter fixedDateFormatterWithDateFormat:format];
    NSDate *date = [df dateFromString:string];
    return date;
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
    NSString *notFoundValue = @(NSNotFound).stringValue;
    NSString *table = [self.storyboard valueForKey:@"name"];
    NSString *localizedString = [self.bundle localizedStringForKey:string value:notFoundValue table:table];
    if ([localizedString isEqualToString:notFoundValue]) {
        localizedString = [NSBundle.mainBundle localizedStringForKey:string value:string table:LocalizableTable];
    }
    return localizedString;
}

- (void)embedViewController:(UIViewController *)vc toView:(UIView *)view {
    [self addChildViewController:vc];
    vc.view.frame = view.bounds;
    [view insertSubview:vc.view atIndex:0];
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










@implementation UITableView (Helpers)

- (NSInteger)numberOfRows {
    NSInteger rows = 0;
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        rows += [self numberOfRowsInSection:section];
    }
    return rows;
}

- (NSArray<NSIndexPath *> *)indexPaths {
    CGRect rect = {CGPointZero, self.contentSize};
    NSArray *indexPaths = [self indexPathsForRowsInRect:rect];
    return indexPaths;
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

- (void)setShadowColor:(UIColor *)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor *)shadowColor {
    UIColor *color = [UIColor colorWithCGColor:self.layer.shadowColor];
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

- (void)moveToView:(UIView *)view {
    CGPoint center = [view convertPoint:self.center fromView:self.superview];
    [view addSubview:self];
    self.center = center;
}

- (UIView *)subviewWithTag:(NSInteger)tag {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag = %i", (int)tag];
    UIView *view = [self.subviews filteredArrayUsingPredicate:predicate].firstObject;
    return view;
}

@end










@implementation UIStackView (Helpers)

- (NSArray<UIView *> *)visibleArrangedSubviews {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hidden = NO"];
    NSArray *views = [self.arrangedSubviews filteredArrayUsingPredicate:predicate];
    return views;
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

- (UIColor *)averageColor {
    uint8_t rgba[4];
    CGContextRef ctx = CGBitmapContextCreate(rgba, 1, 1, 8, 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    CGContextDrawImage(ctx, rect, self.CGImage);
    CGFloat r = (CGFloat)rgba[0] / 255.0;
    CGFloat g = (CGFloat)rgba[1] / 255.0;
    CGFloat b = (CGFloat)rgba[2] / 255.0;
    CGFloat a = (CGFloat)rgba[3] / 255.0;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}

- (instancetype)imageInRect:(CGRect)rect {
    CGAffineTransform transform = CGAffineTransformMakeScale(self.scale, self.scale);
    rect = CGRectApplyAffineTransform(rect, transform);
    CGImageRef img = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:img scale:self.scale orientation:UIImageOrientationUp];
    return image;
}

- (UIColor *)colorForPoint:(CGPoint)point {
    CGFloat x = point.x - 0.5;
    CGFloat y = point.y - 0.5;
    CGRect rect = CGRectMake(x, y, 1.0, 1.0);
    UIImage *image = [self imageInRect:rect];
    UIColor *color = image.averageColor;
    return color;
}

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

- (void)writePNGToURL:(NSURL *)URL {
    NSData *data = UIImagePNGRepresentation(self);
    [data writeToURL:URL atomically:YES];
}

- (void)writePNGToURL:(NSURL *)URL completion:(VoidBlock)completion {
    NSData *data = UIImagePNGRepresentation(self);
    [data writeToURL:URL completion:completion];
}

- (void)writeJPEGToURL:(NSURL *)URL quality:(CGFloat)quality {
    NSData *data = UIImageJPEGRepresentation(self, quality);
    [data writeToURL:URL atomically:YES];
}

- (void)writeJPEGToURL:(NSURL *)URL quality:(CGFloat)quality completion:(VoidBlock)completion {
    NSData *data = UIImageJPEGRepresentation(self, quality);
    [data writeToURL:URL completion:completion];
}

@end










@implementation UINavigationBar (Helpers)

@dynamic bottomLine;

- (void)setBottomLine:(BOOL)bottomLine {
    UIImage *image = bottomLine ? nil : [UIImage new];
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = image;
}

@end










@implementation NSFileManager (Helpers)

- (NSURL *)userDocumentsDirectoryURL {
    NSArray *URLs = [self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return URLs.firstObject;
}

- (NSURL *)userCachesDirectoryURL {
    NSArray *URLs = [self URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
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










@interface NSData (HelpersSelectors)

@property NSString *cachedString;

@end



@implementation NSData (Helpers)

- (void)setCachedString:(NSString *)cachedString {
    objc_setAssociatedObject(self, @selector(cachedString), cachedString, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)cachedString {
    return objc_getAssociatedObject(self, @selector(cachedString));
}

- (void)writeToURL:(NSURL *)URL completion:(VoidBlock)completion {
    [NSOperationQueue.new addOperationWithBlock:^{
        [self writeToURL:URL atomically:YES];
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self invokeHandler:completion];
        }];
    }];
}

- (instancetype)digest:(Digest)digest {
    
    NSMutableData *data = [NSMutableData data];
    
    if (digest == DigestMD5) {
        data.length = CC_MD5_DIGEST_LENGTH;
        CC_MD5(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    } else if (digest == DigestSHA1) {
        data.length = CC_SHA1_DIGEST_LENGTH;
        CC_SHA1(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    } else if (digest == DigestSHA224) {
        data.length = CC_SHA224_DIGEST_LENGTH;
        CC_SHA224(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    } else if (digest == DigestSHA256) {
        data.length = CC_SHA256_DIGEST_LENGTH;
        CC_SHA256(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    } else if (digest == DigestSHA384) {
        data.length = CC_SHA384_DIGEST_LENGTH;
        CC_SHA384(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    } else if (digest == DigestSHA512) {
        data.length = CC_SHA512_DIGEST_LENGTH;
        CC_SHA512(self.bytes, (CC_LONG)self.length, data.mutableBytes);
    }
    
    return data;
}

- (NSString *)string {
    if (self.cachedString) return self.cachedString;
    
    NSMutableString *string = [NSMutableString string];
    uint8_t *bytes = (uint8_t *)self.bytes;
    for (int i = 0; i < self.length; i++) {
        uint8_t byte = bytes[i];
        [string appendFormat:@"%02x", byte];
    }
    self.cachedString = string;
    return string;
}

@end










@implementation NSString (Helpers)

- (NSData *)digest:(Digest)digest {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    data = [data digest:digest];
    return data;
}

- (BOOL)isEqualToVersion:(NSString *)version {
    BOOL equal = ([self compare:version options:NSNumericSearch] == NSOrderedSame);
    return equal;
}

- (BOOL)isGreaterThanVersion:(NSString *)version {
    BOOL greater = ([self compare:version options:NSNumericSearch] == NSOrderedDescending);
    return greater;
}

- (BOOL)isLessThanVersion:(NSString *)version {
    BOOL less = ([self compare:version options:NSNumericSearch] == NSOrderedAscending);
    return less;
}

- (BOOL)isGreaterThanOrEqualToVersion:(NSString *)version {
    BOOL result = ([self isGreaterThanVersion:version] || [self isEqualToVersion:version]);
    return result;
}

- (BOOL)isLessThanOrEqualToVersion:(NSString *)version {
    BOOL result = ([self isLessThanVersion:version] || [self isEqualToVersion:version]);
    return result;
}

@end










@implementation UILabel (Helpers)

- (CGSize)textSize {
    
    CGSize size;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = self.font;
    
    if (self.numberOfLines == 1) {
        size = [self.text sizeWithAttributes:attributes];
    } else {
        size = self.frame.size;
        size.height = CGFLOAT_MAX;
        CGRect rect = [self.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        size = rect.size;
    }
    
    return size;
}

@end
