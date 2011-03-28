//
//  OAuth2Google.m
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuth2Google.h"

// utility function
NSString* encodeURIComponent(NSString* s) {
    return [((NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)s,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8)) autorelease];
}

@implementation OAuth2Google
@synthesize authorized;

- (id)initWithScope:scp clientId:(NSString *)cid clientSecret:(NSString*)csecret {
    if ((self = [super init]) != nil) {
        scope = [[NSString alloc] initWithString:scp];
        clientId = [[NSString alloc] initWithString:cid];
        clientSecret = [[NSString alloc] initWithString:csecret];
        authorized = NO;
    }
    return self;
}

- (void)dealloc {
    [scope release];
    [clientId release];
    [clientSecret release];
    [super dealloc];
}

- (NSURL*)authorizationURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&scope=%@&redirect_uri=%@",
             encodeURIComponent(clientId),
             encodeURIComponent(scope),
             encodeURIComponent(@"urn:ietf:wg:oauth:2.0:oob")]];
}

@end
