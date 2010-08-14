#import "DigitArrayView.h"

@implementation DigitArrayView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void) ensureList
{
	if (!digits)
		digits = [[NSMutableArray alloc] init];
}

- (void) setupClockArray
{
	[self appendDigit: NO];
	[self appendDigit: NO];
	[[self appendDigit: YES] setSpriteIndex: 25];
	[self appendDigit: NO];
	[self appendDigit: NO];
	[[self appendDigit: YES] setSpriteIndex: 25];
	[self appendDigit: NO];
	[self appendDigit: NO];
}

- (DigitView*) appendDigit: (BOOL) halfWidth
{
	[self ensureList];
	
	DigitView* d = [[[DigitView alloc] init] autorelease];
	[digits addObject: d];
	[self addSubview: d];
	
	CGRect rc = d.frame;
	rc.origin.x = rightX;
	
	if (halfWidth)
		rc.size.width *= 0.5;
	
	rightX += rc.size.width;
	if (halfWidth)
		rightX += 1;
	
	d.frame = rc;
	
	return d;
}

- (void) setHour: (int) h min: (int) m sec: (int) s
{
	if (!digits) return;
	if ([digits count] < 8) return;
	
	[[digits objectAtIndex: 0] setSpriteIndex: 2+((h/10)<<1)];
	[[digits objectAtIndex: 1] setSpriteIndex: 2+((h%10)<<1)];
	[[digits objectAtIndex: 3] setSpriteIndex: 2+((m/10)<<1)];
	[[digits objectAtIndex: 4] setSpriteIndex: 2+((m%10)<<1)];
	[[digits objectAtIndex: 6] setSpriteIndex: 2+((s/10)<<1)];
	[[digits objectAtIndex: 7] setSpriteIndex: 2+((s%10)<<1)];
}

- (void) showDots: (BOOL) b
{
	if (!digits) return;
	if ([digits count] < 8) return;
	
	int i = b?1:0;
	[[digits objectAtIndex: 5] setSpriteIndex: 24+i];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc
{
	if (digits) {
		[digits release];
		digits = nil;
	}
	
    [super dealloc];
}


@end
