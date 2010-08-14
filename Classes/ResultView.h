#import <UIKit/UIKit.h>

@interface ResultView : UIView
{
	UIActivityIndicatorView* spinner;
	UIImageView* iconView;
	UILabel* label;
}
@property (nonatomic, readonly) UILabel* label;
@property (nonatomic, readonly) UIActivityIndicatorView* spinner;

- (void) clear;
- (void) showWait: (NSString*) msg;
- (void) showSuccess: (NSString*) msg;
- (void) showFail: (NSString*) msg;

@end
