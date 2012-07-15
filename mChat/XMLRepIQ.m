//
//  XMLRepIQ.m
//  mChat
//
//  Created by Martin Jahn on 01/08/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "XMLRepresentation.h"
#import "Thread.h"

@implementation XMLRepIQ

- (id) initWithAttributes:(NSDictionary *)attrs
{
	self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------
- (id)init
{
    return [self initWithAttributes:nil];
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
    [super dealloc];
}


//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"query"] ) {
		if( [uri isEqualToString:@"jabber:iq:roster"] ){
			XMLRepRoster *tmp = [[XMLRepRoster alloc] init];
			[statM addObject:tmp];
		}
	}
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"iq"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
	
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepRoster

- (id) initWithAttributes:(NSDictionary *)attrs
{
	self = [super initWithAttributes:attrs];
    if (self) {
		roster = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------
- (id)init
{
    return [self initWithAttributes:nil];
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
	[roster release];
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	[roster addObject:attrs];
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"query"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
}

@end
