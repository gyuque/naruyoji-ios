#import <UIKit/UIKit.h>
#import "TwitterSettings.h"

TwitterSettings* twSettings = nil;

int main(int argc, char *argv[]) {
    twSettings = [[TwitterSettings alloc] init];
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
	
	[twSettings release];
    return retVal;
}
