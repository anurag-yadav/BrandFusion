//
//  VZDateExtensions.h
//  Vzaar Framework
//
//  Created by Daniel Kennett on 28/04/2010.

//

#import <Foundation/Foundation.h>


@interface NSDate (VZDateExtensions)

+(NSDate *)dateWithVzaarDateString:(NSString *)dateStr;
+(NSDate *)dateWithS3DateString:(NSString *)dateStr;

@end
