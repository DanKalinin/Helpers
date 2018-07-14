//
//  HLPURL.m
//  Helpers
//
//  Created by Dan Kalinin on 5/22/18.
//

#import "HLPURL.h"










@interface HLPURLComponents ()

@end



@implementation HLPURLComponents

@end










@implementation NSURL (HLP)

@end










@implementation NSURLComponents (HLP)

- (void)setAddress:(struct sockaddr)address {
    if (address.sa_family == AF_INET) {
        struct sockaddr_in address4 = *(struct sockaddr_in *)&address;
        self.host = @(inet_ntoa(address4.sin_addr));
        self.port = @(ntohs(address4.sin_port));
    } else {
        struct sockaddr_in6 address6 = *(struct sockaddr_in6 *)&address;
        char host[INET6_ADDRSTRLEN];
        self.host = @(inet_ntop(AF_INET6, &address6.sin6_addr, host, INET6_ADDRSTRLEN));
        self.port = @(ntohs(address6.sin6_port));
    }
}

- (struct sockaddr)address {
    if ([self.host containsString:@"."]) {
        struct sockaddr_in address4 = {0};
        inet_aton(self.host.UTF8String, &address4.sin_addr);
        address4.sin_port = self.port.unsignedShortValue;
        address4.sin_len = sizeof(address4);
        address4.sin_family = AF_INET;
        return *(struct sockaddr *)&address4;
    } else {
        struct sockaddr_in6 address6 = {0};
        inet_pton(AF_INET6, self.host.UTF8String, &address6.sin6_addr);
        address6.sin6_port = self.port.unsignedShortValue;
        address6.sin6_len = sizeof(address6);
        address6.sin6_family = AF_INET6;
        return *(struct sockaddr *)&address6;
    }
}

@end
