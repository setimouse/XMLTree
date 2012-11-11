//
//  XMLTree.h
//  shenbian
//
//  Created by Leeyan on 11-10-11.
//  Copyright 2011 ÁôæÂ∫¶. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLTreeNode;

@interface XMLTree : NSObject <NSXMLParserDelegate> {
	NSXMLParser *_parser;
	NSString *_xml;
	XMLTreeNode *_tree;
	XMLTreeNode *_lastNode;
	NSMutableArray *_stack;
	NSUInteger _depth;
}

@property(nonatomic, retain) NSString *xml;
@property(nonatomic, readonly) XMLTreeNode *tree;

- (id)initWithXMLString:(NSString *)xmlString;
- (BOOL)parse;
- (XMLTreeNode *)nodeForXPath:(NSString *)xPath error:(NSError **)error;

@end




@interface XMLTreeNode : NSObject {
	XMLTreeNode *_left;
	XMLTreeNode *_right;
	NSString *_key;
	NSString *_value;
}

@property(nonatomic, retain) XMLTreeNode *nextSibling;
@property(nonatomic, retain) XMLTreeNode *child;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *value;
@property(assign) NSUInteger depth;

- (NSString *)stringValue;

@end
