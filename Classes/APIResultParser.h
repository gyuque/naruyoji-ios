#import <Foundation/Foundation.h>

@interface APIResultParser : NSObject<NSXMLParserDelegate>
{
	NSXMLParser* parser;
}

- (void) parse;

@end
