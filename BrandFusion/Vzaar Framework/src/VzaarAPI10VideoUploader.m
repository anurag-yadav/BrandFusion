//
//  VzaarAPI10VideoUploader.m
//  Vzaar Framework
//
//  Created by Daniel Kennett on 28/04/2010.

//

#import "VzaarAPI10VideoUploader.h"
#import "VZStringExtensions.h"
#import "VZDateExtensions.h"
#import <CommonCrypto/CommonHMAC.h> 

@interface VzaarAPI10VideoUploader ()

@property (readwrite, copy, nonatomic) NSString *sourceFileLocation;
@property (readwrite, nonatomic) NSUInteger uploadedVideoId;

@property (readwrite, copy, nonatomic) NSString *videoTitle;
@property (readwrite, copy, nonatomic) NSString *videoDescription;
@property (readwrite, nonatomic) VzaarVideoProfile videoProfile;

@property (readwrite, copy, nonatomic) NSString *transientUploadGuid;
@property (readwrite, nonatomic) NSUInteger replacedVideoId;


-(void)beginS3UploadWithHTTPMethod:(NSString *)httpMethod headers:(NSArray *)headers url:(NSURL *)url;
-(void)requestVzaarRESTUploadSignature;
-(void)notifyVzaarOfSuccessfulUpload;

- (NSData *)HMACSHA1withKey:(NSString *)key forString:(NSString *)string;
- (NSString *)base64forData:(NSData *)data;

@end

@implementation VzaarAPI10VideoUploader


-(void)dealloc {
	[self setSourceFileLocation:nil];
	[self setVideoTitle:nil];
	[self setVideoDescription:nil];
	[self setTransientUploadGuid:nil];
	
	[s3Uploader cancel];
	[s3Uploader release];
	s3Uploader = nil;
	
	[super dealloc];
}

@synthesize sourceFileLocation;
@synthesize delegate;
@synthesize uploadedVideoId;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize videoProfile;
@synthesize transientUploadGuid;
@synthesize replacedVideoId;

-(void)beginUploadOfVideoWithTitle:(NSString *)title
					   description:(NSString *)desc
						   profile:(VzaarVideoProfile)profile
						  filePath:(NSString *)location
			  replacingVideoWithId:(NSUInteger)existingVideoId
						  delegate:(id <VZVideoUploadDelegate>) del {
	
	[self setDelegate:del];
	[self setSourceFileLocation:location];
	[self setVideoTitle:title];
	[self setVideoDescription:desc];
	[self setVideoProfile:profile];
	[self setReplacedVideoId:existingVideoId];

	[self requestVzaarRESTUploadSignature];
	
} 

-(void)cancel {
	[s3Uploader cancel];
}

-(void)requestVzaarRESTUploadSignature {

	NSError *error = nil;
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:[[[self sourceFileLocation] lastPathComponent] urlEncodedString] 
														   forKey:@"filename"];
	
	
	
	NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@s3/sign.xml", [[self apiURL] absoluteString]]]
										   withParameters:parameters
													error:&error];
	
	if (error != nil) {
		[[self delegate] uploader:self didFailToUploadVideo:[self sourceFileLocation] withError:error];
		return;
	}
	
	NSString *httpMethod = [apiResponse valueForKey:@"method"];
	NSString *requestACLHeader = [apiResponse valueForKeyPath:@"headers.acl"];
	NSString *requestDateHeader = [apiResponse valueForKeyPath:@"headers.date"];
	NSString *requestContentTypeHeader = [apiResponse valueForKeyPath:@"headers.content-type"];
	NSString *requestAuthHeader = [apiResponse valueForKeyPath:@"headers.authorization"];
	NSString *guid = [apiResponse valueForKey:@"guid"];
	NSURL *s3URL = [NSURL URLWithString:[apiResponse valueForKey:@"url"]];
	
	if (!httpMethod || !requestACLHeader || !requestDateHeader || 
		!requestContentTypeHeader || !requestAuthHeader || !guid || !s3URL) {
	
		[[self delegate] uploader:self didFailToUploadVideo:[self sourceFileLocation]
						withError:[NSError errorWithDomain:kVZAPIReturnedIncorrectDataError
													  code:0
												  userInfo:[NSDictionary dictionaryWithObject:kVZAPIReturnedIncorrectDataErrorDescription
																					   forKey:NSLocalizedFailureReasonErrorKey]]];
	} else {
		
		[self setTransientUploadGuid:guid];
		
		[self beginS3UploadWithHTTPMethod:httpMethod
								  headers:[NSArray arrayWithObjects:requestACLHeader, requestDateHeader, requestContentTypeHeader, requestAuthHeader, nil]
									  url:s3URL];
		
	}
	
}

-(void)beginS3UploadWithHTTPMethod:(NSString *)httpMethod headers:(NSArray *)headers url:(NSURL *)url {
	
	s3Uploader = [[ASIHTTPRequest alloc] initWithURL:url];
	
	[s3Uploader setPostBodyFilePath:[self sourceFileLocation]];
	[s3Uploader setShouldStreamPostDataFromDisk:YES];
	[s3Uploader setRequestMethod:httpMethod];
	
	for (NSString *header in headers) {
		
		NSRange colonLocation = [header rangeOfString:@":"];
		if (colonLocation.location != NSNotFound) {
			
			NSString *headerKey = [[header substringToIndex:colonLocation.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *headerValue = [[header substringFromIndex:colonLocation.location + colonLocation.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			if ([headerKey length] > 0 && [headerValue length] > 0) {
				[s3Uploader addRequestHeader:headerKey value:headerValue];			
			}		
		}
	}
	
	[s3Uploader setShowAccurateProgress:YES];
	[s3Uploader setUploadProgressDelegate:self];
	[s3Uploader setUseSessionPersistence:NO];
	[s3Uploader setDelegate:self];
	[s3Uploader setDidFinishSelector: @selector(s3UpdateDidComplete:)];
	[s3Uploader setDidFailSelector: @selector(s3UpdateDidFail:)];
	
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:s3Uploader];
	
}


// This is the call ASIHTTPRequest sends on Mac OS X.
-(void)setDoubleValue:(double)value {
	[[self delegate] uploader:self didUploadDataWithProgress:value];
}

// This is the call ASIHTTPRequest sends on iPhone OS.
-(void)setProgress:(float)value {
	[[self delegate] uploader:self didUploadDataWithProgress:(double)value];
}

-(void)s3UpdateDidComplete:(ASIHTTPRequest *)request {
	
	[self notifyVzaarOfSuccessfulUpload];
	
	[s3Uploader release];
	s3Uploader = nil;
}

-(void)s3UpdateDidFail:(ASIHTTPRequest *)request {
	
	[[self delegate] uploader:self
		didFailToUploadVideo:[self sourceFileLocation]
					withError:[request error]];
	
	[s3Uploader release];
	s3Uploader = nil;
}


-(void)notifyVzaarOfSuccessfulUpload {
	
	NSMutableDictionary *internalParams = [NSMutableDictionary dictionary];
	
	[internalParams setValue:[self transientUploadGuid] forKey:@"guid"];
	[internalParams setValue:[self videoTitle] forKey:@"title"];
	[internalParams setValue:[self videoDescription] forKey:@"description"];
	[internalParams setValue:[NSNumber numberWithInt:[self videoProfile]] forKey:@"profile"];
	
	if ([self replacedVideoId] != kDoNotReplaceId) {
		[internalParams setValue:[NSNumber numberWithUnsignedInt:[self replacedVideoId]] forKey:@"replace_id"];
	}
	
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:internalParams forKey:@"video"];
	
	NSError *error = nil;
	
	NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@videos", [self apiURL]]]
												withMethod:@""
												parameters:parameters
													 error:&error];
	
	if (error != nil) {
		
		[[self delegate] uploader:self
			didFailToUploadVideo:[self sourceFileLocation]
						withError:error];
		
		return;
	} else {
		[self setUploadedVideoId:[[apiResponse valueForKey:@"video"] longLongValue]];
		
		[[self delegate] uploader:self
				   didUploadVideo:[self sourceFileLocation]
					  withVideoId:[self uploadedVideoId]];		 
		
	}	
	
}

#pragma mark -
#pragma mark Workers

- (NSData *)HMACSHA1withKey:(NSString *)key forString:(NSString *)string
{
	NSData *clearTextData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	
	CCHmacContext hmacContext;
	CCHmacInit(&hmacContext, kCCHmacAlgSHA1, keyData.bytes, keyData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
	
	return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}


- (NSString *)base64forData:(NSData *)data
{
    static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
    if ([data length] == 0)
        return @"";
	
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
	
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
			buffer[bufferLength++] = ((char *)[data bytes])[i++];
		
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		
        if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		
        if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';        
    }
	
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

@end
