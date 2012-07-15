//
//  XMLRepresentation.m
//  mChat
//
//  Created by Martin Jahn on 27/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "XMLRepresentation.h"
#import "Thread.h"


#pragma mark -
@implementation XMLRepresentation

//--------------------------------------------------------------------------------------------
+ (Thread *) sharedThread:(Thread *)thread
{
	static Thread *thr = nil;
	
	if(thr == nil){
		thr = thread;
	}

	return thr;
}

//--------------------------------------------------------------------------------------------
- (id) initForAuth:(BOOL) isAuth
{
	if (isAuth) {
		[self retainCount];
		return [[XMLRepresentationAuth alloc]init];
	}
	
	self = [super init];
	if (self) {
		perform = @selector(nothing:);

	}
	return self;
}

//--------------------------------------------------------------------------------------------
- (id)init
{
    return [self initForAuth:NO];
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
	
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (void) setPerform:(SEL)sel
{
	perform = sel;
}

//--------------------------------------------------------------------------------------------
- (SEL) perform
{
	return perform;
}

//--------------------------------------------------------------------------------------------
- (id) copy
{
	XMLRepresentation *tmp = [[XMLRepresentation alloc] init];
	
	return tmp;
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"iq"] ){
		XMLRepIQ * tmp = [[XMLRepIQ alloc] initWithAttributes:attrs];
		[statM addObject:tmp];
	}
	
	if( [name isEqualToString:@"message"] ){
		XMLRepChat *tmp = [[XMLRepChat alloc] initWithAttributes:attrs];
		[statM addObject:tmp];
	}
	
	if ([name isEqualToString:@"stream:features"]) {

		XMLRepFeatures * tmp = [[XMLRepFeatures alloc] init];
		[statM addObject:tmp];
	}
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
	NSLog(@"Ignorring text: %@", text);
}

@end


@implementation XMLRepresentationAuth

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"challenge"] ){
		XMLRepChall *tmp = [[XMLRepChall alloc] init];
		[statM addObject:tmp];
	}
	
	if ([name isEqualToString:@"stream:features"]) {
		
		XMLRepFeatures * tmp = [[XMLRepAuthFeatures alloc] init];
		[statM addObject:tmp];
	}
	
	if( [name isEqualToString:@"success"] ){
		
		XMLRepSuccess *tmp = [[XMLRepSuccess alloc] init];
		[statM addObject:tmp];
	}
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
	NSLog(@"Ignorring text: %@", text);
}

@end
