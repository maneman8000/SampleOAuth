//
//  MainViewController.h
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthorizationPageController.h"

@class OAuth2Google;

@interface MainViewController : UIViewController <AuthorizationPageControllerDelegate> {
    UITextView *console;
    OAuth2Google *oauth;
    AuthorizationPageController * authorizationPageController;
}
@property (nonatomic, retain) IBOutlet UITextView *console;

@end
