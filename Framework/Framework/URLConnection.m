//
//  URLConnection.m
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import "URLConnection.h"










@interface URLConnection ()

@property NSMutableArray<NSURLComponents *> *URLs;
@property NSMutableArray<Reachability *> *reachabilities;

@property NSMutableArray<NSURLComponents *> *URLHistory;

@end



@implementation URLConnection

- (instancetype)init {
    self = super.init;
    if (self) {
        self.URLHistorySize = 10;
        
        self.URLs = NSMutableArray.array;
        self.reachabilities = NSMutableArray.array;
        
        self.URLHistory = NSMutableArray.array;
    }
    return self;
}

- (NSURLComponents *)URL {
    return nil;
}

@end
