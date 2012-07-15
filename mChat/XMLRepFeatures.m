//
//  XMLRepFeatures.m
//  mChat
//
//  Created by Martin Jahn on 01/08/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "XMLRepresentation.h"
#import "Thread.h"

@implementation XMLRepFeatures
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
	if( [name isEqualToString:@"starttls"] ){
		XMLRepTLS * tmp = [[XMLRepTLS alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	if( [name isEqualToString:@"compression"] ){
		XMLRepCompress *tmp = [[XMLRepCompress alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	if( [name isEqualToString:@"register"] ){
		XMLRepRegister *tmp = [[XMLRepRegister alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	if( [name isEqualToString:@"bind"] ){
		XMLRepBind *tmp = [[XMLRepBind alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	NSLog(@"unrecognized tag name in features: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"stream:features"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
	
	NSLog(@"end element of name: %@ in stream:features", name);
}

@end

#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepAuthFeatures

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
	if( [name isEqualToString:@"starttls"] ){
		XMLRepTLS * tmp = [[XMLRepTLS alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	if ([name isEqualToString:@"mechanisms"]) {
		XMLRepSASL * tmp = [[XMLRepSASL alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	if( [name isEqualToString:@"compression"] ){
		XMLRepCompress *tmp = [[XMLRepCompress alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	if( [name isEqualToString:@"register"] ){
		XMLRepRegister *tmp = [[XMLRepRegister alloc] init];
		[statM addObject:tmp];
		return;
	}
	
	NSLog(@"unrecognized tag name in features: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"stream:features"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
	
	NSLog(@"end element of name: %@ in stream:features", name);
}


@end

#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepTLS

- (id)init {
    self = [super init];
    if (self) {
        required = NO;
    }
    return self;
}

//--------------------------------------------------------------------------------------------
- (void) setRequired:(BOOL) req
{
	required = req;
}

//--------------------------------------------------------------------------------------------
- (id) copy
{
	XMLRepTLS *tmp = [super copy];
	
	[tmp setRequired:required];
	return tmp;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	NSLog(@"something went wrong at TLS name: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"starttls"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
	
	NSLog(@"end element of name: %@ in starttls", name);
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
	if ([text isEqualToString:@"required"]) {
		required = YES;
	}
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepCompress
- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (id) copy
{
	return [super copy];
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	NSLog(@"ignorring tag at Compress name: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"compression"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];

		[statM removeObject:self];
		return;
	}
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
#warning unprocessed compress
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepSASL

- (id)init {
    self = [super init];
    if (self) {
        mask = 0;
    }
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (id) copy
{
	return [super copy];
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	NSLog(@"Igniring tag name in SASL: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"mechanisms"] ){
		
		perform = @selector(SASL:);
		NSLog(@"SASL ended, mask: %ld", mask);
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
	NSLog(@"Ignoring end tag in SASL: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{

	if( [text isEqualToString:@"DIGEST-MD5"] ){
		mask |= DIGEST_MD5;
		return;
	}
	
	if( [text isEqualToString:@"PLAIN"] ){
		mask |= PLAIN;
		return;
	}
	
	if( [text isEqualToString:@"CRAM-MD5"] ){
		mask |= CRAM_MD5;
		return;
	}
	
	if( [text isEqualToString:@"ANONYMOUS"] ){
		mask |= ANONYMOUS;
		return;
	}
	
	NSLog(@"Uncaught SASL method: %@", text);
}

//--------------------------------------------------------------------------------------------
- (NSInteger) mask
{
	return mask;
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepRegister

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (id) copy
{
	return [super copy];
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	NSLog(@"ignorring tag at Register name: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"register"] ){
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;
	}
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepChall


- (id)init {
    self = [super init];
    if (self) {
        base = nil;
    }
    return self;
}

//--------------------------------------------------------------------------------------------
- (void)dealloc {
    
	if(base != nil){
		[base release];
		base = nil;
	}
	
    [super dealloc];
}

//--------------------------------------------------------------------------------------------
- (NSString *) base
{
	return base;
}

//--------------------------------------------------------------------------------------------
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM
{
	NSLog(@"Ignoring name in Chall: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"challenge"] ){
		
		perform = @selector(digestMD5:);
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;	
	}
	NSLog(@"Ignoring end tag in Chall: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM
{
	if( base == nil){
		base = [text retain];
	}
	else{
		
		[base autorelease];
		base = [text retain];
	}
}

@end


#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepSuccess

- (id)init {
    self = [super init];
    if (self) {

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
	NSLog(@"Ignorring tag name in Success: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"success"] ){
		
		perform = @selector(authSuccess:);
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;	
	}
	NSLog(@"Ignoring end tag in Success: %@", name);
}

@end

#pragma mark -
//--------------------------------------------------------------------------------------------
@implementation XMLRepBind

- (id)init {
    self = [super init];
    if (self) {
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
	NSLog(@"Ignorring tag name in Bind: %@", name);
}

//--------------------------------------------------------------------------------------------
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM
{
	if( [name isEqualToString:@"bind"] ){
		
		perform = @selector(bindResource:);
		Thread *tmp = [XMLRepresentation sharedThread:nil];
		[tmp send:self];
		
		[statM removeObject:self];
		return;	
	}
	NSLog(@"Ignoring end tag in Bind: %@", name);
}

@end