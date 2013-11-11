//
//  VZDateExtensions.m
//  Vzaar Framework
//
//  Created by Daniel Kennett on 28/04/2010.

//

#import "VZDateExtensions.h"


@implementation NSDate (VZDateExtensions)

+(NSDate *)dateWithVzaarDateString:(NSString *)dateStr {
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setLenient:YES];
	
	[formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'+00:00'"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	//2007-07-12T11:30:13+00:00
	
	NSDate *date = [formatter dateFromString:dateStr];
	
	return date;
}

+(NSDate *)dateWithS3DateString:(NSString *)dateStr {
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setLenient:YES];
	
	[formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'.000Z'"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	
	//2009-06-11T00:05:43.000Z
	
	NSDate *date = [formatter dateFromString:dateStr];
	
	return date;
	
}

@end
