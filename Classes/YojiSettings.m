#import "YojiSettings.h"

@implementation YojiSettings
+ (int) isScheduledTime: (time_t) t
{
	struct tm* lt = localtime(&t);
	if (lt) {
		if (lt->tm_hour == 4 && lt->tm_min == 0)
			return 1;
	}

	return 0;
}

@end
