//
//  Vzaarm
//  Vzaar Framework
//
//  Created by Daniel Kennett on 26/04/2010
//  Copyright 2010 KennettNet Software Limited All rights reserved
//

#import "Vzaar.h"
#import "VzaarAPI10Methods.h"

@interface Vzaar () 
// Private properties

@property (readwrite, retain, nonatomic) id <VzaarTransport> transport;


@end

@implementation Vzaar

static NSArray *trustedExtensions;
static NSArray *acceptedExtensions;

+(void)initialize {
	
	acceptedExtensions = [[NSArray arrayWithObjects:@"asf", @"avi", @"flv", @"m4v", @"mov",
						   @"mp4", @"m4a", @"3gp", @"3g2", @"mj2", @"wmv", @"4xm", @"MTV",
						   @"RoQ", @"aac", @"ac3", @"aiff", @"alaw", @"amr", @"apc", @"ape", 
						   @"au", @"avs", @"bethsoftvid", @"bktr", @"c93", @"daud", @"dsicin", 
						   @"dts", @"dv", @"dxa", @"ea", @"ffm", @"film_cpk", @"flac", @"flic",
						   @"gif", @"gxf", @"h261", @"h263", @"h264", @"idcin", @"image2", 
						   @"image2pipe", @"ingenient", @"ipmovie", @"matroska", @"mjpeg", @"mm", 
						   @"mmf", @"mp3", @"mpc", @"mpeg", @"mpegts", @"mpegtsraw", @"mpegvideo",
						   @"mulaw", @"mxf", @"nsv", @"nut", @"nuv", @"ogg", @"oss", @"psxstr", 
						   @"rawvideo", @"redir", @"rm", @"rtsp", @"s16be", @"s16le", @"s8", @"sdp",
						   @"shn", @"smk", @"sol", @"swf", @"thp", @"tiertexseq", @"tta",  @"txd",  
						   @"u16be", @"u16le", @"u8", @"vc1",  @"vmd",  @"voc",  @"wav",  @"wc3movie",
						   @"wsaud", @"wsvqa", @"wv", @"yuv4mpegpipe", nil] retain];
	
	
	trustedExtensions = [[NSArray arrayWithObjects:@"mp3", @"asf", @"avi", @"flv", @"m4v", @"mov", 
						  @"mp4", @"m4a", @"3gp", @"3g2", @"mj2", @"wmv", nil] retain];
	
}

+(BOOL)fileIsAccepted:(NSString *)filePath {
	return [acceptedExtensions containsObject:[[filePath pathExtension] lowercaseString]]; 
}

+(NSArray *)acceptedFileExtensions {
	return [NSArray arrayWithArray:acceptedExtensions];
}

+(BOOL)fileIsTrusted:(NSString *)filePath {
	return [trustedExtensions containsObject:[[filePath pathExtension] lowercaseString]];
}

+(NSArray *)trustedFileExtensions {
	return [NSArray arrayWithArray:trustedExtensions];
}

-(id)init {
	return [self initWithURL:[NSURL URLWithString:kLiveAPIEndPoint]];
}

-(id)initWithURL:(NSURL *)apiEndpoint {
	return [self initWithURL:apiEndpoint oAuthSecret:nil oAuthToken:nil];
}

-(id)initWithoAuthSecret:(NSString *)secret oAuthToken:(NSString *)token {
	return [self initWithURL:[NSURL URLWithString:kLiveAPIEndPoint] oAuthSecret:secret oAuthToken:token];
}

-(id)initWithURL:(NSURL *)apiEndpoint oAuthSecret:(NSString *)secret oAuthToken:(NSString *)token {
	return [self initWithURL:apiEndpoint oAuthSecret:secret oAuthToken:token APIVersion:kVersion1_0];
}

// Designated initialiser
-(id)initWithURL:(NSURL *)apiEndpoint oAuthSecret:(NSString *)secret oAuthToken:(NSString *)token APIVersion:(VzaarAPIVersion)version {
	if (self = [super init]) {
		
		[self setApiURL:apiEndpoint];
		[self setOAuthToken:token];
		[self setOAuthSecret:secret];
		
		[self addObserver:self
			   forKeyPath:@"apiURL"
				  options:0
				  context:nil];
		
		[self addObserver:self
			   forKeyPath:@"oAuthToken"
				  options:0
				  context:nil];
		
		[self addObserver:self
			   forKeyPath:@"oAuthSecret"
				  options:0
				  context:nil];
		
		[self addObserver:self
			   forKeyPath:@"apiVersion"
				  options:0
				  context:nil];
		
		[self setApiVersion:version];
	}
	return self;
}

-(void)dealloc {
	
	[self removeObserver:self forKeyPath:@"apiURL"];
	[self removeObserver:self forKeyPath:@"oAuthToken"];
	[self removeObserver:self forKeyPath:@"oAuthSecret"];
	[self removeObserver:self forKeyPath:@"apiVersion"];
	
	[self setApiURL:nil];
	[self setTransport:nil];
	[self setOAuthToken:nil];
	[self setOAuthSecret:nil];	
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize apiVersion;
@synthesize transport;
@synthesize apiURL;
@synthesize allowUntrustedFiles;
@synthesize oAuthToken;
@synthesize oAuthSecret;

#pragma mark -
#pragma mark KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
		
	if ([keyPath isEqualToString:@"apiVersion"]) {
		
		// Update transport to match APIVersion
		switch ([self apiVersion]) {
			case kVersion1_0:
				[self setTransport:[[[VzaarAPI10Methods alloc] initWithURL:[self apiURL]
																  oAuthToken:[self oAuthToken]
																 oAuthSecret:[self oAuthSecret]] autorelease]];
				break;
			default:
				break;
		}
		
	} else if ([keyPath isEqualToString:@"apiURL"]) {
		if ([self apiVersion] == kVersion1_0) [(VzaarAPI10Methods *)[self transport] setApiURL:[self apiURL]];
	} else if ([keyPath isEqualToString:@"oAuthToken"]) {
		if ([self apiVersion] == kVersion1_0) [(VzaarAPI10Methods *)[self transport] setOAuthToken:[self oAuthToken]];
	} else if ([keyPath isEqualToString:@"oAuthSecret"]) {
		if ([self apiVersion] == kVersion1_0) [(VzaarAPI10Methods *)[self transport] setOAuthSecret:[self oAuthSecret]];
	}
		
}

#pragma mark -
#pragma mark API Methods 


-(NSDictionary *)userDetailsForUsername:(NSString *)username error:(NSError **)error { 
	return [[self transport] userDetailsForUsername:username error:error];
}


-(NSDictionary *)accountDetailsForAccountWithId:(NSUInteger)accountId error:(NSError **)error { 
	return [[self transport] accountDetailsForAccountWithId:accountId error:error];
}

-(NSArray *)videosForUser:(NSString *)userName
		  withTitleFilter:(NSString *)titleFilter
					 page:(NSUInteger)page 
		  ofPagesOfLength:(NSUInteger)pageLength 
		 reverseSortOrder:(BOOL)reverseSort 
					error:(NSError **)error { 
	
	return [[self transport] videosForUser:userName
						   withTitleFilter:titleFilter
									  page:page
						   ofPagesOfLength:pageLength
						  reverseSortOrder:reverseSort
									 error:error];
}

-(NSDictionary *)detailsOfVideoWithId:(NSUInteger)videoId options:(VzaarVideoDetailOptions)options error:(NSError **)error { 
	return [[self transport] detailsOfVideoWithId:videoId options:options error:error];
}

-(NSString *)userName:(NSError **)error { 
	return [[self transport] userName:error];
}


-(id <VZVideoUploader>)beginUploadOfVideoWithTitle:(NSString *)title
									   description:(NSString *)videoDescription
										   profile:(VzaarVideoProfile)videoProfile
										  filePath:(NSString *)location
							  replacingVideoWithId:(NSUInteger)existingVideoId
										  delegate:(id <VZVideoUploadDelegate>) delegate {
	
	return [[self transport] beginUploadOfVideoWithTitle:title
											 description:videoDescription
												 profile:videoProfile
												filePath:location
									replacingVideoWithId:existingVideoId
									 allowUntrustedFiles:[self allowUntrustedFiles]
												delegate:delegate];
}


-(BOOL)updateVideoWithId:(NSUInteger)videoId withTitle:(NSString *)title description:(NSString *)videoDescription error:(NSError **)error { 
	return [[self transport] updateVideoWithId:videoId withTitle:title description:videoDescription error:error];
}

-(BOOL)deleteVideoWithId:(NSUInteger)videoId error:(NSError **)error { 
	return [[self transport] deleteVideoWithId:videoId error:error];
}




@end
