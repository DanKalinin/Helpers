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
#import <SystemConfiguration/SystemConfiguration.h>

DateFormat const DateFormatISO8601 = @"yyyy-MM-dd'T'HH:mm:ss";
DateFormat const DateFormatRFC1123 = @"E, dd MMM yyyy HH:mm:ss 'GMT'";
DateFormat const DateFormatRFC850 = @"EEEE, dd-MMM-yy HH:mm:ss 'GMT'";
DateFormat const DateFormatAsctime = @"E MMM dd HH:mm:ss yyyy";
DateFormat const DateFormatGCCDate = @"MMM d yyyy";
DateFormat const DateFormatGCCTime = @"HH:mm:ss";

LocaleIdentifier const LocaleIdentifierPosix = @"en_US_POSIX";

Extension const ExtensionPlist = @"plist";
Extension const ExtensionStrings = @"strings";
Extension const ExtensionXML = @"xml";
Extension const ExtensionJSON = @"json";

Key const KeyError = @"error";
Key const KeyObject = @"object";

Table const TableErrors = @"Errors";
Table const TableLocalizable = @"Localizable";

Scheme const SchemeTraitCollection = @"tc";
Scheme const SchemeSegue = @"sg";
Scheme const SchemeKeyPath = @"kp";

QueryItem const QueryItemDisplayScale = @"ds";
QueryItem const QueryItemHorizontalSizeClass = @"hsc";
QueryItem const QueryItemUserInterfaceIdiom = @"uii";
QueryItem const QueryItemVerticalSizeClass = @"vsc";
QueryItem const QueryItemForceTouchCapability = @"ftc";
QueryItem const QueryItemDisplayGamut = @"dg";
QueryItem const QueryItemLayoutDirection = @"ld";
QueryItem const QueryItemPreferredContentSizeCategory = @"pcsc";
QueryItem const QueryItemUserInterfaceStyle = @"uis";
QueryItem const QueryItemIdentifier = @"id";

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

UIEdgeInsets UIEdgeInsetsInvert(UIEdgeInsets insets) {
    insets.top = -insets.top;
    insets.left = -insets.left;
    insets.bottom = -insets.bottom;
    insets.right = -insets.right;
    return insets;
}

CGRect UIEdgeInsetsOutsetRect(CGRect rect, UIEdgeInsets insets) {
    insets = UIEdgeInsetsInvert(insets);
    rect = UIEdgeInsetsInsetRect(rect, insets);
    return rect;
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
        component = [NSBundle.mainBundle localizedStringForKey:component value:component table:TableLocalizable];
        [components addObject:component];
    }
    
    NSString *EE = [components componentsJoinedByString:separator];
    EE = [NSBundle.mainBundle localizedStringForKey:EE value:EE table:TableLocalizable];
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










@interface WeakArray ()

@property NSPointerArray *pointers;

@end



@implementation WeakArray

- (instancetype)init {
    self = super.init;
    if (self) {
        self.pointers = NSPointerArray.weakObjectsPointerArray;
    }
    return self;
}

#pragma mark - Array

- (NSUInteger)count {
    [self.pointers compact];
    
    NSUInteger count = self.pointers.count;
    return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    [self.pointers compact];
    
    id object = [self.pointers pointerAtIndex:index];
    return object;
}

#pragma mark - Mutable array

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self.pointers compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.pointers insertPointer:pointer atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.pointers compact];
    
    [self.pointers removePointerAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self.pointers compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.pointers addPointer:pointer];
}

- (void)removeLastObject {
    [self.pointers compact];
    
    NSUInteger index = self.pointers.count - 1;
    [self.pointers removePointerAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.pointers compact];
    
    void *pointer = (__bridge void *)anObject;
    [self.pointers replacePointerAtIndex:index withPointer:pointer];
}

@end










@interface SurrogateArray ()

@property id lastReturnValue;

@end



@implementation SurrogateArray

#pragma mark - Message forwarding

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    self.lastReturnValue = nil;
    for (id object in self) {
        if ([object respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:object];
            self.lastReturnValue = anInvocation.returnValue;
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        for (id object in self) {
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
    
    for (id object in self) {
        if ([object respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return NO;
}

@end










static void Callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);



@interface Reachability ()

@property SCNetworkReachabilityRef target;
@property ReachabilityStatus status;

@end



@implementation Reachability

+ (instancetype)reachability {
    static Reachability *reachability = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reachability = [self.alloc initWithHost:nil];
    });
    return reachability;
}

- (instancetype)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        if (!host) host = @"0.0.0.0";
        self.target = SCNetworkReachabilityCreateWithName(NULL, host.UTF8String);
        SCNetworkReachabilityScheduleWithRunLoop(self.target, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        SCNetworkReachabilityContext ctx;
        ctx.version = 0;
        ctx.info = (__bridge void *)(self);
        ctx.retain = NULL;
        ctx.release = NULL;
        ctx.copyDescription = NULL;
        SCNetworkReachabilitySetCallback(self.target, Callback, &ctx);
        
        SCNetworkReachabilityFlags flags;
        SCNetworkReachabilityGetFlags(self.target, &flags);
        self.status = [self statusForFlags:flags];
    }
    return self;
}

- (void)dealloc {
    SCNetworkReachabilitySetCallback(self.target, NULL, NULL);
    SCNetworkReachabilityUnscheduleFromRunLoop(self.target, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(self.target);
}

#pragma mark - Helpers

- (ReachabilityStatus)statusForFlags:(SCNetworkReachabilityFlags)flags {
    
    ReachabilityStatus status = ReachabilityStatusNone;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired) && !(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            status = ReachabilityStatusWWAN;
        } else {
            status = ReachabilityStatusWiFi;
        }
    }
    
    return status;
}

@end



static void Callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    Reachability *reachability = (__bridge Reachability *)info;
    ReachabilityStatus status = [reachability statusForFlags:flags];
    if (status != reachability.status) {
        reachability.status = status;
        [reachability invokeHandler:reachability.handler object:reachability];
    }
}










@interface StreamPair ()

@property NSString *host;
@property NSUInteger port;

@property SurrogateArray<NSInputStreamDelegate> *inputStreamDelegates;
@property SurrogateArray<NSOutputStreamDelegate> *outputStreamDelegates;

@end



@implementation StreamPair

- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port {
    self = super.init;
    if (self) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, (UInt32)port, &readStream, &writeStream);
        self.host = host;
        self.port = port;
        self.inputStream = (__bridge_transfer NSInputStream *)readStream;
        self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        
        self.inputStreamDelegates = (id)SurrogateArray.new;
        [self.inputStreamDelegates addObject:self];
        self.inputStream.delegate = self.inputStreamDelegates;
        
        self.outputStreamDelegates = (id)SurrogateArray.new;
        [self.outputStreamDelegates addObject:self];
        self.outputStream.delegate = self.outputStreamDelegates;
    }
    return self;
}

- (void)dealloc {
    self.inputStream = nil;
    self.outputStream = nil;
}

#pragma mark - Accessors

- (void)setInputStream:(NSInputStream *)inputStream {
    if (inputStream) {
        [self createStream:inputStream];
    } else {
        [self disposeStream:self.inputStream];
    }
    
    _inputStream = inputStream;
}

- (void)setOutputStream:(NSOutputStream *)outputStream {
    if (outputStream) {
        [self createStream:outputStream];
    } else {
        [self disposeStream:self.outputStream];
    }
    
    _outputStream = outputStream;
}

#pragma mark - Stream

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if ([aStream isEqual:self.inputStream]) {
        
        if (eventCode == NSStreamEventOpenCompleted) {
            [self.inputStreamDelegates inputStreamOpenCompleted:self.inputStream];
        } else if (eventCode == NSStreamEventHasBytesAvailable) {
            [self.inputStreamDelegates inputStreamHasBytesAvailable:self.inputStream];
        } else if (eventCode == NSStreamEventEndEncountered) {
            [self.inputStreamDelegates inputStreamEndEncountered:self.inputStream];
        } else if (eventCode == NSStreamEventErrorOccurred) {
            [self.inputStreamDelegates inputStreamErrorOccurred:self.inputStream];
        }
        
    } else if ([aStream isEqual:self.outputStream]) {
        
        if (eventCode == NSStreamEventOpenCompleted) {
            [self.outputStreamDelegates outputStreamOpenCompleted:self.outputStream];
        } else if (eventCode == NSStreamEventHasSpaceAvailable) {
            [self.outputStreamDelegates outputStreamHasSpaceAvailable:self.outputStream];
        } else if (eventCode == NSStreamEventEndEncountered) {
            [self.outputStreamDelegates outputStreamEndEncountered:self.outputStream];
        } else if (eventCode == NSStreamEventErrorOccurred) {
            [self.outputStreamDelegates outputStreamErrorOccurred:self.outputStream];
        }
        
    }
}

#pragma mark - Input stream

- (void)inputStreamOpenCompleted:(NSInputStream *)inputStream {
    _inputStreamData = [NSMutableData data];
}

- (void)inputStreamHasBytesAvailable:(NSInputStream *)inputStream {
    uint8_t buffer[1024];
    NSInteger length = [self.inputStream read:buffer maxLength:1024];
    if (length > 0) {
        [_inputStreamData appendBytes:(const void *)buffer length:length];
        if (!self.inputStream.hasBytesAvailable) {
            [self inputStream:self.inputStream didReceiveData:_inputStreamData.copy];
            _inputStreamData.length = 0;
        }
    } else if (length == 0) {
        
    } else {
        
    }
}

- (void)inputStreamErrorOccurred:(NSInputStream *)inputStream {
    self.inputStream = nil;
}

- (void)inputStreamEndEncountered:(NSInputStream *)inputStream {
    self.inputStream = nil;
}

- (void)inputStream:(NSInputStream *)inputStream didReceiveData:(NSData *)data {
}

#pragma mark - Output stream

- (void)outputStreamOpenCompleted:(NSOutputStream *)outputStream {
}

- (void)outputStreamHasSpaceAvailable:(NSOutputStream *)outputStream {
}

- (void)outputStreamErrorOccurred:(NSOutputStream *)outputStream {
    self.outputStream = nil;
}

- (void)outputStreamEndEncountered:(NSOutputStream *)outputStream {
    self.outputStream = nil;
}

#pragma mark - Helpers

- (void)createStream:(NSStream *)stream {
    [stream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
    [stream open];
}

- (void)disposeStream:(NSStream *)stream {
    [stream close];
    [stream removeFromRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
}

@end










@interface View ()

@end



@implementation View

@end










@interface ImageView ()

@end



@implementation ImageView

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.backgroundColor = highlighted ? self.highlightedBackgroundColor : self.defaultBackgroundColor;
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
    
    if (textField.pattern) {
        NSRange range = [text rangeOfString:textField.pattern options:NSRegularExpressionSearch];
        if (range.location == NSNotFound) {
            text = textField.text;
        }
    }
    
    textField.text = text;
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return NO;
}

@end










@interface TextField ()

@property TextFieldDelegate *textFieldDelegate;
@property SurrogateArray<UITextFieldDelegate> *delegates;

@end



@implementation TextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.textFieldDelegate = TextFieldDelegate.new;
        super.delegate = self.textFieldDelegate;
    }
    return self;
}

#pragma mark - Accessors

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    if (delegate) {
        self.delegates = (id)SurrogateArray.new;
        [self.delegates addObject:delegate];
        [self.delegates addObject:self.textFieldDelegate];
        [super setDelegate:self.delegates];
    } else {
        [super setDelegate:delegate];
    }
}

- (void)setRightView:(UIButton *)btnEye {
    [super setRightView:btnEye];
    if (self.secureTextEntry) {
        [btnEye addTarget:self action:@selector(onEye:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Actions

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
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willChangeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        UITapGestureRecognizer *tgr = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTap:)];
        tgr.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tgr];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
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

#pragma mark - Accessors

- (void)setFillColor:(UIColor *)fillColor {
    self.layer.fillColor = fillColor.CGColor;
}

- (UIColor *)fillColor {
    UIColor *color = [UIColor colorWithCGColor:self.layer.fillColor];
    return color;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.layer.strokeColor = strokeColor.CGColor;
}

- (UIColor *)strokeColor {
    UIColor *color = [UIColor colorWithCGColor:self.layer.strokeColor];
    return color;
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










@interface AlertAction ()

@property NSInteger tag;

@end



@implementation AlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style delegate:(id<ActionDelegate>)delegate tag:(NSInteger)tag {
    AlertAction *action = [self actionWithTitle:title style:style handler:^(UIAlertAction *action) {
        AlertAction *a = (AlertAction *)action;
        [delegate didHandleAction:a];
    }];
    action.tag = tag;
    return action;
}

@end



@interface PreviewAction ()

@property NSInteger tag;
@property UIViewController *previewViewController;

@end



@implementation PreviewAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIPreviewActionStyle)style delegate:(id<ActionDelegate>)delegate tag:(NSInteger)tag {
    PreviewAction *action = [self actionWithTitle:title style:style handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
        PreviewAction *a = (PreviewAction *)action;
        a.previewViewController = previewViewController;
        [delegate didHandleAction:a];
    }];
    action.tag = tag;
    return action;
}

@end



@interface TableViewRowAction ()

@property NSInteger tag;
@property NSIndexPath *indexPath;

@end



@implementation TableViewRowAction

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style title:(NSString *)title delegate:(id<ActionDelegate>)delegate tag:(NSInteger)tag {
    TableViewRowAction *action = [self rowActionWithStyle:style title:title handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        TableViewRowAction *a = (TableViewRowAction *)action;
        a.indexPath = indexPath;
        [delegate didHandleAction:a];
    }];
    action.tag = tag;
    return action;
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

+ (UIColor *)colorWithColors:(NSArray<UIColor *> *)colors {
    UIColor *color;
    
    CGFloat red, green, blue, alpha;
    CGFloat r, g, b, a;
    
    r = g = b = a = 0.0;
    for (color in colors) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        r += red;
        g += green;
        b += blue;
        a += alpha;
    }
    
    r /= colors.count;
    g /= colors.count;
    b /= colors.count;
    a /= colors.count;
    
    color = [UIColor colorWithRed:r green:g blue:b alpha:a];
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

+ (instancetype)objectWithComponents:(NSURLComponents *)components {
    Class class = NSClassFromString(components.host);
    id object = [class new];
    [object setValuesForKeyPathsWithDictionary:components.queryDictionary];
    return object;
}

- (void)setValuesForKeyPathsWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    for (NSString *keyPath in keyedValues.allKeys) {
        id value = keyedValues[keyPath];
        [self setValue:value forKeyPath:keyPath];
    }
}

- (NSDictionary<NSString *,id> *)dictionaryWithValuesForKeyPaths:(NSArray<NSString *> *)keyPaths {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *keyPath in keyPaths) {
        dictionary[keyPath] = [self valueForKeyPath:keyPath];
    }
    return dictionary;
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

+ (void)invokeHandler:(ObjectBlock)handler object:(id)object {
    if (handler) {
        handler(object);
    }
}

- (void)invokeHandler:(ObjectBlock)handler object:(id)object {
    [self.class invokeHandler:handler object:object];
}

+ (void)setPointer:(id *)pointer toObject:(id)object {
    if (pointer) {
        *pointer = object;
    }
}

- (void)setPointer:(id *)pointer toObject:(id)object {
    [self.class setPointer:pointer toObject:object];
}

#pragma mark - Swizzling

+ (void)load {
    SEL original = @selector(setValue:forKeyPath:);
    SEL swizzled = @selector(Helpers_NSObject_swizzledSetValue:forKeyPath:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(setValue:forKey:);
    swizzled = @selector(Helpers_NSObject_swizzledSetValue:forKey:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(awakeFromNib);
    swizzled = @selector(Helpers_NSObject_swizzledAwakeFromNib);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (void)Helpers_NSObject_swizzledSetValue:(id)value forKeyPath:(NSString *)keyPath {
    if ([keyPath containsString:@"://"]) {
        NSURLComponents *components = [NSURLComponents componentsWithString:keyPath];
        
        keyPath = components.host;
        
        NSMutableDictionary *queryDictionary = components.queryDictionary.mutableCopy;
        NSString *sg = queryDictionary[SchemeSegue];
        NSNumber *kp = queryDictionary[SchemeKeyPath];
        if (sg.length > 0) {
            NSURLComponents *newComponents = components.copy;
            newComponents.scheme = SchemeSegue;
            queryDictionary[QueryItemIdentifier] = queryDictionary[SchemeSegue];
            queryDictionary[SchemeSegue] = nil;
            newComponents.queryDictionary = queryDictionary;
            keyPath = newComponents.string;
        } else if (kp.boolValue) {
            NSURLComponents *newComponents = components.copy;
            newComponents.scheme = SchemeKeyPath;
            queryDictionary[SchemeKeyPath] = nil;
            newComponents.queryDictionary = queryDictionary;
            keyPath = newComponents.string;
        }
        
        if ([components.scheme isEqualToString:SchemeTraitCollection]) {
            UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithQueryItems:components.queryItems];
            self.kvs[SchemeTraitCollection][traitCollection][keyPath] = value;
        } else if ([components.scheme isEqualToString:SchemeSegue]) {
            NSString *identifier = components.queryDictionary[QueryItemIdentifier];
            self.kvs[SchemeSegue][identifier][keyPath] = value;
        } else if ([components.scheme isEqualToString:SchemeKeyPath]) {
            value = [self valueForKeyPath:value];
            [self Helpers_NSObject_swizzledSetValue:value forKeyPath:keyPath];
        }
    } else {
        [self Helpers_NSObject_swizzledSetValue:value forKeyPath:keyPath];
    }
}

- (void)Helpers_NSObject_swizzledSetValue:(id)value forKey:(NSString *)key {
    [self Helpers_NSObject_swizzledSetValue:value forKey:key];
}

- (void)Helpers_NSObject_swizzledAwakeFromNib {
    [self Helpers_NSObject_swizzledAwakeFromNib];
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
    SEL swizzled = @selector(Helpers_NSDictionary_swizzledObjectForKeyedSubscript:);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (id)Helpers_NSDictionary_swizzledObjectForKeyedSubscript:(id)key {
    id object = [self Helpers_NSDictionary_swizzledObjectForKeyedSubscript:key];
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
    df.locale = [NSLocale localeWithLocaleIdentifier:LocaleIdentifierPosix];
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










@interface UIViewController (HelpersSelectors)

@property (weak) UIViewController *appearanceViewController;

@end



@implementation UIViewController (Helpers)

#pragma mark - Swizzling

+ (void)load {
    SEL original = @selector(supportedInterfaceOrientations);
    SEL swizzled = @selector(Helpers_UIViewController_swizzledSupportedInterfaceOrientations);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(previewActionItems);
    swizzled = @selector(Helpers_UIViewController_swizzledPreviewActionItems);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(setEditing:animated:);
    swizzled = @selector(Helpers_UIViewController_swizzledSetEditing:animated:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(prepareForSegue:sender:);
    swizzled = @selector(Helpers_UIViewController_swizzledPrepareForSegue:sender:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(traitCollectionDidChange:);
    swizzled = @selector(Helpers_UIViewController_swizzledTraitCollectionDidChange:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(initWithCoder:);
    swizzled = @selector(initSwizzledWithCoder_Helpers_UIViewController:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(awakeFromNib);
    swizzled = @selector(Helpers_UIViewController_swizzledAwakeFromNib);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(viewDidLoad);
    swizzled = @selector(Helpers_UIViewController_swizzledViewDidLoad);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(viewWillAppear:);
    swizzled = @selector(Helpers_UIViewController_swizzledViewWillAppear:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(viewDidAppear:);
    swizzled = @selector(Helpers_UIViewController_swizzledViewDidAppear:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(viewWillDisappear:);
    swizzled = @selector(Helpers_UIViewController_swizzledViewWillDisappear:);
    [self swizzleInstanceMethod:original with:swizzled];
    
    original = @selector(viewDidDisappear:);
    swizzled = @selector(Helpers_UIViewController_swizzledViewDidDisappear:);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (UIInterfaceOrientationMask)Helpers_UIViewController_swizzledSupportedInterfaceOrientations {
    UIInterfaceOrientationMask orientations;
    NSNumber *object = objc_getAssociatedObject(self, @selector(supportedInterfaceOrientations));
    if (object) {
        orientations = object.unsignedIntegerValue;
    } else {
        orientations = [self Helpers_UIViewController_swizzledSupportedInterfaceOrientations];
    }
    return orientations;
}

- (NSArray<id<UIPreviewActionItem>> *)Helpers_UIViewController_swizzledPreviewActionItems {
    NSArray *items = objc_getAssociatedObject(self, @selector(previewActionItems));
    if (!items) {
        items = [self Helpers_UIViewController_swizzledPreviewActionItems];
    }
    return items;
}

- (void)Helpers_UIViewController_swizzledSetEditing:(BOOL)editing animated:(BOOL)animated {
    [self Helpers_UIViewController_swizzledSetEditing:editing animated:animated];
    
    for (UIViewController *vc in self.childViewControllers) {
        if (vc.editableByParent) {
            [vc setEditing:editing animated:animated];
        }
    }
}

- (void)Helpers_UIViewController_swizzledPrepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self Helpers_UIViewController_swizzledPrepareForSegue:segue sender:sender];
    
    if (segue.identifier.length > 0) {
        NSDictionary *dictionary = self.kvs[SchemeSegue][segue.identifier];
        [segue setValuesForKeyPathsWithDictionary:dictionary];
        
        NSString *key = NSStringFromSelector(@selector(performSegueWithIdentifier:preparation:));
        ObjectBlock preparation = self.kvs[key];
        if ([preparation isKindOfClass:MutableDictionary.class]) {
        } else {
            self.kvs[key] = nil;
            [self invokeHandler:preparation object:segue];
        }
    }
    
    if (!segue.destinationViewController.segueViewController.isViewLoaded) {
        segue.destinationViewController.segueViewController.sourceViewController = segue.sourceViewController;
    }
}

- (void)Helpers_UIViewController_swizzledTraitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self Helpers_UIViewController_swizzledTraitCollectionDidChange:previousTraitCollection];
    
    NSDictionary *keyPathsByTraitCollection = self.kvs[SchemeTraitCollection];
    for (UITraitCollection *traitCollection in keyPathsByTraitCollection.allKeys) {
        if ([self.traitCollection containsTraitsInCollection:traitCollection]) {
            NSDictionary *dictionary = keyPathsByTraitCollection[traitCollection];
            [self setValuesForKeyPathsWithDictionary:dictionary];
        }
    }
}

- (instancetype)initSwizzledWithCoder_Helpers_UIViewController:(NSCoder *)aDecoder {
    self = [self initSwizzledWithCoder_Helpers_UIViewController:aDecoder];
    if (self) {
    }
    return self;
}

- (void)Helpers_UIViewController_swizzledAwakeFromNib {
    [self Helpers_UIViewController_swizzledAwakeFromNib];
}

- (void)Helpers_UIViewController_swizzledViewDidLoad {
    [self Helpers_UIViewController_swizzledViewDidLoad];
    
    self.presentingViewController.presentedViewController.popoverPresentationController.delegate = self;
}

- (void)Helpers_UIViewController_swizzledViewWillAppear:(BOOL)animated {
    [self Helpers_UIViewController_swizzledViewWillAppear:animated];
    
    if (self.invokeAppearanceMethods && (self.sourceViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) && (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)) {
        self.appearanceViewController = self.sourceViewController;
        [self.appearanceViewController viewWillDisappear:animated];
    } else {
        self.appearanceViewController = nil;
    }
}

- (void)Helpers_UIViewController_swizzledViewDidAppear:(BOOL)animated {
    [self Helpers_UIViewController_swizzledViewDidAppear:animated];
    
    [self.appearanceViewController viewDidDisappear:animated];
}

- (void)Helpers_UIViewController_swizzledViewWillDisappear:(BOOL)animated {
    [self Helpers_UIViewController_swizzledViewWillDisappear:animated];
    
    if (self.invokeAppearanceMethods && (self.sourceViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) && (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)) {
        self.appearanceViewController = self.sourceViewController;
        [self.appearanceViewController viewWillAppear:animated];
    } else {
        self.appearanceViewController = nil;
    }
}

- (void)Helpers_UIViewController_swizzledViewDidDisappear:(BOOL)animated {
    [self Helpers_UIViewController_swizzledViewDidDisappear:animated];
    
    [self.appearanceViewController viewDidAppear:animated];
}

#pragma mark - Popover presentation controller

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    BOOL shouldDismiss = YES;
    if (self.popoverDismissSegueIdentifier.length > 0) {
        [self performSegueWithIdentifier:self.popoverDismissSegueIdentifier sender:self];
        shouldDismiss = NO;
    }
    return shouldDismiss;
}

#pragma mark - Accessors

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSNumber *orientationsValue = @(supportedInterfaceOrientations);
    objc_setAssociatedObject(self, @selector(supportedInterfaceOrientations), orientationsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPreviewActionItems:(NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    objc_setAssociatedObject(self, @selector(previewActionItems), previewActionItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEditableByParent:(BOOL)editableByParent {
    NSNumber *object = @(editableByParent);
    objc_setAssociatedObject(self, @selector(editableByParent), object, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)editableByParent {
    NSNumber *object = objc_getAssociatedObject(self, @selector(editableByParent));
    BOOL editableByParent = object.boolValue;
    return editableByParent;
}

- (void)setSegueViewControllerKeyPath:(NSString *)segueViewControllerKeyPath {
    objc_setAssociatedObject(self, @selector(segueViewControllerKeyPath), segueViewControllerKeyPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)segueViewControllerKeyPath {
    return objc_getAssociatedObject(self, @selector(segueViewControllerKeyPath));
}

- (void)setSegueViewController:(UIViewController *)segueViewController {
    objc_setAssociatedObject(self, @selector(segueViewController), segueViewController, OBJC_ASSOCIATION_RETAIN);
}

- (UIViewController *)segueViewController {
    UIViewController *vc = objc_getAssociatedObject(self, @selector(segueViewController));
    if (vc) return vc;
    
    vc = self.segueViewControllerKeyPath ? [self valueForKeyPath:self.segueViewControllerKeyPath] : self;
    return vc;
}

- (void)setPopoverDismissSegueIdentifier:(NSString *)popoverDismissSegueIdentifier {
    objc_setAssociatedObject(self, @selector(popoverDismissSegueIdentifier), popoverDismissSegueIdentifier, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)popoverDismissSegueIdentifier {
    return objc_getAssociatedObject(self, @selector(popoverDismissSegueIdentifier));
}

- (void)setInvokeAppearanceMethods:(BOOL)invokeAppearanceMethods {
    NSNumber *object = @(invokeAppearanceMethods);
    objc_setAssociatedObject(self, @selector(invokeAppearanceMethods), object, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)invokeAppearanceMethods {
    NSNumber *object = objc_getAssociatedObject(self, @selector(invokeAppearanceMethods));
    BOOL invokeAppearanceMethods = object.boolValue;
    return invokeAppearanceMethods;
}

- (void)setSourceViewController:(UIViewController *)sourceViewController {
    objc_setAssociatedObject(self, @selector(sourceViewController), sourceViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)sourceViewController {
    return objc_getAssociatedObject(self, @selector(sourceViewController));
}

- (void)setAppearanceViewController:(UIViewController *)appearanceViewController {
    objc_setAssociatedObject(self, @selector(appearanceViewController), appearanceViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)appearanceViewController {
    return objc_getAssociatedObject(self, @selector(appearanceViewController));
}

#pragma mark - Helpers

- (NSString *)localize:(NSString *)string {
    NSString *notFoundValue = @(NSNotFound).stringValue;
    NSString *table = [self.storyboard valueForKey:@"name"];
    NSString *localizedString = [self.bundle localizedStringForKey:string value:notFoundValue table:table];
    if ([localizedString isEqualToString:notFoundValue]) {
        localizedString = [NSBundle.mainBundle localizedStringForKey:string value:string table:TableLocalizable];
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

- (void)performSegueWithIdentifier:(NSString *)identifier preparation:(StoryboardSegueBlock)preparation {
    NSString *key = NSStringFromSelector(_cmd);
    self.kvs[key] = preparation;
    [self performSegueWithIdentifier:identifier sender:self];
}

#pragma mark - Image picker controller

- (UIAlertController *)alertControllerImagePicker {
    
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

- (NSArray<UITableViewCell *> *)cellsForSection:(NSInteger)section {
    NSMutableArray *cells = [NSMutableArray array];
    
    NSInteger rows = [self numberOfRowsInSection:section];
    for (NSInteger row = 0; row < rows; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (!cell) continue;
        [cells addObject:cell];
    }
    
    return cells;
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    cell.accessoryType = accessoryType;
}

@end










@implementation UICollectionView (Helpers)

- (void)setFlowLayout:(UICollectionViewFlowLayout *)flowLayout {
    self.collectionViewLayout = flowLayout;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    return flowLayout;
}

@end










@implementation UICollectionViewController (Helpers)

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
    
    NSURL *URL = [self URLForResource:TableErrors withExtension:ExtensionPlist];
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
    SEL swizzled = @selector(Helpers_UIView_swizzledIntrinsicContentSize);
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
    NSValue *object = [NSValue valueWithCGSize:intrinsicContentSize];
    objc_setAssociatedObject(self, @selector(intrinsicContentSize), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self invalidateIntrinsicContentSize];
}

- (CGSize)Helpers_UIView_swizzledIntrinsicContentSize {
    CGSize size;
    NSValue *object = objc_getAssociatedObject(self, @selector(intrinsicContentSize));
    if (object) {
        size = object.CGSizeValue;
    } else {
        size = [self Helpers_UIView_swizzledIntrinsicContentSize];
    }
    return size;
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

+ (void)removeSubviews:(NSArray<UIView *> *)views {
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)removeAllSubviews {
    [self.class removeSubviews:self.subviews];
}

@end










@implementation UIStackView (Helpers)

- (NSArray<UIView *> *)visibleArrangedSubviews {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hidden = NO"];
    NSArray *views = [self.arrangedSubviews filteredArrayUsingPredicate:predicate];
    return views;
}

- (void)removeArrangedSubviews:(NSArray<UIView *> *)views {
    for (UIView *view in views) {
        [self removeArrangedSubview:view];
    }
}

- (void)removeAllArrangedSubviews {
    [self removeArrangedSubviews:self.arrangedSubviews];
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
    NSScanner *scanner = [NSScanner scannerWithString:keypath];
    NSInteger index;
    BOOL success = [scanner scanInteger:&index];
    if (!success) return nil;
    
    id object = self[index];
    success = [scanner scanString:@"." intoString:NULL];
    if (success) {
        keypath = [keypath substringFromIndex:scanner.scanLocation];
        object = [object valueForKeyPath:keypath];
    }
    
    return object;
}

@end










@interface NSData (HelpersSelectors)

@property NSString *cachedString;
@property id cachedJSON;
@property UIImage *cachedImage;

@end



@implementation NSData (Helpers)

- (void)setCachedString:(NSString *)cachedString {
    objc_setAssociatedObject(self, @selector(cachedString), cachedString, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)cachedString {
    return objc_getAssociatedObject(self, @selector(cachedString));
}

- (void)setCachedJSON:(id)cachedJSON {
    objc_setAssociatedObject(self, @selector(cachedJSON), cachedJSON, OBJC_ASSOCIATION_RETAIN);
}

- (id)cachedJSON {
    return objc_getAssociatedObject(self, @selector(cachedJSON));
}

- (void)setCachedImage:(UIImage *)cachedImage {
    objc_setAssociatedObject(self, @selector(cachedImage), cachedImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage *)cachedImage {
    return objc_getAssociatedObject(self, @selector(cachedImage));
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

- (id)json {
    if (self.cachedJSON) return self.cachedJSON;
    
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
        self.cachedJSON = json;
        return json;
    } @catch (NSException *exception) {
        return nil;
    }
}

- (UIImage *)image {
    if (self.cachedImage) return self.cachedImage;
    
    CGFloat scale = UIApplication.sharedApplication.keyWindow.screen.scale;
    self.cachedImage = [UIImage imageWithData:self scale:scale];
    return self.cachedImage;
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










@implementation UITraitCollection (Helpers)

+ (instancetype)traitCollectionWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    UITraitCollection *traitCollection;
    
    NSMutableArray *traitCollections = [NSMutableArray array];
    for (NSURLQueryItem *queryItem in queryItems) {
        if ([queryItem.name isEqualToString:QueryItemDisplayScale]) {
            traitCollection = [UITraitCollection traitCollectionWithDisplayScale:queryItem.value.doubleValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemHorizontalSizeClass]) {
            traitCollection = [UITraitCollection traitCollectionWithHorizontalSizeClass:queryItem.value.integerValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemUserInterfaceIdiom]) {
            traitCollection = [UITraitCollection traitCollectionWithUserInterfaceIdiom:queryItem.value.integerValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemVerticalSizeClass]) {
            traitCollection = [UITraitCollection traitCollectionWithVerticalSizeClass:queryItem.value.integerValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemForceTouchCapability]) {
            traitCollection = [UITraitCollection traitCollectionWithForceTouchCapability:queryItem.value.integerValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemDisplayGamut]) {
            traitCollection = [UITraitCollection traitCollectionWithDisplayGamut:queryItem.value.integerValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemLayoutDirection]) {
            traitCollection = [UITraitCollection traitCollectionWithLayoutDirection:queryItem.value.integerValue];
            [traitCollections addObject:traitCollection];
        } else if ([queryItem.name isEqualToString:QueryItemPreferredContentSizeCategory]) {
            traitCollection = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:queryItem.value];
            [traitCollections addObject:traitCollection];
        }
    }
    
    traitCollection = [UITraitCollection traitCollectionWithTraitsFromCollections:traitCollections];
    return traitCollection;
}

@end










@implementation NSURLComponents (Helpers)

- (void)setQueryDictionary:(NSDictionary<NSString *,NSString *> *)queryDictionary {
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *name in queryDictionary.allKeys) {
        NSString *value = queryDictionary[name];
        NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:name value:value];
        [queryItems addObject:queryItem];
    }
    self.queryItems = queryItems;
}

- (NSDictionary<NSString *,NSString *> *)queryDictionary {
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *queryItem in self.queryItems) {
        queryDictionary[queryItem.name] = queryItem.value;
    }
    return queryDictionary;
}

@end










@implementation CAGradientLayer (Helpers)

- (void)setUiColors:(NSArray<UIColor *> *)uiColors {
    NSMutableArray *colors = NSMutableArray.array;
    for (UIColor *uiColor in uiColors) {
        [colors addObject:(id)uiColor.CGColor];
    }
    self.colors = colors;
}

- (NSArray<UIColor *> *)uiColors {
    UIColor *uiColor;
    NSMutableArray *uiColors = NSMutableArray.array;
    for (id color in self.colors) {
        uiColor = [UIColor colorWithCGColor:(CGColorRef)color];
        [uiColors addObject:uiColor];
    }
    return uiColors;
}

@end










@implementation NSInvocation (Helpers)

- (id)returnValue {
    __autoreleasing id value;
    
    if (strcmp(self.methodSignature.methodReturnType, @encode(char)) == 0) {
        char v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(int)) == 0) {
        int v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(short)) == 0) {
        short v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(long)) == 0) {
        long v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(long long)) == 0) {
        long long v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(unsigned char)) == 0) {
        unsigned char v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(unsigned int)) == 0) {
        unsigned int v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(unsigned short)) == 0) {
        unsigned short v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(unsigned long)) == 0) {
        unsigned long v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(unsigned long long)) == 0) {
        unsigned long long v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(float)) == 0) {
        float v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(double)) == 0) {
        double v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(bool)) == 0) {
        bool v;
        [self getReturnValue:&v];
        value = @(v);
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(void)) == 0) {
        value = nil;
    } else if ((strcmp(self.methodSignature.methodReturnType, @encode(id)) == 0) || (strcmp(self.methodSignature.methodReturnType, @encode(Class)) == 0)) {
        [self getReturnValue:&value];
    } else if (strcmp(self.methodSignature.methodReturnType, @encode(SEL)) == 0) {
        SEL v;
        [self getReturnValue:&v];
        value = NSStringFromSelector(v);
    } else {
        void *v = malloc(self.methodSignature.methodReturnLength);
        [self getReturnValue:v];
        value = [NSValue.alloc initWithBytes:v objCType:self.methodSignature.methodReturnType];
    }
    
    return value;
}

@end
