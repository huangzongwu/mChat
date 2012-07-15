//
//  ChunkXMLParser.m
//  mChat
//
//  Created by Martin Jahn on 29/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "ChunkXMLParser.h"


static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                          const xmlChar *URI);
static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len);
static void errorEncounteredSAX(void *ctx, const char *msg, ...);
static void endDocumentSAX(void *ctx);
void startDocument(void *user_data);


@interface ChunkXMLParserInternals : NSObject {
@private
    NSMutableArray *objects;
}

+(id) sharedInstance:(id) inst;

- (void) addToArray:(ChunkXMLParser *) prs;
- (void) removeFromArray:(ChunkXMLParser *) prs;

- (void) parser:(xmlParserCtxtPtr) ctx DidEndItemName:(NSString *)name URI:(NSString *)uri;
- (void) parser:(xmlParserCtxtPtr) ctx DidBeginItemName:(NSString *)name URI:(NSString *)uri 
	 namespaces:(NSArray *)NS attributes:(NSDictionary *)attrs;
- (void) parser:(xmlParserCtxtPtr) ctx DidFindText:(NSString *)text;
- (void) parser:(xmlParserCtxtPtr) ctx DidRecieveError:(NSError *) err;
- (void) parserDidStarted :(xmlParserCtxtPtr) ctx;
- (void) parserDidFinished:(xmlParserCtxtPtr) ctx;

@end

#pragma mark -

@implementation ChunkXMLParser

static xmlSAXHandler simpleSAXHandlerStruct = {
	NULL,                       /* internalSubset */
	NULL,                       /* isStandalone   */
	NULL,                       /* hasInternalSubset */
	NULL,                       /* hasExternalSubset */
	NULL,                       /* resolveEntity */
	NULL,                       /* getEntity */
	NULL,                       /* entityDecl */
	NULL,                       /* notationDecl */
	NULL,                       /* attributeDecl */
	NULL,                       /* elementDecl */
	NULL,                       /* unparsedEntityDecl */
	NULL,                       /* setDocumentLocator */
	startDocument,              /* startDocument */
	endDocumentSAX,             /* endDocument */
	NULL,                       /* startElement*/
	NULL,                       /* endElement */
	NULL,                       /* reference */
	charactersFoundSAX,         /* characters */
	NULL,                       /* ignorableWhitespace */
	NULL,                       /* processingInstruction */
	NULL,                       /* comment */
	NULL,                       /* warning */
	errorEncounteredSAX,        /* error */
	NULL,                       /* fatalError //: unused error() get all the errors */
	NULL,                       /* getParameterEntity */
	NULL,                       /* cdataBlock */
	NULL,                       /* externalSubset */
	XML_SAX2_MAGIC,             // initialized? not sure what it means just do it
	NULL,                       // private
	startElementSAX,            /* startElementNs */
	endElementSAX,              /* endElementNs */
	NULL,                       /* serror */
};

//--------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
		saxParser = NULL;
		[[ChunkXMLParserInternals sharedInstance:nil] addToArray:self];
    }
    
    return self;
}

- (id) initWithData:(NSData *)dat
{
    self = [super init];
    if (self) {
		saxParser = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, NULL, [dat bytes], (int)[dat length], NULL);
		[[ChunkXMLParserInternals sharedInstance:nil] addToArray:self];
    }
    
    return self;	
}
//--------------------------------------------------------------------------------------------
- (void) dealloc
{
	if(saxParser != NULL){
		xmlParseChunk(saxParser, NULL, 0, 1);
		
		xmlFreeParserCtxt(saxParser);
		xmlCleanupParser();
		saxParser = NULL;
	}
	
	[[ChunkXMLParserInternals sharedInstance:nil] removeFromArray: self];
	[super dealloc];
}

//--------------------------------------------------------------------------------------------
- (void) setDelegate:(id<ChunkXMLParserDelegate>) del
{
	delegate = del;
}

//--------------------------------------------------------------------------------------------
- (id) delegate
{
	return delegate;
}

//--------------------------------------------------------------------------------------------
- (BOOL) isContextEqual:(xmlParserCtxtPtr) pars
{
	return pars == saxParser;
}

//--------------------------------------------------------------------------------------------
- (void) createParser:(NSData *) dat
{
	saxParser = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, NULL, [dat bytes], (int)[dat length], NULL);
}

//--------------------------------------------------------------------------------------------
- (void) addData:(NSData *) dat
{
	if(saxParser == NULL){
		[self createParser:dat];

	}
	else{
		xmlParseChunk(saxParser, [dat bytes], (int)[dat length], 0);
	}
	
}

//--------------------------------------------------------------------------------------------
- (void) finishProcessing
{
	xmlParseChunk(saxParser, NULL, 0, 1);
}
@end


#pragma mark -

@implementation ChunkXMLParserInternals

//--------------------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        objects = [[NSMutableArray alloc] init];
    }
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
	
    [objects release];
	
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
+(id) sharedInstance:(id) inst
{
	NSMutableDictionary *thrDict = [[NSThread currentThread] threadDictionary];
	ChunkXMLParserInternals *cur = [thrDict objectForKey:@"ChunkXMLParserInternals"];
	
	if( cur == nil){
		cur = [[ChunkXMLParserInternals alloc] init];
		[thrDict setObject:cur forKey:@"ChunkXMLParserInternals"];
	}
	if(inst != nil && [[inst className] isEqualToString:@"ChunkXMLParserInternals"]) {
		[thrDict removeObjectForKey:@"ChunkXMLParserInternals"];
	}
	
	return cur;
}

//--------------------------------------------------------------------------------------------
- (void) addToArray:(ChunkXMLParser *) prs
{
	[objects addObject:prs];
}

//--------------------------------------------------------------------------------------------
- (void) removeFromArray:(ChunkXMLParser *) prs
{
	[objects removeObject:prs];
	if( [objects count] == 0){
		[ChunkXMLParserInternals sharedInstance:self];
		[self release];
	}
}

//--------------------------------------------------------------------------------------------
- (id) getDelegate:(xmlParserCtxtPtr) ctx forObject:(ChunkXMLParser **) obj
{
	for (id tmp in objects) {
		if([tmp isContextEqual:ctx]){
			*obj = tmp;
			return [tmp delegate];
		}
	}
	*obj = nil;
	return nil;
}

//--------------------------------------------------------------------------------------------
- (void) parser:(xmlParserCtxtPtr) ctx DidEndItemName:(NSString *)name URI:(NSString *)uri
{
	ChunkXMLParser * obj;
	id delegate = [self getDelegate:ctx forObject:&obj];
	if( [delegate respondsToSelector:@selector(parserDidEndItem:name:URI:)] ){
		[delegate parserDidEndItem:obj name:name URI:uri];
	}
}

//--------------------------------------------------------------------------------------------
- (void) parser:(xmlParserCtxtPtr) ctx DidBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS attributes:(NSDictionary *)attrs
{
	ChunkXMLParser * obj;
	id delegate = [self getDelegate:ctx forObject:&obj];
	if( [delegate respondsToSelector:@selector(parserDidBeginItem:name:URI:namespaces:attributes:)] ){
		[delegate parserDidBeginItem:obj name:name URI:uri namespaces:NS attributes:attrs];
	}
}

//--------------------------------------------------------------------------------------------
- (void) parser:(xmlParserCtxtPtr) ctx DidFindText:(NSString *)text
{
	ChunkXMLParser * obj;
	id delegate = [self getDelegate:ctx forObject:&obj];
	if( [delegate respondsToSelector:@selector(parser:foundText:)] ){
		[delegate parser:obj foundText:text];
	}
}

//--------------------------------------------------------------------------------------------
- (void) parserDidStarted:(xmlParserCtxtPtr) ctx
{
	ChunkXMLParser * obj;
	id delegate = [self getDelegate:ctx forObject:&obj];
	if( [delegate respondsToSelector:@selector(parserDidBeginParsingData:)] ){
		[delegate parserDidBeginParsingData:obj];
	}
}

//--------------------------------------------------------------------------------------------
- (void) parserDidFinished:(xmlParserCtxtPtr) ctx
{
	ChunkXMLParser * obj;
	id delegate = [self getDelegate:ctx forObject:&obj];
	if( [delegate respondsToSelector:@selector(parserDidEndParsingData:)] ){
		[delegate parserDidEndParsingData:obj];
	}
}

//--------------------------------------------------------------------------------------------
- (void) parser:(xmlParserCtxtPtr) ctx DidRecieveError:(NSError *) err
{
	ChunkXMLParser * obj;
	id delegate = [self getDelegate:ctx forObject:&obj];
	if ([delegate respondsToSelector:@selector(parser:didFailWithError:)] ){
		[delegate parser:obj didFailWithError:err];
	}
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
static inline NSString * xmlCharToNSString( const xmlChar * ch )
{
	if ( ch == NULL )
		return ( nil );
	
	return ( [[NSString allocWithZone: nil] initWithBytes: ch
												   length: strlen((const char *)ch)
												 encoding: NSUTF8StringEncoding] );
}

//--------------------------------------------------------------------------------------------
static NSDictionary * attributesToNSDictionary( const xmlChar **attrs, int count)//count is 5 times the number of attrs
{
	if(attrs == NULL){
		return nil;
	}
	
	const xmlChar * tmp = NULL;
	xmlChar * str = NULL, * pointer = NULL;
	
	NSMutableArray *namesAndVals = [NSMutableArray arrayWithCapacity: count * 2 / 5];
	
	for (int i = 0; i < count; i += 5) {
		[namesAndVals addObject:xmlCharToNSString(attrs[i]) ];
		
		tmp = attrs[i + 3];
		str = (xmlChar *) malloc(attrs[i + 4] - attrs[i + 3] + 1);
		pointer = str;
		
		while (tmp != attrs[i + 4]) {
			*(pointer++) = *(tmp++);
		}
		*pointer = '\0';
		
		[namesAndVals addObject:xmlCharToNSString(str) ];
		free(str);
	}

	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:count/5];
	NSUInteger len = [namesAndVals count];
	
	for (int i = 0; i < len; i += 2) {
		[result setObject:[namesAndVals objectAtIndex:i+1] forKey:[namesAndVals objectAtIndex:i] ];
	}
	
	return result;
}

//--------------------------------------------------------------------------------------------
static NSArray * namespacesToNSArray(const xmlChar **namespaces, int count)
{
	if(namespaces == NULL){
		return nil;
	}
	
	NSMutableArray *NS = [NSMutableArray arrayWithCapacity:count /2];
	
	for (int i = 0; i < count; i += 2) {
		[NS addObject:xmlCharToNSString(namespaces[i + 1]) ];
	}
	
	return NS;
}

#pragma mark -
#pragma mark SAX Parsing Callbacks
//--------------------------------------------------------------------------------------------
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes) 
{
	NSString *name;
	
	if(prefix == NULL){
		name = xmlCharToNSString(localname);
	}
	else{
		name = [NSString stringWithFormat:@"%s:%s", prefix, localname];
	}
	
	NSString *uri = xmlCharToNSString(URI);
	NSArray * NS = namespacesToNSArray(namespaces, nb_namespaces *2);
	
	NSDictionary * attrs = attributesToNSDictionary(attributes, nb_attributes * 5);
	
	[[ChunkXMLParserInternals sharedInstance:nil] parser:(xmlParserCtxtPtr)ctx DidBeginItemName:name URI:uri namespaces:NS attributes: attrs];

}

//--------------------------------------------------------------------------------------------
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                          const xmlChar *URI) 
{
	NSString *name;
	
	if(prefix == NULL){
		name = xmlCharToNSString(localname);
	}
	else{
		name = [NSString stringWithFormat:@"%s:%s", prefix, localname];
	}
	
	NSString *uri = xmlCharToNSString(URI);
	
	[[ChunkXMLParserInternals sharedInstance:nil] parser:(xmlParserCtxtPtr)ctx DidEndItemName: name URI: uri];
}


//--------------------------------------------------------------------------------------------
static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) 
{
	char chars[len + 1];
    strncpy(chars, (const char *)ch, len);
    chars[len] = (char)NULL;

	[[ChunkXMLParserInternals sharedInstance:nil] parser:(xmlParserCtxtPtr)ctx DidFindText: xmlCharToNSString((xmlChar *)chars) ];
}

//--------------------------------------------------------------------------------------------
static void errorEncounteredSAX(void *ctx, const char *msg, ...) 
{
	va_list argList;
	va_start(argList, msg);
	xmlParserCtxtPtr con = ctx;

	NSError *er = [NSError errorWithDomain: NSXMLParserErrorDomain code: con->errNo userInfo: nil];
	[[ChunkXMLParserInternals sharedInstance:nil] parser:con DidRecieveError:er];
}

//--------------------------------------------------------------------------------------------
void startDocument(void *user_data)
{
	[[ChunkXMLParserInternals sharedInstance:nil] parserDidStarted:(xmlParserCtxtPtr)user_data];
}

//--------------------------------------------------------------------------------------------
static void endDocumentSAX(void *ctx) 
{
	[[ChunkXMLParserInternals sharedInstance:nil] parserDidFinished:(xmlParserCtxtPtr)ctx];
}
