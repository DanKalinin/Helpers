//
//  Helpers.m
//  R4S
//
//  Created by Dan Kalinin on 09/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "Helpers.h"
#import <objc/runtime.h>

NSString *const DateFormatRFC1123 = @"E, dd MMM yyyy HH:mm:ss 'GMT'";
NSString *const DateFormatRFC850 = @"EEEE, dd-MMM-yy HH:mm:ss 'GMT'";
NSString *const DateFormatAsctime = @"E MMM dd HH:mm:ss yyyy";

NSString *const ErrorKey = @"ErrorKey";

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










@interface PasswordTextFieldDelegate : NSObject <UITextFieldDelegate>

@end



@implementation PasswordTextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return NO;
}

@end










@interface PasswordTextField ()

@property SurrogateContainer *delegates;
@property PasswordTextFieldDelegate *textFieldDelegate;

@end



@implementation PasswordTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegates = [SurrogateContainer new];
        self.textFieldDelegate = [PasswordTextFieldDelegate new];
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
    [btnEye addTarget:self action:@selector(onEye:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onEye:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.secureTextEntry = !sender.selected;
}

@end










@interface FilledButton ()

@property UIColor *initialBackgroundColor;

@end



@implementation FilledButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.initialBackgroundColor = self.backgroundColor;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? self.tintColor : self.initialBackgroundColor;
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










@implementation TableViewCell

@end










#pragma mark - Categories

@implementation UIColor (Helpers)

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
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

@end










@implementation NSObject (Helpers)

+ (void)swizzleClassMethod:(SEL)swizzling with:(SEL)original {
    Method swizzlingMethod = class_getClassMethod(self, swizzling);
    Method originalMethod = class_getClassMethod(self, original);
    method_exchangeImplementations(originalMethod, swizzlingMethod);
}

+ (void)swizzleInstanceMethod:(SEL)swizzling with:(SEL)original {
    Method swizzlingMethod = class_getInstanceMethod(self, swizzling);
    Method originalMethod = class_getInstanceMethod(self, original);
    method_exchangeImplementations(originalMethod, swizzlingMethod);
}

+ (NSBundle *)bundle {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    return bundle;
}

- (NSBundle *)bundle {
    NSBundle *bundle = self.class.bundle;
    return bundle;
}

@end










@implementation NSDictionary (Helpers)

+ (void)load {
    [self swizzleInstanceMethod:@selector(swizzledObjectForKeyedSubscript:) with:@selector(objectForKeyedSubscript:)];
}

- (id)swizzledObjectForKeyedSubscript:(id)key {
    id object = [self swizzledObjectForKeyedSubscript:key];
    if ([object isKindOfClass:[NSNull class]]) {
        object = nil;
    }
    return object;
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
    SEL swizzling = @selector(supportedInterfaceOrientations);
    SEL swizzled = @selector(swizzledSupportedInterfaceOrientations);
    [self swizzleInstanceMethod:swizzling with:swizzled];
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

@end
