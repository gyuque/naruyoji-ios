#import <UIKit/UIKit.h>
#import "OAAsynchronousDataFetcher.h"
#import "ResultView.h"

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController<UIActionSheetDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UITextField* txVeriCode;
	IBOutlet UIButton* btnVeriCode;
	IBOutlet UILabel* labelReady;
	IBOutlet UILabel* labelVeriCode;
	IBOutlet UILabel* labelInstruction;
	IBOutlet UIButton* btnOAuthStart;
	IBOutlet UIButton* btnAPITest;
	IBOutlet UIButton* btnReset;
	IBOutlet UITextView* txAbout;
	ResultView* rvAPITest;
	
	OAAsynchronousDataFetcher* fetcherForTest;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done: (id)sender;
- (IBAction)didSetupTouch: (id)sender;
- (IBAction)didAPITestTouch: (id)sender;
- (IBAction)didAuthResetTouch: (id)sender;
- (IBAction)didVerifyTouch: (id)sender;

- (void) showVerifyField: (BOOL)b;
- (void) showTestField: (BOOL)b;
- (void) toggleVisibility;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

