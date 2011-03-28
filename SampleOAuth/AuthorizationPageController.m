//
//  AuthorizationPageController.m
//  SampleOAuth
//
//  Created by 西谷 明洋 on 11/03/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AuthorizationPageController.h"


@implementation AuthorizationPageController
@synthesize webView, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)aURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        authURL = [aURL retain];
    }
    return self;
}

- (void)dealloc
{
    [webView release];
    [authURL release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    webView.delegate = self;
    
    [webView loadRequest:[NSURLRequest requestWithURL:authURL]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [webView release];
    webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([title hasPrefix:@"Success code"]) {
        if ([delegate respondsToSelector:@selector(authorizationPageController:didFinishUserAuthorize:)]) {
            NSRange range = [title rangeOfString:@"="];
            [delegate authorizationPageController:self
                           didFinishUserAuthorize:[title substringFromIndex:range.location+1]];
        }
        [self dismissModalViewControllerAnimated:YES];
    }
    else if ([title hasPrefix:@"Denied"]) {
        [self dismissModalViewControllerAnimated:YES];
    }
}


@end
