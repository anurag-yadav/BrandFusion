//
//  VZXMLParser.m
//  Vzaar Framework
//
//  Created by Daniel Kennett on 27/04/2010.

//

#import "VZXMLParser1_0.h"
#import "TouchXML.h"
#import "Vzaar.h"

@interface VZXMLParser1_0 (Private) 
	
-(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error;
-(id)valueForXMLNode:(CXMLNode *)node;

@end

@implementation VZXMLParser1_0

+(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error {
	
	VZXMLParser1_0 *parser = [[VZXMLParser1_0 alloc] init];
	
	NSDictionary *dict = [[parser dictionaryForXMLData:data error:error] retain];
	[parser release];
	parser = nil;
	
	return [dict autorelease];	
}

-(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error {
	
	CXMLDocument *xmldocument = [[CXMLDocument alloc] initWithData:data
															options:0
															  error:error]; 
	
	id xmlRepresentation = [self valueForXMLNode:[xmldocument rootElement]];
	
	[xmldocument autorelease];
	
	if ([xmlRepresentation isKindOfClass:[NSDictionary class]]) {
		return xmlRepresentation;
	} else if ([xmlRepresentation isKindOfClass:[NSString class]]) {
		
		return [NSDictionary dictionaryWithObject:xmlRepresentation
										   forKey:[[xmldocument rootElement] name]];
		
	} else {
		if (error != NULL) {
			*error = [NSError errorWithDomain:kVZXMLParseError
										 code:0
									 userInfo:[NSDictionary dictionaryWithObject:kVZXMLParseErrorDescription
																		  forKey:NSLocalizedFailureReasonErrorKey]];
		}
		return nil;
	}
	
}

-(id)valueForXMLNode:(CXMLNode *)node {

	if ([node childCount] == 1 && [(CXMLNode *)[[node children] lastObject] kind] == CXMLTextKind) {
		
		NSString *str = [[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([str length] > 0) {
			return str;
		} else {
			return nil;
		}	
		
	} else if ([node childCount] > 0) {
			
		// Either an array or a dictionary

		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		for(CXMLNode *child in [node children]) {
		
			id existingObject = [dict valueForKey:[child name]];
			id newValue = [self valueForXMLNode:child];
						
			if (existingObject) {
				
				if ([existingObject isKindOfClass:[NSArray class]]) {
					[dict setValue:[existingObject arrayByAddingObject:newValue]
							forKey:[child name]];
				} else {
					
					if (newValue) {
						NSArray *array = [NSArray arrayWithObjects:existingObject, newValue, nil];
						[dict setValue:array forKey:[child name]];
					}
				}
				
			} else {
				
				if (newValue != nil) {
					
					NSString *name = [child name];
					if (!name) {
						name = [[child parent] name];
					}
					
					[dict setValue:newValue forKey:name];
				}
			}
		}
			
		return dict;
			
	} else {
		
		NSString *str = [[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([str length] > 0) {
			return str;
		} else {
			return nil;
		}	
		
	}
}

@end