//
//  RosterController.h
//  mChat
//
//  Created by Martin Jahn on 03/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMPPManager.h"

@interface RosterController : NSObject  <NSApplicationDelegate, XMPPManagerDelegate> {
@private
	XMPPManager *stream;
	NSArray *roster;
	
    IBOutlet NSPanel *signInSheet;
    IBOutlet NSWindow *window;

    IBOutlet NSTextField *server;
    IBOutlet NSTextFieldCell *serverCell;
    IBOutlet NSTextField *port;
    IBOutlet NSButton *sslStyle;
    IBOutlet NSButton *selfSignedCert;
    IBOutlet NSTextField *jid;
    IBOutlet NSSecureTextField *passwd;
    IBOutlet NSTextField *resource;
	IBOutlet id table;
}
- (IBAction)signIn:(id)sender;
- (IBAction)registerJID:(id)sender;
- (IBAction)changePort:(id)sender;
- (IBAction)sendField:(id)sender;
- (IBAction)presence:(id)sender;



@end
