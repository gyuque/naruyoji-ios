#import "FlipsideViewController.h"
#import "DigitArrayView.h"
#import "ResultView.h"
#import "OAAsynchronousDataFetcher.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIAlertViewDelegate>
{
	CFAbsoluteTime originTime;
	DigitArrayView* dClock;
	ResultView* rvPost;
	int dotCount;
	OAAsynchronousDataFetcher* fetcherForPost;
	
	BOOL stopClock;
	IBOutlet UIButton* btnTest;
	IBOutlet UILabel* labelEnd;
}

- (void) ensureViews;
- (void) showFailure;
- (void) showSuccess;
- (IBAction)showInfo:(id)sender;
- (IBAction)didTestTouch:(id)sender;
- (void) readyClock: (id) param;
- (void) tickClock: (id) param;
- (void) showInProgress;
- (void) checkPrevFinished;

@end
