//
//  MainViewController.h
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthorizationPageController.h"
#import "OAuth2Google.h"

@interface MainViewController : UIViewController <AuthorizationPageControllerDelegate, OAuth2GoogleDelegate> {
    UITextView *console;
    OAuth2Google *oauth;
    AuthorizationPageController * authorizationPageController;
    NSURLConnection *connectionInProgress;
    NSMutableData *xmlData;
}
@property (nonatomic, retain) IBOutlet UITextView *console;

@end
