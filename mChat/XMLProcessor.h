//
//  XMLProcessor.h
//  mChat
//
//  Created by Martin Jahn on 05/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChunkXMLParser.h"
#import "XMLRepresentation.h"

@protocol XMLProcessorDelegate;

@interface XMLProcessor : NSObject <ChunkXMLParserDelegate> {
@private
    
	NSInteger state;
	id<XMLProcessorDelegate> delegate;
	
	ChunkXMLParser * parser;
	NSMutableArray *stateMachine;
}

- (id)initWithDelegate:(id) del;
- (id)initWithDelegate:(id) del andAuth: (BOOL) isAuth;

- (id) delegate;
- (void) setDelegate:(id<XMLProcessorDelegate>) del;

- (void) parseData:(NSData *)dat;

@end

@protocol XMLProcessorDelegate <NSObject>
@optional

- (void) XMLProcessorBegan:(XMLProcessor *)xp;

@end
