#import <UIKit/UIKit.h>
#import "DigitView.h"

@interface DigitArrayView : UIView
{
	NSMutableArray* digits;
	int rightX;
}

- (void) setupClockArray;
- (DigitView*) appendDigit: (BOOL) halfWidth;
- (void) ensureList;
- (void) setHour: (int) h min: (int) m sec: (int) s;
- (void) showDots: (BOOL) b;

@end
