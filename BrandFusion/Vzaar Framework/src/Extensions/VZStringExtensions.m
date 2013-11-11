//
//  VZStringExtensions.m
//  Vzaar Framework
//
//  Created by Daniel Kennett on 26/04/2010.

//

#import "VZStringExtensions.h"


@implementation NSString (VZStringExtensions) 

-(NSString *)urlEncodedString {
	
	CFStringRef str = CFURLCreateStringByAddingPercentEscapes(NULL,
															  (CFStringRef)self,
															  NULL,
															  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
															  kCFStringEncodingUTF8);
	
	NSString *unencodedString = [NSString stringWithString:(NSString *)str];	
	
	CFRelease(str);
	
	return unencodedString;
}

@end
