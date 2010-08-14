#import "APIResultParser.h"

@implementation APIResultParser

- (id)initWithData: (NSData*) d
{
    if ((self = [super init])) {
		parser = [[NSXMLParser alloc] initWithData: d];
		
		[parser setDelegate:self];  
		[parser setShouldProcessNamespaces: NO];  
		[parser setShouldReportNamespacePrefixes: NO];  
		[parser setShouldResolveExternalEntities: NO];
	
    }
    return self;
}

- (void) parse
{
	[parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"%@", elementName);
}

- (void)dealloc
{
	if (parser) {
		[parser release];
		parser = nil;
	}
	
	[super dealloc];
}
@end
