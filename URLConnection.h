//
//  URLConnection.h
//  Helpers
//
//  Created by Dan Kalinin on 4/16/18.
//

#import <Foundation/Foundation.h>
#import "Main.h"

@class URLConnection;










@protocol URLConnectionDelegate

@optional
- (void)URLConnection:(URLConnection *)connection didUpdateURL:(NSURLComponents *)URL;

@end



@interface URLConnection : NSObject <URLConnectionDelegate>

@property NSUInteger URLHistorySize;

@property (readonly) NSMutableArray<NSURLComponents *> *URLs;
@property (readonly) NSMutableArray<Reachability *> *reachabilities;

@property (readonly) NSURLComponents *URL;
@property (readonly) NSMutableArray<NSURLComponents *> *URLHistory;

@end
