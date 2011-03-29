//
//  OAuth2Google.h
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OAuth2Google;

@protocol OAuth2GoogleDelegate <NSObject>

@optional

// use for receiving requestAccessTokenWithAuthorizationCode result
- (void)oauth2Google:(OAuth2Google*)oauth didReceiveAccessToken:(NSString*)token;
- (void)oauth2Google:(OAuth2Google*)oauth didFailWithErrorMessage:(NSString*)message;

@end

@interface OAuth2Google : NSObject {
@private
    id <OAuth2GoogleDelegate> delegate;
    NSString *scope;
    NSString *clientId;
    NSString *clientSecret;
    NSString *accessToken;
    NSString *refreshToken;
    NSURLConnection *connectionInProgress;
    NSMutableData *jsonData;
}

@property (nonatomic, assign) id <OAuth2GoogleDelegate> delegate;

- (id)initWithScope:(NSString*)scp clientId:(NSString *)cid clientSecret:(NSString*)csecret;
- (BOOL)authorized;

// get user authorization URL
- (NSURL*)authorizationURL;

// load acess token asynchronously with user authorization code
- (void)requestAccessTokenWithAuthorizationCode:(NSString*)code;

// retun authorized request object, if not authorized return nil
- (NSMutableURLRequest*)authorizedRequestWithURL:(NSString*)urlstr;

@end
