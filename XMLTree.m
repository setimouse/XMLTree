//
//  XMLTree.m
//  shenbian
//
//  Created by Leeyan on 11-10-11.
//  Copyright 2011 ÁôæÂ∫¶. All rights reserved.
//

#import "XMLTree.h"


@implementation XMLTree

@synthesize xml = _xml;
@synthesize tree = _tree;

- (void)dealloc {
	[_parser release];
	[_tree release];
	[_stack release];
	
	[super dealloc];
}

- (id)initWithXMLString:(NSString *)xmlString {
	if (self = [super init]) {
		self.xml = xmlString;
		_parser = [[NSXMLParser alloc] initWithData:[self.xml dataUsingEncoding:NSUTF8StringEncoding]];
		[_parser setDelegate:self];
	}
	return self;
}

- (BOOL)parse {
	[_tree release];
	_tree = nil;
	
	return [_parser parse];
}

#pragma mark -
#pragma mark NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	_tree = [[XMLTreeNode alloc] init];
	_stack = [[NSMutableArray alloc] initWithObjects:_tree, nil];
	_lastNode = _tree;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[_stack release];
	_stack = nil;
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	XMLTreeNode *node = [[XMLTreeNode alloc] init];
	
	node.key = elementName;
	node.depth = [_stack count];
	
	XMLTreeNode *parent = [_stack lastObject];
	parent.child = node;
	
	[_stack addObject:node];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
	[_stack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	XMLTreeNode *node = (XMLTreeNode *)[_stack lastObject];
	node.value = string;
}

- (XMLTreeNode *)tree {
	return _tree.child;
}

- (XMLTreeNode *)_nodeForXPath:(NSMutableArray *)pathStack inTree:(XMLTreeNode *)aTree error:(NSError **)error {
	
	NSString *step = [pathStack objectAtIndex:0];
	
	if ([pathStack count] == 1 && [aTree.key isEqualToString:step]) {
		return aTree;
	}
	
	if (nil == aTree.key && [step isEqualToString:@""]) {
		[pathStack removeObjectAtIndex:0];
		return [self _nodeForXPath:pathStack inTree:aTree.child error:error];
	}
	
	if ([aTree.key isEqualToString:step]) {
		if ([pathStack count] == 1) {
			return aTree;
		} else if (nil != aTree.child) {
			[pathStack removeObjectAtIndex:0];
			return [self _nodeForXPath:pathStack inTree:aTree.child error:error];
		}
	}
	
	if (nil != aTree.nextSibling) {
		return [self _nodeForXPath:pathStack inTree:aTree.nextSibling error:error];
	}
	
	*error = [NSError errorWithDomain:@"node not found" code:0 userInfo:nil];
	return nil;
}

- (XMLTreeNode *)nodeForXPath:(NSString *)xPath error:(NSError **)error {
	NSArray *pathStack = [xPath componentsSeparatedByString:@"/"];
	return [self _nodeForXPath:[NSMutableArray arrayWithArray:pathStack] inTree:_tree error:error];
}

@end





#pragma mark -
#pragma mark XMLTreeNode

@implementation XMLTreeNode 

@synthesize key = _key, value = _value, nextSibling = _left, child = _right;
@synthesize depth;

- (void)dealloc {
	[_key release];
	[_value release];
	[_left release];
	[_right release];
	
	[super dealloc];
}

- (NSString *)stringValue {
	DLog(@"node value is %@, for key: %@", self.value, self.key);
	return self.value;
}

- (NSString *)descStringValue {
	NSMutableString *indent = [NSMutableString string];;
	for (int i = 0; i < self.depth; i++) {
		[indent appendString:@"\t"];
	}
	NSMutableString *string = [NSMutableString string];
	[string appendFormat:@"\n%@{ %@ : %@ }", indent, self.key, self.value];
	
	if (self.child) {
		[string appendFormat:@"%@", [self.child stringValue]];
	} else if (self.nextSibling) {
		[string appendFormat:@"%@", [self.nextSibling stringValue]];
	}
	
	return string;
}

- (NSString *)description {
	return [self descStringValue];
}

- (void)setNextSibling:(XMLTreeNode *)node {
	if (nil == self.nextSibling) {
		[_left release];
		_left = [node retain];
	} else {
		self.nextSibling.nextSibling = node;
	}
}

- (void)setChild:(XMLTreeNode *)node {
	if (self.child == nil) {
		[_right release];
		_right = [node retain];
	} else {
		self.child.nextSibling = node;
	}

}





















@end
