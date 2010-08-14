#import "DigitView.h"

#define DG_WIDTH 16
#define DG_HEIGHT 32

@implementation DigitView


- (id)init
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, DG_WIDTH, DG_HEIGHT)]))
	{
		self.opaque = NO;
    }
    return self;
}

- (void) setSpriteIndex: (int) i
{
	spriteIndex = i;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	UIImage* img = [UIImage imageNamed:@"7seg.png"];

	CGRect rc = self.frame;
	rc.origin.y = 0;
	rc.origin.x = spriteIndex * -(DG_WIDTH/2);
	rc.size.width = DG_WIDTH * 14;
	
	
	CGContextRef cg = UIGraphicsGetCurrentContext();
	CGContextDrawImage (cg, rc, [img CGImage]);
}

- (void)dealloc {
    [super dealloc];
}


@end
