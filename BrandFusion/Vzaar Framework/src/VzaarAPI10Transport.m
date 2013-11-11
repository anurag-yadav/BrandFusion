//
//  VzaarAPI10Transport.m
//  Vzaar Framework
//
//  Created by Daniel Kennett on 26/04/2010.

//

#import "VzaarAPI10Transport.h"
#import "VzaarTransport.h"
#import "VZXMLParser1_0.h"
#import "VZStringExtensions.h"
#import "VZDateExtensions.h"
#import "VZDictionaryExtensions.h"

@implementation VzaarAPI10Transport

-(id)initWithURL:(NSURL *)url oAuthToken:(NSString *)token oAuthSecret:(NSString *)secret {
	if (self = [super init]) {
		[self setApiURL:url];
		[self setOAuthToken:token];
		[self setOAuthSecret:secret];
	} 
	return self;
}

@synthesize apiURL;
@synthesize oAuthToken;
@synthesize oAuthSecret;

#pragma mark -
#pragma mark Sending Requests

-(NSDictionary *)sendPostRequestToURL:(NSURL *)url withMethod:(NSString *)httpMethod parameters:(NSDictionary *)parameters error:(NSError **)error {
	
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"" secret:@""] autorelease];
	OAToken *token = [[[OAToken alloc] initWithKey:[self oAuthSecret] secret:[self oAuthToken]] autorelease];

	NSMutableString *xml = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
	
	[xml appendString:@"<vzaar-api>"];
	
	if ([httpMethod length] > 0) {
		[xml appendFormat:@"<_method>%@</_method>\n", httpMethod];
	}
	
	if (parameters) {
		[xml appendString:[parameters vzaarAPIXMLString]];
	}
	[xml appendString:@"</vzaar-api>"];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:token 
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];	
	
}

-(NSDictionary *)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
	
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"" secret:@""] autorelease];
	OAToken *token = [[[OAToken alloc] initWithKey:[self oAuthSecret] secret:[self oAuthToken]] autorelease];
	
	NSMutableString *parameterString = [NSMutableString string];
	BOOL first = YES;
	
	for (NSString *key in [parameters allKeys]) {		
		
		id value = [parameters valueForKey:key];
		
		if (value) {
			[parameterString appendFormat:@"%@%@=%@",
			 first ? @"?" : @"&", 
			 key, 
			 [value isKindOfClass:[NSString class]] ? [value urlEncodedString] : [[value stringValue] urlEncodedString]];
			first = NO;
		}		
	}
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
																								  [url absoluteString], 
																								  parameterString]]
																   consumer:consumer
																	  token:token 
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"GET"];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];
}

-(NSDictionary *)sendPreparedRequest:(OAMutableURLRequest *)request error:(NSError **)error {
			
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&connectionError];
	
	if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {
		if (connectionError == nil) {
			
			NSDictionary *errorResponse = [self dictionaryForVzaarResponseData:responseData error:nil]; 
			
			if (error != NULL) {
				*error = [NSError errorWithDomain:@"com.vzaar.api"
											 code:[response statusCode]
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   [errorResponse valueForKey:@"error"], NSLocalizedFailureReasonErrorKey, nil]];
			}
		} else {
			
			if (error != NULL) {
				*error = connectionError;
			}
		}
		return nil;
		
	} else {
		// All was OK in the URL, let's try and parse the XML.
		
		NSError *parseError = nil;
		NSDictionary *dict = [self dictionaryForVzaarResponseData:responseData error:&parseError];
		
		if (parseError != nil) {
			if (error != NULL) {
				*error = parseError;
			}
			return nil;
		} else {
			return dict;
		}
	}	
}
							  
-(NSDictionary *)dictionaryForVzaarResponseData:(NSData *)data error:(NSError **)error {
	return [VZXMLParser1_0 dictionaryForXMLData:data error:error];	
}



@end 
