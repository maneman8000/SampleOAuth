//
//  MainViewController.m
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "OAuth2Google.h"
#import "OAuth2GoogleClientSecret.h"

@implementation MainViewController
@synthesize console;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        oauth = [[OAuth2Google alloc] initWithScope:@"https://picasaweb.google.com/data"
                                           clientId:GOOGLE_OAUTH2_CLIENT_ID
                                       clientSecret:GOOGLE_OAUTH2_CLIENT_SECRET];
        oauth.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [oauth release];
    [authorizationPageController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    if (![oauth authorized] && !authorizationPageController) {
        authorizationPageController =
        [[AuthorizationPageController alloc]
         initWithNibName:@"AuthorizationPageController"
         bundle:nil url:[oauth authorizationURL]];
        authorizationPageController.delegate = self;
        
        [self presentModalViewController:authorizationPageController animated:YES];        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [console setText:[[oauth authorizationURL] description]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [authorizationPageController release];
    authorizationPageController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)authorizationPageController:(AuthorizationPageController *)controller
             didFinishUserAuthorize:(NSString *)code {
    [console setText:[NSString stringWithFormat:@"request with code : %@", code]];
    [oauth requestAccessTokenWithAuthorizationCode:code];
}

- (void)oauth2Google:(OAuth2Google*)oauth didReceiveAccessToken:(NSString*)token {
    [console setText:[NSString stringWithFormat:@"[SUCCESS]\n%@", token]];
}

- (void)oauth2Google:(OAuth2Google*)oauth didFailWithErrorMessage:(NSString*)message {
    [console setText:[NSString stringWithFormat:@"[ERROR]\n%@", message]];
}


@end
