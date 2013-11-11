//
//  VZDictionaryExtensions.m
//  Vzaar Framework
//
//  Created by Daniel Kennett on 28/04/2010.

//

#import "VZDictionaryExtensions.h"


@implementation NSDictionary (VZDictionaryExtensions)

-(NSString *)vzaarAPIXMLString {
	
	NSMutableString *xmlString = [NSMutableString string];
	
	for (NSString *key in [self allKeys]) {
		
		id value = [self valueForKey:key];
		
		if ([value isKindOfClass:[NSString class]]) {
			[xmlString appendFormat:@"<%@>%@</%@>", key, value, key];
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			[xmlString appendFormat:@"<%@>\n%@\n</%@>", key, [value vzaarAPIXMLString], key];
		} else {
			[xmlString appendFormat:@"<%@>%@</%@>", key, [value stringValue], key];
		}		
	}
	return xmlString;	
}

@end
