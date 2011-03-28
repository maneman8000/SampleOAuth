//
//  AuthorizationPageController.h
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AuthorizationPageController;

@protocol AuthorizationPageControllerDelegate <NSObject>

@optional

- (void)authorizationPageController:(AuthorizationPageController *)controller
             didFinishUserAuthorize:(NSString *)code;

@end


@interface AuthorizationPageController : UIViewController <UIWebViewDelegate> {
    id <AuthorizationPageControllerDelegate> delegate;
    UIWebView *webView;
    NSURL *authURL;
}
@property (nonatomic, assign) id <AuthorizationPageControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)aURL;

@end
