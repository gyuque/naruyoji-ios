#import <Foundation/Foundation.h>
#import "OAConsumer.h"

@interface TwitterSettings : NSObject
{
	
}

@property (retain, nonatomic) NSString* authToken;
@property (retain, nonatomic) NSString* authSecret;
@property (retain, nonatomic) NSString* accessToken;
@property (retain, nonatomic) NSString* accessSecret;

- (void) load;
- (void) saveAuthToken: (NSString*) tok secret: (NSString*) sec;
- (void) saveAccessToken: (NSString*) tok secret: (NSString*) sec;
+ (OAConsumer*) appConsumer;
+ (NSString*) generateTimestamp;
+ (NSString*) generateNonce;
+ (void) saveLastTime;
+ (NSInteger) lastTime;

@end
