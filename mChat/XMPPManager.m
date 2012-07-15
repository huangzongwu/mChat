//
//  XMPPManager.m
//  mChat
//
//  Created by Martin Jahn on 02/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//


#import <SSCrypto/SSCrypto.h>
#import "XMPPManager.h"
#import "XMLRepresentation.h"

@implementation XMPPManager

-(id) initWithAttrs:(NSDictionary *) attrs
{
	return [self initWithAttrs:attrs andDelegate:nil];
}

//--------------------------------------------------------------------------------------------
- (id)initWithAttrs:(NSDictionary *) attrs andDelegate:(id) del
{
    self = [super init];
    
    if(self != nil){
		
		
		name = nil;
		jServer = nil;
		conServer = nil;
		password = nil;
		resource = nil;
		
		delegate = del;

		[self setAttrs:attrs];

		parser = [[Thread alloc] initWithThread];
		[parser setDelegate:self];
		
		NSNumber *prt = [NSNumber numberWithInt:port];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: prt, @"port", conServer, @"server", parser, @"thread", nil];

		stream  = [[NetStream alloc] initWithArgument:dict andDelegate:self];
    }
    return self;
}

//--------------------------------------------------------------------------------------------
-(void) dealloc
{
	delegate = nil;
	
	[parser release];
    
	[name release];
	[jServer release];
	[conServer release];
	[password release];
	[resource release];
	
	[super dealloc];
}

//--------------------------------------------------------------------------------------------
-(void) setDelegate:(id<XMPPManagerDelegate>) del
{
	delegate = del;
}

-(id) getDelegate
{
	return delegate;
}


//--------------------------------------------------------------------------------------------
-(void) setAttrs:(NSDictionary *) atrs
{	
	if(name != nil)
		[name release];
	
	name = [[atrs objectForKey:@"name"] retain];
	if(jServer != nil)
		[jServer release];
	
	jServer = [[atrs objectForKey:@"jServer"] retain];
	if(conServer != nil)
		[conServer release];
	
	conServer = [[atrs objectForKey:@"conServer"] retain];
	if(password != nil)
		[password release];
		
	password = [[atrs objectForKey:@"password"] retain];
	if(resource != nil)
		[resource release];
	
	resource = [[atrs objectForKey:@"resource"] retain];
	
	selfSigned = [[atrs objectForKey:@"selfSigned"] boolValue];
	sslStyle = [[atrs objectForKey:@"sslStyle"] boolValue];
	port = [[atrs objectForKey:@"port"] intValue];
}

//--------------------------------------------------------------------------------------------
-(NSDictionary *) attrs
{
	return [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", jServer, @"jServer", conServer, @"conServer", 
			password, @"pass", resource, @"resource", [NSNumber numberWithBool: selfSigned], @"selfSigned", 
			[NSNumber numberWithBool:sslStyle], @"sslStyle", [NSNumber numberWithInt:port], @"port", nil];
}

//--------------------------------------------------------------------------------------------
-(NSDictionary *) getPortAndServer: (Thread *)thr
{
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:conServer, @"server", [NSNumber numberWithInt:port], @"port", nil];
	return dict;
}

//--------------------------------------------------------------------------------------------
-(void) sendString:(NSString *)str
{
	[stream sendString:str];
}

//--------------------------------------------------------------------------------------------
-(void) autentificate
{

	NSString * str = [NSString stringWithFormat:
					  @"<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' to='%@' version='1.0'>", 
						  jServer];
	[self sendString:str];
}

#pragma mark -
#pragma mark XMPP stuff
//--------------------------------------------------------------------------------------------
-(void) setPresence:(NSInteger) type
{	
	switch (type) {
		case 0:
			[self sendString:@"<presence/>"];
			break;
		
		case 1:
			[self sendString:@"<presence><show>chat</show></presence>"];
			break;
			
		case 2:
			[self sendString:@"<presence><show>away</show></presence>"];
			break;
			
		case 3:
			[self sendString:@"<presence><show>xa</show></presence>"];
			break;
			
		case 4:
			[self sendString:@"<presence><show>dnd</show></presence>"];
			break;
			
		case 5:
			[self sendString:@"<presence type='unavailable'/>"];
			break;
			
		default:
			NSLog(@"Unimplemented presence type XMPPManager");
			break;
	}
}

//--------------------------------------------------------------------------------------------
-(void) threadStarted: (Thread *)thr
{
	NSLog(@"thread has started");
}

#pragma mark -
//--------------------------------------------------------------------------------------------
-(NSString *) convertNameAndPassword
{
    NSData * result;
    int len = (int)[name length];
    char *res, i;
    const char *tmp;
    
    res = (char *) malloc([name length] + [password length] + 2);
    
    res[0] = '\0';
    tmp = [name UTF8String];
    
    for(i = 0 ; i < len; i++){
        res[i+1] = tmp[i];
    }
    
    res[i + 1] = '\0';
    tmp = [password UTF8String];
    len = (int)[password length];
    int n = i + 2;
    
    for(i = 0; i< len; i++){
        res[n] = tmp[i];
        n++;
    }
    result = [[NSString stringWithCString:res encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    free(res);
    return [result encodeBase64WithNewlines:NO];
}

//--------------------------------------------------------------------------------------------
-(void) SASLOptions:(NSInteger) mask
{
	if((mask & DIGEST_MD5) == 0){
		NSString *encoded;
		NSString *auth;
		encoded = [self convertNameAndPassword];
		auth = [NSString stringWithFormat:
				@"<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>%s</auth>", encoded];
		[self sendString:auth];
		return;
	}
	
	[self sendString:@"<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='DIGEST-MD5'/>"];
	
	
}

//--------------------------------------------------------------------------------------------
-(void) canEncrypt
{
	NSLog(@"canEncrypt");	
}

//--------------------------------------------------------------------------------------------
-(void) canCompress
{
	NSLog(@"canCompress");
}

//--------------------------------------------------------------------------------------------
-(void) canRegister:(BOOL) reg
{
	NSLog(@"canRegister: %d",reg);	
}


#pragma mark -
//--------------------------------------------------------------------------------------------
-(NSDictionary *) processDirectives:(NSArray *)dirs
{
	NSArray *tmp, *nms = [NSArray arrayWithObjects:@"realm", @"nonce", @"qop", @"charset", @"algorithm", nil];
	NSMutableDictionary *vals = [NSMutableDictionary dictionaryWithCapacity:5];

	
	for (NSString *str in dirs){
		
		tmp = [str componentsSeparatedByString:@"="];

		if([tmp count] != 2){
			@throw @"Wrong directives. [XMPPManager processDirectives:]";
		}
		
		for (NSString *nam in nms){
			if ([[tmp objectAtIndex:0]isEqualToString:nam] ){
				NSString *final = [[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:
								   [NSCharacterSet characterSetWithCharactersInString:@"\"'="]];
				[vals setObject:final forKey:nam];
				break;
			}
		}
	}
	
	if([vals count] == 5){
		return vals;
	}
	else{
		if([[tmp objectAtIndex:0] isEqualToString: @"rspauth"]){
			[vals setObject:[tmp objectAtIndex:1] forKey:@"rspauth"];
			return vals;
		}
		   
		@throw @"Something missing in directives. [XMPPManager processDirectives:]";
	}
}

//--------------------------------------------------------------------------------------------
-(NSString *) makeResponse:(NSDictionary *) vals cnonce:(NSString *) cnc
{
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	
	NSString *HA1str = [NSString stringWithFormat:@"%@:%@:%@", name, [vals objectForKey:@"realm"], password];
	NSString *HA2str = [NSString stringWithFormat:@"AUTHENTICATE:xmpp/%@", jServer];
	

	
	[crypto setClearTextWithString:HA1str];
	NSData *HA1dataA = [crypto digest:@"MD5"];
	
	NSData *HA1dataB = [[NSString stringWithFormat:@":%@:%@", [vals objectForKey:@"nonce"], cnc] dataUsingEncoding:NSUTF8StringEncoding];
	
	
	NSMutableData *HA1data = [NSMutableData dataWithCapacity:([HA1dataA length] + [HA1dataB length])];
	[HA1data appendData:HA1dataA];
	[HA1data appendData:HA1dataB];
	
	[crypto setClearTextWithData:HA1data];
	NSString *HA1 = [[crypto digest:@"MD5"] hexval];

	[crypto setClearTextWithString:HA2str];
	NSString *HA2 = [[crypto digest:@"MD5"] hexval];	
						
	NSString *responseStr = [NSString stringWithFormat:@"%@:%@:00000001:%@:auth:%@", HA1, [vals objectForKey:@"nonce"], cnc, HA2];

	[crypto setClearTextWithString:responseStr];
	NSString *response = [[crypto digest:@"MD5"] hexval];
	
	return response;
}

//--------------------------------------------------------------------------------------------
-(NSString *) makeCnonce:(NSDictionary *)vals
{	
	NSData *dat;
	dat = [SSCrypto getSHA1ForData:[[NSString stringWithFormat:@"%@", vals] dataUsingEncoding:NSUTF8StringEncoding]];

	return [dat hexval];
}


//--------------------------------------------------------------------------------------------
-(void) composeResponse:(NSDictionary *) vals
{
	NSMutableString *response = [[NSMutableString alloc] init];
	
	[response appendFormat:@"username=\"%@\",realm=\"%@\",", name, [vals objectForKey:@"realm"]];
	NSString *cnonce = [self makeCnonce:vals];
	[response appendFormat:@"nonce=\"%@\",cnonce=\"%@\",", [vals objectForKey:@"nonce"], cnonce];
	[response appendFormat:@"nc=00000001,qop=auth,digest-uri=\"xmpp/%@\",", jServer];
	[response appendFormat:@"response=%@,charset=utf-8", [self makeResponse:vals cnonce:cnonce]];
	
	NSString *txt = [[response dataUsingEncoding:NSUTF8StringEncoding] encodeBase64WithNewlines:NO];
	
	[response setString:@"<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>"];
	[response appendFormat:@"%@</response>", txt];

	[self sendString:response];
}
 
//--------------------------------------------------------------------------------------------
-(void) response:(NSString*) resp
{
	NSData *response = [[resp dataUsingEncoding:NSUTF8StringEncoding] decodeBase64WithNewLines:NO];
	NSString *str = [[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding] autorelease];
	NSArray *directives = [str componentsSeparatedByString:@","];
	
	NSDictionary *dict = [self processDirectives:directives];
		
	if([dict objectForKey:@"rspauth"] != nil){
		[self sendString: @"<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>"];
	}
	else{
		[self composeResponse:dict];
	}
}
#pragma mark -
//--------------------------------------------------------------------------------------------
-(void) roster:(NSArray *) rstr
{
	if( [delegate respondsToSelector:@selector(XMPPManagerHasRoster:)] ){
		[delegate XMPPManagerHasRoster:rstr];
	}
}

//--------------------------------------------------------------------------------------------
-(void) setResource:(NSString *) rsc
{
	resource = rsc;
}

//--------------------------------------------------------------------------------------------
-(void) textMessage:(NSDictionary *) msg
{
	NSLog(@"textMessage: %@", msg);
}

//--------------------------------------------------------------------------------------------
-(void) iqMessage:(NSDictionary *) iq
{
	NSLog(@"iqMessage: %@", iq);
}

//--------------------------------------------------------------------------------------------
-(void) firendRequest:(NSDictionary *) fr
{
	NSLog(@"friendRequest: %@",fr);
}


#pragma mark -
#pragma mark Process XMLRep stuff
#pragma mark Authentificaion
//--------------------------------------------------------------------------------------------
- (void) SASL:(XMLRepSASL *) obj
{
	[self SASLOptions:[obj mask]];
}

//--------------------------------------------------------------------------------------------
- (void) digestMD5:(XMLRepChall *) obj
{
	[self response:[obj base]];
}

//--------------------------------------------------------------------------------------------
- (void) authSuccess:(XMLRepSuccess *) obj
{
	[parser newParser];
	
	[self sendString:[NSString stringWithFormat:@"<?xml version='1.0'?><stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' to='%@' version='1.0'>", jServer]];
}

//--------------------------------------------------------------------------------------------
-(void) bindResource:(XMLRepBind *) obj
{
	NSString *send;	
	
	
	send = [NSString stringWithFormat:@"<iq from='%@@%@/%@' type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>%@</resource></bind></iq>", name, jServer, resource, resource];
	[self sendString:send];
	
	//send = [NSString stringWithString:@"<iq id='session-start' type='set'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>"];
	//[self sendString:send];
	
	send = [NSString stringWithString:@"<iq type='get'><query xmlns='jabber:iq:roster'/> </iq>"];
	[self sendString:send];
	
	if ([delegate respondsToSelector:@selector(XMPPManagerDidAuthenticate:)] ){
		[delegate XMPPManagerDidAuthenticate:self];
	}
}

//--------------------------------------------------------------------------------------------
- (void) nothing:(XMLRepresentation *)obj
{
}

//--------------------------------------------------------------------------------------------
- (void) pushObject:(id) obj FromThread: (Thread *)thr
{
	[self performSelector:[obj perform] withObject:obj];
}

@end
