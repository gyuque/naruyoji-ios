//
//  ResultView.m
//  naruyoji
//
//  Created by 荒川 智則 on 10/08/12.
//  Copyright 2010 Tomonori Arakawa. All rights reserved.
//

#import "ResultView.h"
#define FIXHEIGHT 20

@implementation ResultView
@synthesize label;
@synthesize spinner;

- (id)initWithFrame:(CGRect)frame {
	frame.size.height = FIXHEIGHT;
    if ((self = [super initWithFrame:frame])) {
        spinner  = [[[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)] autorelease];
		label    = [[[UILabel alloc] initWithFrame: CGRectMake(22, 0, frame.size.width-22, FIXHEIGHT)] autorelease];
		iconView = [[[UIImageView alloc] initWithFrame: CGRectMake(2, 2, 16, 16)] autorelease];
		label.opaque = NO;
		label.backgroundColor = nil;
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[spinner setHidesWhenStopped:YES];
		
		[self addSubview: spinner];
		[self addSubview: label];
		[self addSubview: iconView];
		
		[self clear];
    }
    return self;
}

- (void) clear
{
	[spinner stopAnimating];
	label.hidden = YES;
	iconView.hidden = YES;
}

- (void) showWait: (NSString*) msg
{
	[spinner startAnimating];
	iconView.hidden = YES;
	label.text = msg;
	label.hidden = NO;
}

- (void) showSuccess: (NSString*) msg
{
	[spinner stopAnimating];
	iconView.hidden = NO;
	iconView.image = [UIImage imageNamed:@"isuc.png"];
	label.text = msg;
	label.hidden = NO;
}

- (void) showFail: (NSString*) msg
{
	[spinner stopAnimating];
	iconView.hidden = NO;
	iconView.image = [UIImage imageNamed:@"ifail.png"];
	label.text = msg;
	label.hidden = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
