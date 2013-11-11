#import "VzaarAPI10Methods.h"
#import "VZStringExtensions.h"
#import "VZDateExtensions.h"
#import "ASIHTTPRequest.h"
#import "VzaarAPI10VideoUploader.h"

@interface VzaarAPI10Methods (Private)

-(NSDictionary *)videoDictionaryFromAPIVideoListResponseElement:(NSDictionary *)apiVideo;

@end

@implementation VzaarAPI10Methods

-(NSDictionary *)userDetailsForUsername:(NSString *)username error:(NSError **)error {
	
	if ([username length] == 0) return nil;
	
	NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@.xml", [[self apiURL] absoluteString], username]] 
										   withParameters:nil
													error:error];
	
	if (apiResponse) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		if ([apiResponse valueForKey:@"version"]) { 
			[dict setValue:[NSNumber numberWithDouble:[[apiResponse valueForKey:@"version"] doubleValue]] forKey:VZAPIVersionKey];
		}
		
		if ([apiResponse valueForKey:@"author_name"]) {
			[dict setValue:[apiResponse valueForKey:@"author_name"] forKey:VZUserNameKey];
		}
		
		if ([apiResponse valueForKey:@"author_id"]) {
			[dict setValue:[NSNumber numberWithUnsignedInteger:[[apiResponse valueForKey:@"author_id"] longLongValue]] forKey:VZUserIdKey];
		}
		
		if ([apiResponse valueForKey:@"author_url"]) {
			[dict setValue:[NSURL URLWithString:[apiResponse valueForKey:@"author_url"]] forKey:VZUserDashboardURLKey];
		}
		
		if ([apiResponse valueForKey:@"author_account"]) {
			[dict setValue:[NSNumber numberWithUnsignedInteger:[[apiResponse valueForKey:@"author_account"] longLongValue]] forKey:VZAccountIdKey];
		}
		
		if ([apiResponse valueForKey:@"play_count"]) {
			[dict setValue:[NSNumber numberWithUnsignedInteger:[[apiResponse valueForKey:@"play_count"] longLongValue]] forKey:VZPlayCountKey];
		}
		
		if ([apiResponse valueForKey:@"video_count"]) {
			[dict setValue:[NSNumber numberWithUnsignedInteger:[[apiResponse valueForKey:@"video_count"] longLongValue]] forKey:VZVideoCountKey];
		}
		
		if ([apiResponse valueForKey:@"created_at"]) {
			[dict setValue:[NSDate dateWithVzaarDateString:[apiResponse valueForKey:@"created_at"]] forKey:VZDateCreatedKey];
		}
		
		return dict;
		
	} else {
		return nil;
	}
}

-(NSDictionary *)accountDetailsForAccountWithId:(NSUInteger)accountId error:(NSError **)error {
	
	NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/%d.xml", [[self apiURL] absoluteString], accountId]] 
										   withParameters:nil
													error:error];
	
	if (apiResponse) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		if ([apiResponse valueForKey:@"version"]) { 
			[dict setValue:[NSNumber numberWithDouble:[[apiResponse valueForKey:@"version"] doubleValue]] forKey:VZAPIVersionKey];
		}
		
		if ([apiResponse valueForKey:@"account_id"]) {
			[dict setValue:[NSNumber numberWithUnsignedInteger:[[apiResponse valueForKey:@"account_id"] longLongValue]] forKey:VZVideoCountKey];
		}
		
		if ([apiResponse valueForKey:@"title"]) {
			[dict setValue:[apiResponse valueForKey:@"title"] forKey:VZAccountTitleKey];
		}
		
		if ([apiResponse valueForKey:@"bandwidth"]) {
			[dict setValue:[NSNumber numberWithUnsignedInteger:[[apiResponse valueForKey:@"bandwidth"] longLongValue]] forKey:VZAccountBandwidthKey];
		}
		
		if ([apiResponse valueForKeyPath:@"cost.monthly"]) {
			[dict setValue:[NSNumber numberWithDouble:[[apiResponse valueForKeyPath:@"cost.monthly"] doubleValue]] forKey:VZAccountMonthlyCostKey];
		}
		
		if ([apiResponse valueForKeyPath:@"cost.currency"]) {
			[dict setValue:[apiResponse valueForKeyPath:@"cost.currency"] forKey:VZAccountBillingCurrencyKey];
		}
		
		if ([apiResponse valueForKeyPath:@"rights.borderless"]) {
			[dict setValue:[NSNumber numberWithBool: [[apiResponse valueForKeyPath:@"rights.borderless"] caseInsensitiveCompare:@"true"] == NSOrderedSame ? YES : NO] 
					forKey:VZAccountAllowsBorderlessPlayerKey];
		}
		
		if ([apiResponse valueForKeyPath:@"rights.searchEnhancer"]) {
			[dict setValue:[NSNumber numberWithBool: [[apiResponse valueForKeyPath:@"rights.searchEnhancer"] caseInsensitiveCompare:@"true"] == NSOrderedSame ? YES : NO] 
					forKey:VZAccountAllowsSearchEnhancerKey];
		}
		
		return dict;
	} else {
		return nil;
	}
	
}

-(NSArray *)videosForUser:(NSString *)userName
		  withTitleFilter:(NSString *)titleFilter
					 page:(NSUInteger)page 
		  ofPagesOfLength:(NSUInteger)pageLength 
		 reverseSortOrder:(BOOL)reverseSort 
					error:(NSError **)error {
	
	if ([userName length] == 0) return nil;
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (reverseSort) {
		[parameters setValue:@"least_recent" forKey:@"sort"];
	}
	
	if ([titleFilter length] > 0) {
		[parameters setValue:titleFilter forKey:@"title"];
	}
	
	[parameters setValue:[NSNumber numberWithUnsignedInteger:page < 1 ? 1 : page]
				  forKey:@"page"];
	
	[parameters setValue:[NSNumber numberWithUnsignedInteger:pageLength > 100 ? 100 : (pageLength < 1 ? 1 : pageLength)]
				  forKey:@"count"];
	
	[parameters setValue:@"active,processing,failed" forKey:@"status"];
		
	NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/videos.xml", [[self apiURL] absoluteString], userName]]
										   withParameters:parameters
													error:error];
	
	if (apiResponse) {
		
		// This can either be a single video or an array of them
		id video = [apiResponse valueForKey:@"video"];
		
		if ([video isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *videos = [NSMutableArray array];
			
			for (NSDictionary *apiVideo in video) {
				
				NSDictionary *conditionedVideo = [self videoDictionaryFromAPIVideoListResponseElement:apiVideo];
				if (conditionedVideo) {
					[videos addObject:conditionedVideo];
				}
			}
			
			return [NSArray arrayWithArray:videos];
 			
		} else {
			NSDictionary *conditionedVideo = [self videoDictionaryFromAPIVideoListResponseElement:video];
			if (conditionedVideo) {
				return [NSArray arrayWithObject:conditionedVideo];
			}
		}
		
	} 
	
	return nil;
}

-(NSDictionary *)detailsOfVideoWithId:(NSUInteger)videoId options:(VzaarVideoDetailOptions)options error:(NSError **)error {
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if ((options & VzaarVideoDetailOptionBorderless) == VzaarVideoDetailOptionBorderless) {
		[parameters setValue:@"true" forKey:@"borderless"];
	}
	
	if ((options & VzaarVideoDetailOptionEmbedOnly) == VzaarVideoDetailOptionEmbedOnly) {
		[parameters setValue:@"true" forKey:@"embed_only"];
	}
	
	NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@videos/%d.xml", [[self apiURL] absoluteString], videoId]] 
										   withParameters:parameters
													error:error];
	if (apiResponse) {
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		if ([apiResponse valueForKeyPath:@"video.id"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKeyPath:@"video.id"] longLongValue]] forKey:VZVideoIdKey];
		}
		
		if ([apiResponse valueForKeyPath:@"video.state"]) {
			[dict setValue:[apiResponse valueForKeyPath:@"video.state"] forKey:VZVideoStatusKey];
		}
		
		if ([apiResponse valueForKeyPath:@"video.video_status_id"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKeyPath:@"video.video_status_id"] longLongValue]] forKey:VZVideoStatusIDKey];
		}
				
		if ([apiResponse valueForKey:@"id"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"id"] longLongValue]] forKey:VZVideoIdKey];
		}
		
		if ([apiResponse valueForKey:@"state"]) {
			[dict setValue:[apiResponse valueForKey:@"state"] forKey:VZVideoStatusKey];
		}
		
		if ([apiResponse valueForKey:@"type"]) {
			[dict setValue:[apiResponse valueForKey:@"type"] forKey:VZVideoTypeKey];
		}
		
		if ([apiResponse valueForKey:@"version"]) {
			[dict setValue:[NSNumber numberWithDouble:[[apiResponse valueForKey:@"version"] doubleValue]] forKey:VZVideoEmbedVersionKey];
		}
		
		if ([apiResponse valueForKey:@"title"]) {
			[dict setValue:[apiResponse valueForKey:@"title"] forKey:VZVideoStatusKey];
		}
		
		if ([apiResponse valueForKey:@"description"]) {
			[dict setValue:[apiResponse valueForKey:@"description"] forKey:VZVideoDescriptionKey];
		}
		
		if ([apiResponse valueForKey:@"author_name"]) {
			[dict setValue:[apiResponse valueForKey:@"author_name"] forKey:VZUserNameKey];
		}
		
		if ([apiResponse valueForKey:@"author_url"]) {
			[dict setValue:[NSURL URLWithString:[apiResponse valueForKey:@"author_url"]] forKey:VZUserDashboardURLKey];
		}
		
		if ([apiResponse valueForKey:@"author_account"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"author_account"] longLongValue]] forKey:VZAccountIdKey];
		}
		
		if ([apiResponse valueForKey:@"provider_name"]) {
			[dict setValue:[apiResponse valueForKey:@"provider_name"] forKey:VZVideoProviderNameKey];
		}
		
		if ([apiResponse valueForKey:@"provider_url"]) {
			[dict setValue:[NSURL URLWithString:[apiResponse valueForKey:@"provider_url"]] forKey:VZVideoProviderURLKey];
		}
		
		if ([apiResponse valueForKey:@"thumbnail_url"]) {
			[dict setValue:[NSURL URLWithString:[apiResponse valueForKey:@"thumbnail_url"]] forKey:VZVideoThumbnailURLKey];
		}
		
		if ([apiResponse valueForKey:@"thumbnail_width"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"thumbnail_width"] longLongValue]] forKey:VZVideoThumbnailWidthKey];
		}
		
		if ([apiResponse valueForKey:@"thumbnail_height"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"thumbnail_height"] longLongValue]] forKey:VZVideoThumbnailHeightKey];
		}	
		
		if ([apiResponse valueForKey:@"framegrab_url"]) {
			[dict setValue:[NSURL URLWithString:[apiResponse valueForKey:@"framegrab_url"]] forKey:VZVideoFrameGrabURLKey];
		}
		
		if ([apiResponse valueForKey:@"framegrab_width"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"framegrab_width"] longLongValue]] forKey:VZVideoFrameGrabWidthKey];
		}
		
		if ([apiResponse valueForKey:@"framegrab_height"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"framegrab_height"] longLongValue]] forKey:VZVideoFrameGrabHeightKey];
		}
		
		if ([apiResponse valueForKey:@"html"]) {
			[dict setValue:[apiResponse valueForKey:@"html"] forKey:VZVideoEmbedCodeKey];
		}
		
		if ([apiResponse valueForKey:@"width"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"width"] longLongValue]] forKey:VZVideoPlayerWidthKey];
		}
		
		if ([apiResponse valueForKey:@"height"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"height"] longLongValue]] forKey:VZVideoPlayerHeightKey];
		}
		
		if ([apiResponse valueForKey:@"borderless"]) {
			[dict setValue:[NSNumber numberWithBool: [[apiResponse valueForKey:@"borderless"] caseInsensitiveCompare:@"true"] == NSOrderedSame ? YES : NO] 
					forKey:VZVideoPlayerIsBorderless];
		}
		
		if ([apiResponse valueForKey:@"duration"]) { 
			[dict setValue:[NSNumber numberWithDouble:[[apiResponse valueForKey:@"duration"] doubleValue]] forKey:VZVideoDurationKey];
		}
		
		if ([apiResponse valueForKey:@"video_status_id"]) {
			[dict setValue:[NSNumber numberWithLongLong:[[apiResponse valueForKey:@"video_status_id"] longLongValue]] forKey:VZVideoStatusIDKey];
		}
		
		return dict;
		
	} else {
		return nil;
	}
}

-(NSString *)userName:(NSError **)error {
	
	NSDictionary *dict = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[self apiURL] absoluteString], @"test/whoami"]] 
									withParameters:nil
											 error:error];
	
	return [dict valueForKeyPath:@"test.login"];
}



-(BOOL)updateVideoWithId:(NSUInteger)videoId withTitle:(NSString *)title description:(NSString *)videoDescription error:(NSError **)error {
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (title != nil) {
		[parameters setValue:title forKey:@"title"];
	}
	
	if (videoDescription != nil) {
		[parameters setValue:videoDescription forKey:@"description"];
	}
	
	NSError *internalError = nil;
	
	[self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@videos/%d.xml", [[self apiURL] absoluteString], videoId]] 
					withMethod:@"put"
					parameters:[NSDictionary dictionaryWithObject:parameters forKey:@"video"]
						 error:&internalError];
	
	if (error != NULL) {
		*error = internalError;
	}
	
	return internalError == nil;
}

-(BOOL)deleteVideoWithId:(NSUInteger)videoId error:(NSError **)error {
	
	NSError *internalError = nil;
	
	[self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@videos/%d.xml", [[self apiURL] absoluteString], videoId]] 
					withMethod:@"delete"
					parameters:nil
						 error:&internalError];
	
	if (error != NULL) {
		*error = internalError;
	}
	
	return internalError == nil;
}

-(id <VZVideoUploader>)beginUploadOfVideoWithTitle:(NSString *)title
									   description:(NSString *)videoDescription
										   profile:(VzaarVideoProfile)videoProfile
										  filePath:(NSString *)location
							  replacingVideoWithId:(NSUInteger)existingVideoId
							   allowUntrustedFiles:(BOOL)allowUntrusted
										  delegate:(id <VZVideoUploadDelegate>)delegate {
	
	if (![Vzaar fileIsAccepted:location]) {
	
		[delegate uploader:nil
	  didFailToUploadVideo:location
				 withError:[NSError errorWithDomain:kVZFileUnsupportedError
											   code:0
										   userInfo:[NSDictionary dictionaryWithObject:kVZFileUnsupportedErrorDescription
																				forKey:NSLocalizedFailureReasonErrorKey]]];
		return nil;
	}
	
	if (!allowUntrusted && ![Vzaar fileIsTrusted:location]) {
		[delegate uploader:nil
	  didFailToUploadVideo:location
				 withError:[NSError errorWithDomain:kVZFileUntrustedError
											   code:0
										   userInfo:[NSDictionary dictionaryWithObject:kVZFileUntrustedErrorDescription
																				forKey:NSLocalizedFailureReasonErrorKey]]];
		return nil;
	}
	
	VzaarAPI10VideoUploader *uploader = [[VzaarAPI10VideoUploader alloc] initWithURL:[self apiURL]
																		  oAuthToken:[self oAuthToken]
																		 oAuthSecret:[self oAuthSecret]];
	
	[uploader beginUploadOfVideoWithTitle:title
							  description:videoDescription
								  profile:videoProfile
								 filePath:location
					 replacingVideoWithId:existingVideoId
								 delegate:delegate];
	
	return [uploader autorelease];
	
}

#pragma mark -
#pragma mark Workers

-(NSDictionary *)videoDictionaryFromAPIVideoListResponseElement:(NSDictionary *)apiVideo {
	
	if (!apiVideo) return nil;
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if ([apiVideo valueForKey:@"version"]) { 
		[dict setValue:[NSNumber numberWithDouble:[[apiVideo valueForKey:@"version"] doubleValue]] forKey:VZAPIVersionKey];
	}
	
	if ([apiVideo valueForKey:@"id"]) {
		[dict setValue:[NSNumber numberWithLongLong:[[apiVideo valueForKey:@"id"] longLongValue]] forKey:VZVideoIdKey];
	}
	
	if ([apiVideo valueForKey:@"title"]) {
		[dict setValue:[apiVideo valueForKey:@"title"] forKey:VZVideoTitleKey];
	}
	
	if ([apiVideo valueForKey:@"created_at"]) {
		[dict setValue:[NSDate dateWithVzaarDateString:[apiVideo valueForKey:@"created_at"]] forKey:VZDateCreatedKey];
	}
	
	if ([apiVideo valueForKey:@"url"]) {
		[dict setValue:[NSURL URLWithString:[apiVideo valueForKey:@"url"]] forKey:VZVideoURLKey];
	}
	
	if ([apiVideo valueForKey:@"thumbnail_url"]) {
		[dict setValue:[NSURL URLWithString:[apiVideo valueForKey:@"thumbnail_url"]] forKey:VZVideoThumbnailURLKey];
	}
	
	if ([apiVideo valueForKey:@"play_count"]) {
		[dict setValue:[NSNumber numberWithLongLong:[[apiVideo valueForKey:@"play_count"] longLongValue]] forKey:VZPlayCountKey];
	}
	
	if ([apiVideo valueForKey:@"duration"]) { 
		[dict setValue:[NSNumber numberWithDouble:[[apiVideo valueForKey:@"duration"] doubleValue]] forKey:VZVideoDurationKey];
	}
	
	if ([apiVideo valueForKey:@"width"]) {
		[dict setValue:[NSNumber numberWithLongLong:[[apiVideo valueForKey:@"width"] longLongValue]] forKey:VZVideoWidthKey];
	}	
	
	if ([apiVideo valueForKey:@"height"]) {
		[dict setValue:[NSNumber numberWithLongLong:[[apiVideo valueForKey:@"height"] longLongValue]] forKey:VZVideoHeightKey];
	}
	
	if ([apiVideo valueForKeyPath:@"user.author_name"]) {
		[dict setValue:[apiVideo valueForKeyPath:@"user.author_name"] forKey:VZUserNameKey];
	}
	
	if ([apiVideo valueForKeyPath:@"user.author_url"]) {
		[dict setValue:[NSURL URLWithString:[apiVideo valueForKeyPath:@"user.author_url"]] forKey:VZUserDashboardURLKey];
	}
	
	if ([apiVideo valueForKeyPath:@"user.author_account"]) {
		[dict setValue:[NSNumber numberWithLongLong:[[apiVideo valueForKeyPath:@"user.author_account"] longLongValue]] forKey:VZAccountIdKey];
	}
	
	if ([apiVideo valueForKeyPath:@"user.video_count"]) {
		[dict setValue:[NSNumber numberWithLongLong:[[apiVideo valueForKeyPath:@"user.video_count"] longLongValue]] forKey:VZVideoCountKey];
	}
	
	if ([apiVideo valueForKey:@"status"]) {
		[dict setValue:[apiVideo valueForKey:@"status"] forKey:VZVideoStatusKey];
	}
	
	if ([apiVideo valueForKey:@"status_id"]) {
		[dict setValue:[apiVideo valueForKey:@"status_id"] forKey:VZVideoStatusIDKey];
	}
	
	return dict;
}


@end
