//
//  ChunkXMLParser.h
//  mChat
//
//  Created by Martin Jahn on 29/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <libxml/parser.h>

@protocol ChunkXMLParserDelegate;

@interface ChunkXMLParser : NSObject{
@private
	xmlParserCtxtPtr	saxParser;
	
	id<ChunkXMLParserDelegate> delegate;

}

- (void) setDelegate:(id<ChunkXMLParserDelegate>) del;
- (id) delegate;


- (void) addData:(NSData *) dat;

- (void) finishProcessing;
@end


@protocol ChunkXMLParserDelegate <NSObject>
@optional

- (void)parserDidBeginParsingData:(ChunkXMLParser *)pars;
- (void)parserDidEndParsingData:(ChunkXMLParser *)pars;

- (void)parserDidBeginItem:(ChunkXMLParser *)pars name:(NSString *)name URI:(NSString *)uri 
				namespaces:(NSArray *)NS attributes:(NSDictionary *) attrs;
- (void)parserDidEndItem:(ChunkXMLParser *)pars name:(NSString *)name URI:(NSString *)uri;
- (void)parser:(ChunkXMLParser *)pars foundText:(NSString *)text;

- (void)parser:(ChunkXMLParser *)pars didFailWithError:(NSError *)error;
@end
