#include <time.h>
#import "MainViewController.h"
#import "TwitterSettings.h"

#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OADataFetcher.h"
#import "YojiSettings.h"

#define POST_DELAY 150
// #define ENABLE_TEST_BUTTON

extern TwitterSettings* twSettings;

@interface MainViewController(Private)
- (void) requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data;
- (void) requestTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error;
@end

@implementation MainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
#ifndef ENABLE_TEST_BUTTON
btnTest.hidden = YES;
#endif
	
	if (!dClock) {
		originTime = CFAbsoluteTimeGetCurrent();
		[self performSelector:@selector(readyClock:) withObject:nil afterDelay:0.05];
	}
	
	[self ensureViews];
	[self checkPrevFinished];
}

- (void) checkPrevFinished
{
	NSInteger tnow = (NSInteger)CFAbsoluteTimeGetCurrent();
	if (tnow <= ([TwitterSettings lastTime] + POST_DELAY)) {
		dClock.hidden = YES;
		rvPost.hidden = YES;
		labelEnd.hidden = NO;
		stopClock = YES;
	}
}

- (void) ensureViews
{
	if (!dClock) {
		dClock = [[[DigitArrayView alloc] initWithFrame: CGRectMake(160-57, 210, 114, 32)] autorelease];
		[[self view] addSubview: dClock];
		[dClock setupClockArray];
		dClock.opaque = NO;		
	}
	
	if (!rvPost) {
		rvPost = [[[ResultView alloc] initWithFrame:CGRectMake(113, 216, 100, 20)] autorelease];
		rvPost.label.textColor = [UIColor whiteColor];
		rvPost.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		[self.view addSubview: rvPost];
		[rvPost clear];
	}
}

- (void) showInProgress
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	CGAffineTransform tr = CGAffineTransformMake(2,0,0,2, 0,0);
	
	rvPost.alpha = 0;
	rvPost.hidden = NO;
	[rvPost showWait: @"送信中..."];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	rvPost.alpha = 1.0;
	dClock.alpha = 0;
	dClock.transform = tr;
	[UIView commitAnimations];	
}

- (void) flipIfNeeded
{
	[twSettings load];
	if (!twSettings.accessToken || !twSettings.accessSecret)
		[self showInfo: nil];
}

- (void) tickClock: (id) param
{
	[self ensureViews];
	
	dotCount = 1 - dotCount;
	time_t t = time(NULL);
	struct tm* lt = localtime(&t);

	if (lt && dClock && dClock.alpha > 0.1 && !dClock.hidden) {
		[dClock setHour: lt->tm_hour min: lt->tm_min sec: lt->tm_sec];
		[dClock showDots: !dotCount];
	}
	
	int sch = [YojiSettings isScheduledTime: t];
	if (sch) {
		NSInteger tnow = (NSInteger)CFAbsoluteTimeGetCurrent();
		if (tnow > ([TwitterSettings lastTime] + POST_DELAY)) {
			[self didTestTouch: nil];
			
			stopClock = YES;
			[TwitterSettings saveLastTime];
		}
	}
	
	if (!stopClock)
		[self performSelector:@selector(tickClock:) withObject:nil afterDelay: 0.5];
}

- (void) readyClock: (id) param
{
	CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
	if ((int) t != (int)originTime) {
		[self performSelector:@selector(tickClock:) withObject:nil afterDelay: 1.1];
		[self flipIfNeeded];
	}
	else {
		[self performSelector:@selector(readyClock:) withObject:nil afterDelay:0.05];
	}
}

- (IBAction)didTestTouch:(id)sender
{
    OAToken* tok = [[[OAToken alloc] init] autorelease];
	[twSettings load];
	tok.key    = twSettings.accessToken;
	tok.secret = twSettings.accessSecret;
	// NSLog(@"%@  %@", tok.secret, tok.key);

	OAMutableURLRequest* req;
	OAConsumer* co = [TwitterSettings appConsumer];
	
	req = [[[OAMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://api.twitter.com/statuses/update.xml"]
										   consumer: co
											  token: tok
											  realm: NULL
								  signatureProvider: nil
											  nonce: [TwitterSettings generateNonce]
										  timestamp: [TwitterSettings generateTimestamp]] autorelease];
	

	[req setHTTPMethod:@"POST"];
	NSArray* prms = [NSArray arrayWithObjects:
					 [[[OARequestParameter alloc] initWithName:@"status" value: @"なるほど四時じゃねーの #4ji"] autorelease],
					 nil];
	[req setParameters: prms];
	
	if (!fetcherForPost) {
		fetcherForPost = [OAAsynchronousDataFetcher alloc];
		[fetcherForPost initWithRequest: req 
							   delegate: self
					  didFinishSelector: @selector(requestTokenTicket:finishedWithData:)
						didFailSelector: @selector(requestTokenTicket:failedWithError:)];
	} else {
		[fetcherForPost renewNonce: [TwitterSettings generateNonce] timestamp: [TwitterSettings generateTimestamp]];
	}

	
	[self showInProgress];
	[fetcherForPost start];
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if (fetcherForPost && fetcherForPost.lastStatus >= 400) {
		[self showFailure];
	} else {
		[self performSelector:@selector(showSuccess) withObject: nil afterDelay: 0.5];
	}
}

- (void) showFailure
{
	[rvPost showFail:@"送信失敗"];
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle: @"失敗しました"  
						   message: @"再送信しますか?"  
						   delegate: nil  
						   cancelButtonTitle: @"キャンセル"
						   otherButtonTitles: @"再送信", nil] autorelease];
	alert.delegate = self;
	[alert show];  
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex) {
		[self didTestTouch:nil];
	}
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error
{
	NSLog(@"%@", [error localizedDescription]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self showFailure];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void) showSuccess
{
	[rvPost showSuccess:@"送信完了"];
	CGRect rc = rvPost.frame;	
	
	labelEnd.hidden = NO;
	labelEnd.alpha = 0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.7];
	rc.origin.y = 200;
	rvPost.frame = rc;
	labelEnd.alpha = 1;
	[UIView commitAnimations];	
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
	BOOL NA_clock = YES;
	BOOL NA_rv = YES;
	for (UIView* v in [self.view subviews]) {
		if (v == dClock) NA_clock = NO;
		else if (v == rvPost) NA_rv = NO;
	}
	
	if (NA_clock) dClock = nil;
	if (NA_rv) rvPost = nil;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	if (fetcherForPost) {
		[fetcherForPost release];
		fetcherForPost = nil;
	}
	
    [super dealloc];
}


@end
