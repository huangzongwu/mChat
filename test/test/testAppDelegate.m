//
//  testAppDelegate.m
//  test
//
//  Created by Martin Jahn on 26/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "testAppDelegate.h"

@implementation testAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}


-(IBAction) newThread:(id)sender
{
	thr = [[Thread alloc]initWithThread];
}


-(IBAction) endThread:(id)sender
{
	[thr endThread];
}

-(IBAction) performSelector:(id)sender
{
	[thr test];
}
@end
