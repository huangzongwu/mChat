//
//  NetStream.m
//  mChat
//
//  Created by Martin Jahn on 27/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "NetStream.h"

#define BUFFSIZE 256

@implementation NetStream

//--------------------------------------------------------------------------------------------
- (id)initWithArgument:(NSDictionary *) arg
{
    return [self initWithArgument:arg andDelegate:nil];
}

//--------------------------------------------------------------------------------------------
-(id) initWithArgument:(NSDictionary *) arg andDelegate: (id) del
{
	self = [super init];
    if (self) {
        canSend = NO;
		delegate = del;
		

		port = [[arg objectForKey:@"port"] integerValue];
		server = [[arg objectForKey:@"server"] retain];
		parser = [[ arg objectForKey:@"thread"] retain];
		


		NSHost *host = [NSHost hostWithName:server];
		// iStream and oStream are instance variables
		[NSStream getStreamsToHost:host port:port inputStream:&iStream
					  outputStream:&oStream];
		[iStream retain];
		[oStream retain];
		[iStream setDelegate:self];
		[oStream setDelegate:self];
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
		[iStream open];
		[oStream open];
		
        sendQueue = [[NSMutableArray alloc] init];
	}

    return self;
	
}

//--------------------------------------------------------------------------------------------
-(void) dealloc
{
	
	if(oStream != nil){
        [oStream write:(const uint8_t*)"<presence type='unavailable'/></stream:stream>" maxLength:16];
        [oStream close];
        [oStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [oStream release];
        oStream = nil; // stream is ivar, so reinit it
    }
    
    if(iStream != nil){
        [iStream close];
        [iStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [iStream release];
        iStream = nil; // stream is ivar, so reinit it
	}
	
	[server release];
	[parser release];
	
	[super dealloc];
}

//--------------------------------------------------------------------------------------------
-(void) sendXMLObject:(NSXMLNode *) elem
{
	[self sendString:[elem stringValue]];
}

//--------------------------------------------------------------------------------------------
- (void) setThread:(Thread *)thr
{
	parser = thr;
}

//--------------------------------------------------------------------------------------------
- (Thread *) thread
{
	return parser;
}

#pragma mark -
#pragma mark Connection
//--------------------------------------------------------------------------------------------
- (void) whitespaceAvailable: (NSStream *) stream
{
    if (stream == oStream) {
        if([sendQueue count]  == 0){
            canSend = YES;
            NSLog(@"Nothing to write\n");
            return;
        }
        else{
			canSend = NO;
        }
        
        
        const uint8_t * rawstring = (uint8_t*)[[sendQueue objectAtIndex:0] UTF8String];
        NSLog(@"Write: %s\n", rawstring);
        [oStream write:rawstring maxLength:strlen((const char *) rawstring)];
        [sendQueue removeObjectAtIndex:0];
    }
    else{
        NSLog(@"input stream cannot write\n");
    }
    
}

//--------------------------------------------------------------------------------------------
-(void) sendString:(NSString *) str
{
	[sendQueue addObject:str];
	
	if(canSend){
		[self whitespaceAvailable:oStream];
	}
}

//--------------------------------------------------------------------------------------------
- (void) closeStream: (NSStream *) stream
{
	[oStream close];
	[oStream removeFromRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
	[oStream release];
	oStream = nil;
	
	[iStream close];
	[iStream removeFromRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
	[iStream release];
	iStream = nil;
	NSLog(@"end encountered");
	
}

//--------------------------------------------------------------------------------------------
- (void) incomming:(NSStream *)stream
{
	
	if(stream == iStream){
		
		uint8_t *bfr;
		
		bfr = (uint8_t *) calloc(sizeof(uint8_t), BUFFSIZE);
		[iStream read:bfr maxLength:BUFFSIZE - 1];
		
		NSData *inp = [NSData dataWithBytes:bfr length:strlen((const char *)bfr)];
		NSLog(@"Returned text: %s", (const char *) bfr);
		
		[parser parseData:inp];
		
		free(bfr);
	}
}

//--------------------------------------------------------------------------------------------
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            
            [self whitespaceAvailable: stream];
            
            break;
            
        case NSStreamEventHasBytesAvailable:
            [self incomming:stream];
			
            break;
            
        case NSStreamEventOpenCompleted:
			
            NSLog(@"open compleated");
            break;
            
        case NSStreamEventEndEncountered:
            
            [self closeStream: stream];
			
			if( [delegate respondsToSelector:@selector(netStreamDidClose:)] ){
				[delegate netStreamDidClose:self];
			}
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Status error");
            NSLog(@"Self refCOunt: %ld", [self retainCount]);
            NSError *theError = [stream streamError];
            
			if( [delegate respondsToSelector:@selector(netStream:DidRecieveError:)] ){
				[delegate netStream:self DidRecieveError:theError];
			}
			
			[stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream autorelease];
			stream = nil;
            break;
            
        default:
            NSLog(@"uncatched");
            
        }
    }
}




@end
