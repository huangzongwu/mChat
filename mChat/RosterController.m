//
//  RosterController.m
//  mChat
//
//  Created by Martin Jahn on 03/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import "RosterController.h"


#define SECURE_PORT 5223
#define UNSECURE_PORT 5222

@implementation RosterController


- (id)init
{
	self = [super init];
    if (self) {
    
		roster = nil;
    }
    
    return self;
}


#pragma mark Actions
- (IBAction)signIn:(id)sender
{
	NSArray *JID;
	NSString *CServer;

	JID = [[jid stringValue] componentsSeparatedByString:@"@"];
	if([[server stringValue] isEqualToString:@""]){
		CServer = [JID objectAtIndex:1];
	}
	else{
		CServer = [[server stringValue] copy];
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[port integerValue]], @"port",
						  [NSNumber numberWithBool:[sslStyle state]], @"sslState",
						  [NSNumber numberWithBool:[selfSignedCert state]], @"selfSigned",
						  [JID objectAtIndex:0], @"name",
						  [JID objectAtIndex:1], @"jServer",
						  CServer, @"conServer",
						  [[resource stringValue] copy], @"resource",
						  [[passwd stringValue] copy], @"password",nil];
			
	stream = [[XMPPManager alloc] initWithAttrs:dict andDelegate:self];
	
	//[stream autentificate];
	
	[signInSheet  orderOut:self];
	[NSApp endSheet:signInSheet];
}

//--------------------------------------------------------------------------------------------
- (IBAction)registerJID:(id)sender
{

}

//--------------------------------------------------------------------------------------------
- (IBAction)changePort:(id)sender
{
    if([sender state]){
        if(port.intValue == UNSECURE_PORT){
            [port setIntValue:SECURE_PORT];
        }
    }
    else{
        if(port.intValue == SECURE_PORT){
			[port setIntValue:UNSECURE_PORT];
		}
	}
}

//--------------------------------------------------------------------------------------------
- (IBAction)sendField:(id)sender
{
	[stream sendString:[sender stringValue]];
}

//--------------------------------------------------------------------------------------------
- (IBAction)presence:(id)sender
{
	[stream setPresence:[[sender selectedItem]tag]];
}

#pragma mark XMPPManager Delegate Methods
//--------------------------------------------------------------------------------------------
- (void)XMPPManagerDidAuthenticate:(XMPPManager *)xs
{
	[signInSheet  orderOut:self];
	[NSApp endSheet:signInSheet];
	[stream setPresence:0];
}

//--------------------------------------------------------------------------------------------
- (void)XMPPManagerHasRoster:(NSArray *) rstr
{
	roster = [rstr retain];
	[table reloadData];
}

//--------------------------------------------------------------------------------------------
- (void)XMPPManagerDidClose:(XMPPManager *)xs
{
    [NSApp beginSheet:signInSheet
       modalForWindow:window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

#pragma mark UI Delegate Methods
//--------------------------------------------------------------------------------------------
- (void) JIDChecker
{
  NSString *text = [jid stringValue];
    
    
    if([text isEqualToString:@""]){
        return;
    }
    NSArray *ar = [text componentsSeparatedByString:@"@"];
    
    if([ar count] == 2){
        NSString *srv = [ar objectAtIndex:1];
        
        [serverCell setPlaceholderString:srv];
        return;
    }
    return;
}

//--------------------------------------------------------------------------------------------
-(void) portChecer{
	if([port intValue] < 65536){
		[port setIntValue:[port intValue]];
	}
	else{
		int val = [port intValue];
		while (val > 65536) {
			val /= 10;
		}
		[port setIntValue:val];
	}
}

//--------------------------------------------------------------------------------------------
- (void)controlTextDidEndEditing:(NSNotification *)aNotification{
	id object = [aNotification object];
	
	if(object == jid){
		[self JIDChecker];
	}
	if (object == port) {
		[self portChecer];
	}
}


//--------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
    [NSApp beginSheet:signInSheet
       modalForWindow:window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}


//--------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(NSNotification *)aNotification
{	
	if(stream != nil){
		[stream release];
	}
	
	if(roster != nil){
		[roster release];
	}
}

#pragma mark Table
//--------------------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *) aTableView
{
	return [roster count];
}

//--------------------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	return [[roster objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

//--------------------------------------------------------------------------------------------
/*- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)tableColumn
			  row:(int)rowIndex
{
    [[columns objectForKey:[tableColumn identifier]] replaceObjectAtIndex:[aTableView selectedRow] 
                                                               withObject:(NSString *)anObject];
}*/
@end
