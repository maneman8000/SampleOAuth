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
    [connectionInProgress release];
    [xmlData release];
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

    NSMutableURLRequest *request = [oauth authorizedRequestWithURL:
                                    @"https://picasaweb.google.com/data/feed/api/user/default"];

    // Clear out the existing connection if there is one
    if (connectionInProgress) {
        [connectionInProgress cancel];
        [connectionInProgress release];
    }

    [xmlData release];
    xmlData = [[NSMutableData alloc] init];
    
    // Create and initiate the connection - non-blocking
    connectionInProgress = [[NSURLConnection alloc] initWithRequest:request
                                                           delegate:self
                                                   startImmediately:YES];
}

- (void)oauth2Google:(OAuth2Google*)oauth didFailWithErrorMessage:(NSString*)message {
    [console setText:[NSString stringWithFormat:@"[ERROR]\n%@", message]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [console setText:[[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    int statusCode = [(NSHTTPURLResponse*)response statusCode];
    if (statusCode >= 300) {
        [console setText:[NSString stringWithFormat:@"%@\n\nHTTP error %d",
                          [console text], statusCode]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connectionInProgress release];
    connectionInProgress = nil;
    
    [xmlData release];
    xmlData = nil;
    
    [console setText:[NSString stringWithFormat:@"%@\n\nFetch failed: %@",
                      [console text], [error localizedDescription]]];
}

@end
