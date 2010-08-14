#import "TwitterSettings.h"

@implementation TwitterSettings
@synthesize authToken;
@synthesize authSecret;
@synthesize accessToken;
@synthesize accessSecret;

- (void) load
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	self.authToken  = [defaults stringForKey:@"authToken"];
	self.authSecret = [defaults stringForKey:@"authSecret"];

	self.accessToken  = [defaults stringForKey:@"accessToken"];
	self.accessSecret = [defaults stringForKey:@"accessSecret"];
}

- (void) saveAuthToken: (NSString*) tok secret: (NSString*) sec
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: tok forKey: @"authToken"];
	[defaults setObject: sec forKey: @"authSecret"];
	
	self.authToken  = tok;
	self.authSecret = sec;
}

- (void) saveAccessToken: (NSString*) tok secret: (NSString*) sec
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: tok forKey: @"accessToken"];
	[defaults setObject: sec forKey: @"accessSecret"];
	
	self.accessToken  = tok;
	self.accessSecret = sec;
}

+ (OAConsumer*) appConsumer
{
	return [[[OAConsumer alloc] initWithKey: @"TKg2iqVqlYWwo1bajkZig"
									 secret: @"A1tYcqjQqvSB2NQqlpyrWIA0NivwQJlyUnv2Oq6H8"] autorelease];

}

+ (void) saveLastTime
{
	NSInteger t = (NSInteger)CFAbsoluteTimeGetCurrent();
	[[NSUserDefaults standardUserDefaults] setInteger: t forKey: @"last-post-time"];
}

+ (NSInteger) lastTime
{
	return [[NSUserDefaults standardUserDefaults] integerForKey: @"last-post-time"];
}

+ (NSString*)generateTimestamp 
{
    return [NSString stringWithFormat:@"%d", time(NULL)];
}

+ (NSString*)generateNonce 
{
    CFUUIDRef u = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, u);
	CFRelease(u);
	
    NSString* nonce = (NSString *)string;
	
	[nonce autorelease];
	return nonce;
}

- (void)dealloc
{
	self.authToken  = nil;
	self.authSecret = nil;
	self.accessToken  = nil;
	self.accessSecret = nil;
	
	[super dealloc];
}

@end
