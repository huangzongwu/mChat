//
//  Thread.m
//  mChat
//
//  Created by Martin Jahn on 24/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "Thread.h"
#import "XMLRepresentation.h"

@implementation Thread

- (id)init
{
    self = [super init];
    if (self) {
		thr = nil;
		run = YES;
		
		recieveQueue = [[NSMutableArray alloc] init];
		sendQueue = [[NSMutableArray alloc] init];
		
		sendLock = [[NSLock alloc] init];
		recieveLock = [[NSLock alloc] init];
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------
-(id) initWithThread
{
	return [self initWithThreadAndArgument:nil];
}

//--------------------------------------------------------------------------------------------
-(id) initWithThreadAndArgument:(id) attr
{
	id obj = [self init];
	[obj createThreadWithArgument:attr];
	
	return obj;
}

//--------------------------------------------------------------------------------------------
-(void) dealloc
{	
	[self performSelector:@selector(deallocThread) onThread:thr withObject:self waitUntilDone:YES];
	
	[sendQueue release];
	[recieveQueue release];
	[sendLock release];
	[recieveLock release];
	
	[thr release];
	
	[super dealloc];
	
	
}

//--------------------------------------------------------------------------------------------
-(void) setDelegate:(id<ThreadDelegate>) del
{
	delegate = del;
}
-(id) getDelegate
{
	return delegate;
}

//--------------------------------------------------------------------------------------------
-(void) endThread{
	[self performSelector:@selector(deallocThread) onThread:thr withObject:self waitUntilDone:NO];
}

//--------------------------------------------------------------------------------------------
-(void) threadStarted
{
	[self performSelector:@selector(standardizeRunLoop) onThread:thr withObject:self waitUntilDone:NO];
	
	if ([delegate respondsToSelector:@selector(threadStarted:)] ){
		[delegate threadStarted:self];
	}
	
	if ([delegate respondsToSelector:@selector(autentificate)] ){
		[delegate autentificate];
	}
}

#pragma mark Thread creation
//--------------------------------------------------------------------------------------------
-(void) createThread
{
	[self createThreadWithArgument:nil];
}

//--------------------------------------------------------------------------------------------
-(void) createThreadWithArgument:(id) attr;
{
	run = YES;
	
	thr = [[NSThread alloc] initWithTarget:self selector:@selector(threadManager:) object:attr];
	[thr start];
	[thr setName:@"XMLStreaAndParser"];
}

#pragma mark -
#pragma mark Primary Thread
//--------------------------------------------------------------------------------------------
- (void) parseData:(NSData *)dat
{
	[sendLock lock];
	[sendQueue addObject:dat];
	[sendLock unlock];
	
	[self performSelector:@selector(getData) onThread:thr withObject:self waitUntilDone:NO];
}

//--------------------------------------------------------------------------------------------
- (void) pushObject
{
	[recieveLock lock];
	id tmp = [recieveQueue objectAtIndex:0];
	[recieveQueue removeObjectAtIndex:0];
	[recieveLock unlock];
	
	if( [delegate respondsToSelector:@selector(pushObject:FromThread:)] ){
		[delegate pushObject:tmp FromThread:self];
	}
	[tmp release];
}

//--------------------------------------------------------------------------------------------
- (void) newParser
{
	[self performSelector:@selector(newParserObject) onThread:thr withObject:self waitUntilDone:NO];
	
	[sendLock lock];
	[sendQueue removeAllObjects];
	[sendLock unlock];
	
	[recieveLock lock];
	[recieveQueue removeAllObjects];
	[recieveLock unlock];
}

#pragma mark -
#pragma mark Secondary Thread
//--------------------------------------------------------------------------------------------
-(void) initThread
{
	NSLog(@"init Thread");
	pars = [[XMLProcessor alloc] initWithDelegate:self andAuth:YES];
	
}

//--------------------------------------------------------------------------------------------
-(void) threadManager:(id)Arg
{
	NSAutoreleasePool * pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
							 beforeDate:[NSDate dateWithTimeIntervalSinceNow:3]];
	

	[self initThread];
	[self performSelectorOnMainThread:@selector(threadStarted) withObject:self waitUntilDone:NO];
	
	[NSThread sleepForTimeInterval:1];
	[pool drain];

	while (run) {
		pool = [[NSAutoreleasePool alloc] init];

		@try {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
		}
		@catch (NSException *exception) {
			NSLog(@"Unrecognized exception: %@", exception);
		}
		@finally {
		}
		
		
		[pool drain];
	}

	NSLog(@"Run Loop broke");
}

//--------------------------------------------------------------------------------------------
- (void) standardizeRunLoop
{
	NSLog(@"loop standardized");
}

//--------------------------------------------------------------------------------------------
-(void) deallocThread
{
	[pars release];
	
	run = NO;
}

//--------------------------------------------------------------------------------------------
- (void) newParserObject
{
	[pars release];
	pars = [[XMLProcessor alloc] initWithDelegate:self andAuth:NO];
	
}

//--------------------------------------------------------------------------------------------
- (void) getData
{
	[sendLock lock];
	NSData * dat = [[sendQueue objectAtIndex:0] copy];
	[sendQueue removeObjectAtIndex:0];
	[sendLock unlock];
	
	[pars parseData: dat];
	[dat autorelease];
}


- (void) send:(id) obj
{
	[recieveLock lock];
	[recieveQueue addObject:obj];
	[recieveLock unlock];
	
	[self performSelectorOnMainThread:@selector(pushObject) withObject:self waitUntilDone:NO];
}
	 
@end
