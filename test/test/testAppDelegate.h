//
//  testAppDelegate.h
//  test
//
//  Created by Martin Jahn on 26/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Thread.h"

@interface testAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	
	Thread *thr;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction) newThread:(id)sender;
-(IBAction) endThread:(id)sender;
-(IBAction) performSelector:(id)sender;
@end
