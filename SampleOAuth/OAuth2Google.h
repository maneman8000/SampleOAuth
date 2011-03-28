//
//  OAuth2Google.h
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OAuth2Google : NSObject {
    NSString *scope;
    NSString *clientId;
    NSString *clientSecret;
    BOOL authorized;
}
@property (nonatomic, assign, readonly) BOOL authorized;

- (id)initWithScope:(NSString*)scp clientId:(NSString *)cid clientSecret:(NSString*)csecret;
- (BOOL)authorized;
- (NSURL*)authorizationURL;

@end
