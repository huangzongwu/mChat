//
//  XMPPManager.h
//  mChat
//
//  Created by Martin Jahn on 02/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Thread.h"
#import "NetStream.h"

@protocol XMPPManagerDelegate;

@interface XMPPManager : NSObject <NetStreamProtocol, ThreadDelegate>{
@private

	NSString *name;
	NSString *jServer;
	NSString *conServer;
	NSString *password;
	NSString *resource;
	
	BOOL selfSigned;
	BOOL sslStyle;
	int port;
	
	Thread * parser;
	NetStream *stream;
	
	id<XMPPManagerDelegate> delegate;
}

-(id) initWithAttrs:(NSDictionary *) attrs;
-(id) initWithAttrs:(NSDictionary *) attrs andDelegate:(id) del;

-(void) setDelegate:(id<XMPPManagerDelegate>) del;
-(id) getDelegate;

-(void) setAttrs:(NSDictionary *) atrs;
-(NSDictionary *) attrs;

-(void) autentificate;
-(void) setPresence:(NSInteger) type;

-(void) sendString:(NSString *) str;

@end


@protocol XMPPManagerDelegate <NSObject>
@optional

- (void)XMPPManagerDidOpen:(XMPPManager *)xs;

- (void)XMPPManagerDidRegister:(XMPPManager *)xs;


- (void)XMPPManagerDidAuthenticate:(XMPPManager *)xs;
- (void)XMPPManagerHasRoster:(NSArray *) rstr;

- (void)XMPPManager:(XMPPManager *)xs didReceiveMessage:(NSXMLElement *)message;
- (void)XMPPManager:(XMPPManager *)xs didReceivePresence:(NSXMLElement *)presence;

- (void)XMPPManager:(XMPPManager *)xs didReceiveError:(id)error;

- (void)XMPPManagerDidClose:(XMPPManager *)xs;

@end