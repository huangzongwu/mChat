//
//  NetStream.h
//  mChat
//
//  Created by Martin Jahn on 27/07/2011.
//  Copyright 2011 Mums SOft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"

@protocol NetStreamProtocol;

@interface NetStream : NSObject <NSStreamDelegate>{
@private
	
	id<NetStreamProtocol> delegate;
	BOOL canSend;
	
	NSString *server;
	NSInteger port;
	
	Thread *parser;
	
	NSOutputStream *oStream;
    NSInputStream *iStream;
    NSMutableArray *sendQueue;
}

- (id) initWithArgument:(NSDictionary *) arg;
- (id) initWithArgument:(NSDictionary *) arg andDelegate: (id) del;

- (void) setThread:(Thread *)thr;
- (Thread *) thread;

- (void) sendString:(NSString *) str;
- (void) sendXMLObject:(NSXMLNode *) elem;
@end

@protocol NetStreamProtocol <NSObject>
@optional

- (void) netStreamDidOpen:(NetStream *)ns;
- (void) netStreamDidClose:(NetStream *)ns;

- (void) netStream:(NetStream *)ns DidRecieveError:(NSError *)er;
@end
