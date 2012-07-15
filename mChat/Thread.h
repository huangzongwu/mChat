//
//  Thread.h
//  mChat
//
//  Created by Martin Jahn on 24/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLProcessor.h"

@protocol ThreadDelegate;

@interface Thread : NSObject <XMLProcessorDelegate> {
@private

	XMLProcessor *pars;
	BOOL run;
	NSThread *thr;
	
	id<ThreadDelegate> delegate;

	NSLock *recieveLock;
	NSMutableArray *recieveQueue;
	
	NSLock *sendLock;
	NSMutableArray *sendQueue;
}

-(id) initWithThread;
-(id) initWithThreadAndArgument:(id) attr;

-(void) setDelegate:(id<ThreadDelegate>) del;
-(id) getDelegate;

-(void) createThread;
-(void) createThreadWithArgument:(id) attr;
-(void) endThread;

//--------------------------------------------------------------------------------------------
//primary thread
- (void) parseData:(NSData *)dat;
- (void) newParser;

//--------------------------------------------------------------------------------------------
//secondary thread
- (void) send:(id) obj;


@end


@protocol ThreadDelegate <NSObject>
@optional

-(void) threadStarted: (Thread *)thr;

- (void) pushObject:(id) obj FromThread: (Thread *)thr;
- (void) autentificate;
@end
