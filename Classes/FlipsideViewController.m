#import "FlipsideViewController.h"
#import "TwitterSettings.h"

#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OADataFetcher.h"
#import "APIResultParser.h"

@interface FlipsideViewController(Private)
- (void) requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data;
- (void) requestTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error;
- (void) accessTokenRequestWithTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data;
- (void) accessTokenRequestWithTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error;

- (void) testRequestWithTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data;
- (void) testRequestWithTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error;

- (void) apitestFailed;
- (BOOL) ensureFetcherForTest;
@end


extern TwitterSettings* twSettings;
@implementation FlipsideViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	[twSettings load];
	[self toggleVisibility];
	
	txAbout.font = [UIFont fontWithName: @"Arial" size: 12];
	txAbout.text = @"なるほど四時じゃねーの for iPhone\n(C) 2010 Arakawa Tomonori\n\nOAuth Library\nCopyright 2007 Kaboomerang LLC. All rights reserved.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
	
	if (!rvAPITest) {
		rvAPITest = [[[ResultView alloc] initWithFrame:CGRectMake(65, 123, 190, 20)] autorelease];
		[self.view addSubview: rvAPITest];
		[rvAPITest.label setFont: [UIFont fontWithName: @"Arial" size: 14]];
	}
}

- (void) toggleVisibility
{
	[twSettings load];
	if (twSettings.accessToken && twSettings.accessSecret) {
		labelReady.hidden = NO;
		labelInstruction.hidden = YES;
		btnOAuthStart.hidden = YES;
		[self showVerifyField: NO];
		[self showTestField: YES];
	} else if (twSettings.authToken && twSettings.authSecret) {
		labelReady.hidden = YES;
		labelInstruction.hidden = YES;
		btnOAuthStart.hidden = NO;
		[self showVerifyField: YES];
		[self showTestField: NO];
	} else {
		labelReady.hidden = YES;
		labelInstruction.hidden = NO;
		btnOAuthStart.hidden = NO;
		[self showVerifyField: NO];		
		[self showTestField: NO];
	}

}

- (void) showVerifyField: (BOOL)b
{
	[txVeriCode setHidden: !b];
	[btnVeriCode setHidden: !b];
	[labelVeriCode setHidden: !b];
}

- (void) showTestField: (BOOL)b
{
	[rvAPITest setHidden: !b];
	[btnReset setHidden: !b];
	[btnAPITest setHidden: !b];
}

- (IBAction)done:(id)sender {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)didSetupTouch: (id)sender
{
	OAConsumer* co = [TwitterSettings appConsumer];
	NSURL *url = [NSURL URLWithString:@"http://twitter.com/oauth/request_token"];
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL: url
                                                                   consumer: co
                                                                      token: NULL
                                                                      realm: NULL
                                                          signatureProvider: nil] autorelease];
	[request setHTTPMethod:@"POST"];

	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest: request 
                         delegate: self
                didFinishSelector: @selector(requestTokenTicket:finishedWithData:)
                  didFailSelector: @selector(requestTokenTicket:failedWithError:)];	
}

- (IBAction) didAPITestTouch: (id)sender
{
	[twSettings load];
	
	if (![self ensureFetcherForTest]) {
		UIAlertView *alert = [[[UIAlertView alloc]
							  initWithTitle: @"リクエスト失敗"  
							  message: @"Access Token がありません"  
							  delegate: nil  
							  cancelButtonTitle: @"了解"
							  otherButtonTitles: nil] autorelease];
							  [alert show];  
		
		return;
	}
	
	[rvAPITest showWait: @"テスト中..."];
	[fetcherForTest renewNonce: [TwitterSettings generateNonce] timestamp: [TwitterSettings generateTimestamp]];
	fetcherForTest.mode = (sender==nil) ? 1 : 0;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[fetcherForTest start];
}

- (IBAction)didAuthResetTouch: (id)sender
{
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle: @"OAuthの設定を削除しますか?"
															 delegate: self 
													cancelButtonTitle: @"キャンセル" 
											   destructiveButtonTitle: @"削除する"
													otherButtonTitles: nil] autorelease];
	/*
	　actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
	
	　[actionSheet showFromToolbar:self.toolBar];
	
	　[actionSheet release];
	*/
	
	[actionSheet showInView: self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[twSettings saveAuthToken: nil secret: nil];
		[twSettings saveAccessToken: nil secret: nil];
		[self toggleVisibility];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data
{
	NSString* responseBody = [[[NSString alloc] initWithData: data
												   encoding: NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", responseBody);

//	OAConsumer* co = [[[OAConsumer alloc] initWithKey: @"TKg2iqVqlYWwo1bajkZig"
//											   secret: @"A1tYcqjQqvSB2NQqlpyrWIA0NivwQJlyUnv2Oq6H8"] autorelease];
    OAToken* tok = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
	[twSettings saveAuthToken: tok.key secret: tok.secret];
	
	NSMutableString* geturl = [NSMutableString stringWithString: @"http://twitter.com/oauth/authorize"];
	[geturl appendFormat: @"?%@", responseBody];
//	NSURLRequest* ureq = [NSURLRequest requestWithURL: [NSURL URLWithString: geturl]];
	
	[self toggleVisibility];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: geturl]];
/*	
	OAMutableURLRequest* req;
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef nstring = CFUUIDCreateString(NULL, uuid);
	
	req = [[[OAMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://twitter.com/oauth/access_token"]
										  consumer: co
											 token: tok
											 realm: NULL
								 signatureProvider: nil
											 nonce: (NSString*)nstring
										 timestamp: [NSString stringWithFormat:@"%d", time(NULL)]] autorelease];
	
	
	
	CFRelease(nstring);
	CFRelease(uuid);
	
	[req setHTTPMethod:@"POST"];
	
	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest: req
                         delegate: self
                didFinishSelector: @selector(accessTokenRequestWithTicket:finishedWithData:)
                  didFailSelector: @selector(accessTokenRequestWithTicket:failedWithError:)];
*/	
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error
{
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle: @"リクエスト失敗"  
						   message: @"Request Token を取得できません"  
						   delegate: nil  
						   cancelButtonTitle: @"了解"
						   otherButtonTitles: nil] autorelease];
	[alert show];  
	
}

- (IBAction)didVerifyTouch: (id)sender
{
	[txVeriCode resignFirstResponder];

	[twSettings load];
	NSString* tkK = twSettings.authToken;
	NSString* tkS = twSettings.authSecret;
	if (!tkK || !tkS)
		return;
	
    OAToken* tok = [[[OAToken alloc] init] autorelease];
	tok.key    = tkK;
	tok.secret = tkS;

	OAMutableURLRequest* req;
	OAConsumer* co = [TwitterSettings appConsumer];
	
	req = [[[OAMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://twitter.com/oauth/access_token"]
										   consumer: co
											  token: tok
											  realm: NULL
								  signatureProvider: nil
											  nonce: [TwitterSettings generateNonce]
										  timestamp: [TwitterSettings generateTimestamp]] autorelease];
	
	
	
	
	[req setHTTPMethod:@"GET"];
	NSArray* prms = [NSArray arrayWithObjects:
												[[[OARequestParameter alloc] initWithName:@"oauth_verifier" value: txVeriCode.text] autorelease],
												nil];
	[req setParameters: prms];
    
	
	
	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest: req
                         delegate: self
                didFinishSelector: @selector(accessTokenRequestWithTicket:finishedWithData:)
                  didFailSelector: @selector(accessTokenRequestWithTicket:failedWithError:)];
	
}

- (void) accessTokenRequestWithTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data
{
	NSString* responseBody = [[[NSString alloc] initWithData: data
													encoding: NSUTF8StringEncoding] autorelease];
	
	/* OAuth setup completed */
	
    OAToken* tok = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
	[twSettings saveAccessToken: tok.key secret: tok.secret];
	[self toggleVisibility];
	[self didAPITestTouch: nil];
}

- (void) accessTokenRequestWithTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error
{
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle: @"認証失敗"  
						   message: @"Access Token を取得できません"  
						   delegate: nil  
						   cancelButtonTitle: @"了解"
						   otherButtonTitles: nil] autorelease];
	[alert show];  
	
	NSLog(@"%@", error);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/* -- response handler for APITest -- */

- (void) testRequestWithTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString* responseBody = [[[NSString alloc] initWithData: data
													encoding: NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", responseBody);
	NSRange r = [responseBody rangeOfString:@"<statuses"];
	if (r.location == NSNotFound) {
		NSLog(@"Bad XML");
		[self apitestFailed];
	} else {
		/*
		APIResultParser* parser = [[APIResultParser alloc] initWithData: data];
		[parser parse];
		[parser release];
		*/
		
		[rvAPITest showSuccess: @"成功しました"];
		
		if (fetcherForTest.mode)
			[self performSelector:@selector(done:) withObject: nil afterDelay: 0.6];
	}

}

- (void) testRequestWithTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self apitestFailed];
}

- (void) apitestFailed
{
	[rvAPITest showFail: @"失敗しました"];
}

- (BOOL) ensureFetcherForTest
{
	if (!fetcherForTest) {
		NSString* tkK = twSettings.accessToken;
		NSString* tkS = twSettings.accessSecret;
		if (!tkK || !tkS)
			return NO;
		
		OAToken* tok = [[[OAToken alloc] init] autorelease];
		tok.key    = tkK;
		tok.secret = tkS;
		
		OAConsumer* co = [TwitterSettings appConsumer];
		
		OAMutableURLRequest* req;
		req = [[[OAMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://api.twitter.com/statuses/home_timeline.xml"]
											   consumer: co
												  token: tok
												  realm: NULL
									  signatureProvider: nil
												  nonce: nil
											  timestamp: nil] autorelease];
		
		[req setHTTPMethod:@"GET"];
	
		OAAsynchronousDataFetcher* f = [[OAAsynchronousDataFetcher alloc] initWithRequest: req
																				 delegate: self
																		didFinishSelector: @selector(testRequestWithTicket:finishedWithData:)
																		  didFailSelector: @selector(testRequestWithTicket:failedWithError:) ];
		
		fetcherForTest = f;
	}
	
	return YES;
}



- (void)dealloc
{
	if (fetcherForTest) {
		[fetcherForTest release];
		fetcherForTest = nil;
	}
	
    [super dealloc];
}


@end
