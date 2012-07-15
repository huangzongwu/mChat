//
//  XMLProcessor.m
//  mChat
//
//  Created by Martin Jahn on 05/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "XMLProcessor.h"

@implementation XMLProcessor

- (id)init
{
    return [self initWithDelegate:nil];
}

//--------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id) del
{
	return [self initWithDelegate:del andAuth: NO];
}

//--------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id) del andAuth: (BOOL) isAuth
{
    self = [super init];
    if (self) {
		
		state = 0;
		delegate = del;
		
		XMLRepresentation *rep = [[XMLRepresentation alloc] initForAuth:isAuth];
		[XMLRepresentation sharedThread:delegate];
		stateMachine = [[NSMutableArray alloc] initWithObjects:rep, nil];
		
		parser = [[ChunkXMLParser alloc] init];
		[parser setDelegate:self];
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc
{
	delegate = nil;
	
	for (id xml in stateMachine) {
		[xml release];
	}
	
	[stateMachine release];
	
	[super dealloc];
}

//--------------------------------------------------------------------------------------------
-(id) delegate
{
	return delegate;
}

-(void) setDelegate:(id<XMLProcessorDelegate>) del
{
	delegate = del;
}

//--------------------------------------------------------------------------------------------
- (void) parseData:(NSData *)dat
{
	[parser addData:dat];
}

#pragma mark -
#pragma mark ChunkXMLParser delegate
//--------------------------------------------------------------------------------------------
- (void)parserDidBeginParsingData:(ChunkXMLParser *)pars
{
	NSLog(@"Did start parser: %@", pars);
}

//--------------------------------------------------------------------------------------------
- (void)parserDidEndParsingData:(ChunkXMLParser *)pars
{
	NSLog(@"Did end parser: %@", pars);
}

//--------------------------------------------------------------------------------------------
- (void)parserDidBeginItem:(ChunkXMLParser *)pars name:(NSString *)name URI:(NSString *)uri
				namespaces:(NSArray *)NS attributes:(NSArray *) attrs
{
	XMLRepresentation *tmp = [stateMachine objectAtIndex:[stateMachine count] - 1];
	[tmp processBeginItemName: name URI: uri namespaces: NS 
				   attributes:attrs stateMachine: stateMachine];
}

//--------------------------------------------------------------------------------------------
- (void)parserDidEndItem:(ChunkXMLParser *)pars name:(NSString *)name URI:(NSString *)uri
{
	XMLRepresentation *tmp = [stateMachine objectAtIndex:[stateMachine count] - 1];
	[tmp processEndItemName: name URI: uri stateMachine: stateMachine];
	
}

//--------------------------------------------------------------------------------------------
- (void)parser:(ChunkXMLParser *)pars foundText:(NSString *)text
{
	XMLRepresentation *tmp = [stateMachine objectAtIndex:[stateMachine count] - 1];
	[tmp processText: text stateMachine: stateMachine];
}

//--------------------------------------------------------------------------------------------
- (void)parser:(ChunkXMLParser *)pars didFailWithError:(NSError *)error
{
	NSLog(@"\nParser error: %@\n", error);
}

@end
