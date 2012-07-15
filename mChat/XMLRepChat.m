//
//  XMLRepChat.m
//  mChat
//
//  Created by Martin Jahn on 01/08/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "XMLRepresentation.h"
#import "Thread.h"

@implementation XMLRepChat
//--------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
    [super dealloc];
}


//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"iq"] ){
		XMLRepIQ * tmp = [[XMLRepIQ alloc] initWithAttributes:attrs];
		[statM addObject:tmp];
	}
	
	if ([name isEqualToString:@"stream:features"]) {
		XMLRepFeatures * tmp = [[XMLRepFeatures alloc] init];
		[statM addObject:tmp];
	}
	
	if( [name isEqualToString:@"message"] ){
		XMLRepChat *tmp = [[XMLRepChat alloc] initWithAttributes:attrs];
	}
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
	
}

@end