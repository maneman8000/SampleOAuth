//
//  OAuth2Google.m
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuth2Google.h"
#import "JsonParser.h"

#define REDIRECT_URI @"urn:ietf:wg:oauth:2.0:oob"

// utility function
NSString* encodeURIComponent(NSString* s) {
    return [((NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)s,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8)) autorelease];
}

@implementation OAuth2Google
@synthesize delegate;

- (id)initWithScope:scp clientId:(NSString *)cid clientSecret:(NSString*)csecret {
    if ((self = [super init]) != nil) {
        scope = [[NSString alloc] initWithString:scp];
        clientId = [[NSString alloc] initWithString:cid];
        clientSecret = [[NSString alloc] initWithString:csecret];
    }
    return self;
}

- (void)dealloc {
    [scope release];
    [clientId release];
    [clientSecret release];
    [accessToken release];
    [connectionInProgress release];
    [jsonData release];
    [super dealloc];
}

- (BOOL)authorized {
    return accessToken ? YES : NO;
}

- (NSURL*)authorizationURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&scope=%@&redirect_uri=%@",
             encodeURIComponent(clientId),
             encodeURIComponent(scope),
             encodeURIComponent(REDIRECT_URI)]];
}

- (void)requestAccessTokenWithAuthorizationCode:(NSString*)code {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/accounts/o8/oauth2/token"]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"www.google.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[NSString stringWithFormat:
                           @"grant_type=authorization_code&client_id=%@&client_secret=%@&code=%@&redirect_uri=%@",
                           encodeURIComponent(clientId),
                           encodeURIComponent(clientSecret),
                           encodeURIComponent(code),
                           encodeURIComponent(REDIRECT_URI)] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Clear out the existing connection if there is one
    if (connectionInProgress) {
        [connectionInProgress cancel];
        [connectionInProgress release];
    }

    [jsonData release];
    jsonData = [[NSMutableData alloc] init];
    
    // Create and initiate the connection - non-blocking
    connectionInProgress = [[NSURLConnection alloc] initWithRequest:request
                                                           delegate:self
                                                   startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [jsonData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (![delegate respondsToSelector:@selector(oauth2Google:didReceiveAccessToken:)]) return;
    NSString* t = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"received %@", t);

    JsonParser *parser = [[JsonParser alloc] init];
    NSMutableDictionary *parsedJson = [parser
                                       parseFromString:[[[NSString alloc] initWithData:jsonData
                                                                              encoding:NSUTF8StringEncoding] autorelease]];
    if (!parsedJson) {
        if ([delegate respondsToSelector:@selector(oauth2Google:didFailWithErrorMessage:)]) {
            [delegate oauth2Google:self didFailWithErrorMessage:@"JSON parse error!"];
        }
        return;
    }
    accessToken = [[parsedJson objectForKey:@"access_token"] retain];
    NSLog(@"access token %@", accessToken);
    [parser release];
    if (!accessToken) {
        if ([delegate respondsToSelector:@selector(oauth2Google:didFailWithErrorMessage:)]) {
            [delegate oauth2Google:self didFailWithErrorMessage:@"can't get access_token"];
        }
        return;
    }
    [delegate oauth2Google:self didReceiveAccessToken:accessToken];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    int statusCode = [(NSHTTPURLResponse*)response statusCode];
    if (statusCode >= 300
        && [delegate respondsToSelector:@selector(oauth2Google:didFailWithErrorMessage:)]) {
        [delegate oauth2Google:self
       didFailWithErrorMessage:[NSString stringWithFormat:@"HTTP error %d", statusCode]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connectionInProgress release];
    connectionInProgress = nil;
    
    [jsonData release];
    jsonData = nil;
    
    if ([delegate respondsToSelector:@selector(oauth2Google:didFailWithErrorMessage:)]) {
        [delegate oauth2Google:self
       didFailWithErrorMessage:[NSString stringWithFormat:@"Fetch failed: %@",
                                [error localizedDescription]]];
    }
}

- (NSMutableURLRequest*)authorizedRequestWithURL {
    return nil;
}

@end
