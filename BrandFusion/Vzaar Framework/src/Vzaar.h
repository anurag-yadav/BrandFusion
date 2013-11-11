//
//  Vzaar.h
//  Vzaar Framework
//
//  Created by Daniel Kennett on 26/04/2010.

//

#import <Foundation/Foundation.h>

@protocol VZVideoUploader;
@protocol VzaarTransport;


static NSString * const kLiveAPIEndPoint = @"https://vzaar.com/api/";
static NSString * const kSandboxAPIEndPoint = @"https://sandbox.vzaar.com/api/";

static NSString * const kVZXMLParseError = @"com.vzaar.xmlParseError";
static NSString * const kVZXMLParseErrorDescription = @"The response from the Vzaar server was invalid. Please try again.";
static NSString * const kVZAPIReturnedIncorrectDataError = @"com.vzaar.apiFailureError";
static NSString * const kVZAPIReturnedIncorrectDataErrorDescription = @"The response from the Vzaar server did not contain the required information. Please try again.";
static NSString * const kVZFileUnsupportedError = @"com.vzaar.fileUnsupportedError";
static NSString * const kVZFileUnsupportedErrorDescription = @"The given file is not supported by the Vzaar API.";
static NSString * const kVZFileUntrustedError = @"com.vzaar.fileUntrustedError";
static NSString * const kVZFileUntrustedErrorDescription = @"The given file is not trusted by the Vzaar API, and only trusted files are allowed.";


/*! 
 @class Constants
 */

/*!
 @enum VzaarAPIVersion
 @brief   Vzaar API versions available in this framework.
 @constant   kVersion1_0 Version 1.0 of the API.
 */
typedef enum {
	kVersion1_0
} VzaarAPIVersion;

enum {
	kDoNotReplaceId = 0
};

/*!
 @enum VzaarVideoProfile
 @brief   Video profiles to dictate how Vzaar should encode the uploaded video.
 @constant   kVideoProfileSmall 
 @constant   kVideoProfileMedium
 @constant   kVideoProfileLarge
 @constant   kVideoProfileHighDefinition
 @constant   kVideoProfileOriginal
 */
typedef enum {
	
	kVideoProfileSmall = 1,
	kVideoProfileMedium = 2,
	kVideoProfileLarge = 3,
	kVideoProfileHighDefinition = 4,
	kVideoProfileOriginal = 5
	
} VzaarVideoProfile;

/*!
 @enum VzaarVideoDetailOption
 @brief   Options for customising the details returned when requesting video details.
 @constant   VzaarVideoDetailOptionBorderless Request a borderless player.
 @constant   VzaarVideoDetailOptionEmbedOnly Request the minimum amount of information required to generate a HTML embed code.
 */
typedef enum {
	
	VzaarVideoDetailOptionBorderless = 0x01,
	VzaarVideoDetailOptionEmbedOnly = 0x02
	
} VzaarVideoDetailOption;
typedef NSUInteger VzaarVideoDetailOptions;

/*!
 @enum VzaarVideoStatus
 @brief   The status of a Vzaar video..
 @constant   VzaarVideoStatusProcessingIncomplete The video is still being encoded.
 @constant   VzaarVideoStatusAvailable The video is available for playback.
 @constant   VzaarVideoStatusExpired The video has expired.
 @constant   VzaarVideoStatusOnHold The video is on hold for encoding.
 @constant   VzaarVideoStatusEncodingFailed Video encoding failed.
 @constant   VzaarVideoStatusEncodingUnavailable Video encoding is unavailable.
 @constant   VzaarVideoStatusReplaced The video has been replaced with another video.
 @constant   VzaarVideoStatusDeleted The video has been deleted.
 */
typedef enum {
	
	VzaarVideoStatusProcessingIncomplete = 1,
	VzaarVideoStatusAvailable = 2,
	VzaarVideoStatusExpired = 3,
	VzaarVideoStatusOnHold = 4,
	VzaarVideoStatusEncodingFailed = 5,
	VzaarVideoStatusEncodingUnavailable = 6,
	VzaarVideoStatusReplaced = 8,
	VzaarVideoStatusDeleted = 9
	
} VzaarVideoStatus;

#pragma mark -
#pragma mark Generic Dictionary Keys

static NSString * const VZAPIVersionKey = @"version";
static NSString * const VZDateCreatedKey = @"created_at";
static NSString * const VZPlayCountKey = @"play_count";

#pragma mark -
#pragma mark User Information Dictionary Keys

static NSString * const VZUserNameKey = @"author_name";
static NSString * const VZUserIdKey = @"author_id";
static NSString * const VZUserDashboardURLKey = @"author_url";

#pragma mark -
#pragma mark Video Information Dictionary Keys

static NSString * const VZVideoCountKey = @"video_count";
static NSString * const VZVideoIdKey = @"id";
static NSString * const VZVideoTitleKey = @"title";
static NSString * const VZVideoDescriptionKey = @"description";
static NSString * const VZVideoURLKey = @"url";
static NSString * const VZVideoThumbnailURLKey = @"thumbnail";
static NSString * const VZVideoThumbnailWidthKey = @"thumbnail_width";
static NSString * const VZVideoThumbnailHeightKey = @"thumbnail_height";
static NSString * const VZVideoFrameGrabURLKey = @"framegrab_url";
static NSString * const VZVideoFrameGrabWidthKey = @"framegrab_width";
static NSString * const VZVideoFrameGrabHeightKey = @"framegrab_height";
static NSString * const VZVideoWidthKey = @"width";
static NSString * const VZVideoHeightKey = @"height";
static NSString * const VZVideoDurationKey = @"duration";
static NSString * const VZVideoTypeKey = @"type";
static NSString * const VZVideoEmbedVersionKey = @"oEmbedVersion";
static NSString * const VZVideoProviderNameKey = @"provider_name";
static NSString * const VZVideoProviderURLKey = @"provider_url";
static NSString * const VZVideoEmbedCodeKey = @"html";
static NSString * const VZVideoPlayerWidthKey = @"player_width";
static NSString * const VZVideoPlayerHeightKey = @"player_height";
static NSString * const VZVideoStatusKey = @"state";
static NSString * const VZVideoStatusIDKey = @"video_status_id";
static NSString * const VZVideoPlayerIsBorderless = @"player_borderless";

#pragma mark -
#pragma mark Account Information Dictionary Keys

static NSString * const VZAccountIdKey = @"account_id";
static NSString * const VZAccountTitleKey = @"title";
static NSString * const VZAccountBandwidthKey = @"bandwidth";
static NSString * const VZAccountMonthlyCostKey = @"monthly";
static NSString * const VZAccountBillingCurrencyKey = @"currency";
static NSString * const VZAccountAllowsBorderlessPlayerKey = @"borderless";
static NSString * const VZAccountAllowsSearchEnhancerKey = @"searchenhancer";


/*! 
 @endclass Constants
 */

#pragma mark -
#pragma mark APIs

/*!
 @protocol VZVideoUploadDelegate
 @brief    Delegate protocol for receiving video upload progress information.
 
 When uploading a video, pass an object the conforms to this protocol to receive updates on the upload progress.
 */
@protocol VZVideoUploadDelegate <NSObject>

/*!
 @param uploader The video uploader object.
 @param progress The progress of the upload between 0.0 (nothing uploaded) to 1.0 (complete).
 @brief Called to allow you to update upload progress UI.
 
 This method will be called at arbitrary points during the file upload process.
 */
-(void)uploader:(id <VZVideoUploader>)uploader didUploadDataWithProgress:(double)progress;

/*!
 @param uploader The video uploader object. Can be nil if the error happened before the upload started.
 @param videoPath The path of the video that failed.
 @param error The cause of the failure.
 @brief Called when the upload fails for any reason.
 
 This method will be called if the upload fails for any reason, including being cancelled.
 */
-(void)uploader:(id <VZVideoUploader>)uploader didFailToUploadVideo:(NSString *)videoPath withError:(NSError *)error;

/*!
 @param uploader The video uploader object.
 @param videoPath The path of the video that failed.
 @param videoId The Vzaar video ID for the new video.
 @brief Called when the upload succeeds.
 
 This method will be called when the upload succeeds. Note: The video may not be immediately available for playback if 
 Vzaar needs to encode the video. Use detailsOfVideoWithId:options:error: to find out the status of the video.
 */
-(void)uploader:(id <VZVideoUploader>)uploader didUploadVideo:(NSString *)videoPath withVideoId:(NSUInteger)videoId;

@end

/*!
 @protocol VZVideoUploader
 @brief    An abstract protocol for video uploader objects. 
 
 When beginning a video upload, you'll be provided with an object that conforms to this protocol. 
 You can use this to cancel theupload if needed.
 */
@protocol VZVideoUploader <NSObject>

/*!
 @property  delegate
 @brief This uploader's delegate.  
 */
@property (readwrite, assign, nonatomic) id <VZVideoUploadDelegate> delegate;

/*!
 @property  sourceFileLocation
 @brief The location of the video being updated.
 */
@property (readonly, copy, nonatomic) NSString *sourceFileLocation;

/*!
 @property  uploadedVideoId
 @brief Once the upload is complete, the Vzaar ID for the video. This propery is KVO-compliant.   
 */
@property (readonly, nonatomic) NSUInteger uploadedVideoId;

/*!
 @brief   Cancel the upload.
 
 This method will cancel this uploader's upload, and the delegate's uploader:didFailToUploadVideo:withError:
 method will be called.
 */
-(void)cancel;

@end

/*!
 @class Vzaar
 @brief    Class for interacting with the Vzaar API.
 
 The Vzaar class provides methods to interact with the Vzaar API, including video upload. 
 */

@interface Vzaar : NSObject {
	
	VzaarAPIVersion apiVersion;
	id <VzaarTransport> transport;
	BOOL allowUntrustedFiles;
	
	NSString *oAuthSecret;
	NSString *oAuthToken;
	NSURL *apiURL;
}

/*!
 @result A BOOL value determining if the given file is accepted by the Vzaar API.
 @brief   Determine if a file is accepted by the Vzaar API.
 */
+(BOOL)fileIsAccepted:(NSString *)filePath;

/*!
 @result An array containing a list of file extensions accepted by the Vzaar API.
 @brief   Determine if a file is trusted by the Vzaar API.
 */
+(NSArray *)acceptedFileExtensions;

/*!
 @result A BOOL value determining if the given file is trusted by the Vzaar API.
 @brief   Determine if a file is trusted by the Vzaar API.
 */
+(BOOL)fileIsTrusted:(NSString *)filePath;

/*!
 @result An array containing a list of file extensions trusted by the Vzaar API.
 @brief   Determine if a file is trusted by the Vzaar API.
 */
+(NSArray *)trustedFileExtensions;

/*!
 @result The created Vzaar API object.
 @brief   Create a Vzaar API object with the default endpoint URL and no authentication.
 
 This method will create a Vzaar API object with the default endpoint URL (the live
 API endpoint) and no authentication details.
 */
-(id)init;


/*!
 @param apiEndpoint An NSURL pointing to the required endpoint.
 @result The created Vzaar API object.
 @brief   Create a Vzaar API object with the given endpoint URL and no authentication.
 
 This method will create a Vzaar API object with the given endpoint URL and no authentication details.
 */
-(id)initWithURL:(NSURL *)apiEndpoint;


/*!
 @param secret Your Vzaar authentication secret - typically your user name.
 @param token You Vzaar authentication token.
 @result The created Vzaar API object.
 @brief   Create a Vzaar API object authenticated with the given credentials.
 
 This method will create a Vzaar API object with the default endpoint URL (the live
 API endpoint) and the given authentication details.
 */
-(id)initWithoAuthSecret:(NSString *)secret oAuthToken:(NSString *)token;

/*!
 @param apiEndpoint An NSURL pointing to the required endpoint.
 @param secret Your Vzaar authentication secret - typically your user name.
 @param token You Vzaar authentication token.
 @result The created Vzaar API object.
 @brief   Create a Vzaar API object with the given endpoint URL authenticated with the given credentials.
 
 This method will create a Vzaar API object with the given endpoint URL and the given authentication details.
 */
-(id)initWithURL:(NSURL *)apiEndpoint oAuthSecret:(NSString *)secret oAuthToken:(NSString *)token;

/*!
 @param apiEndpoint An NSURL pointing to the required endpoint.
 @param secret Your Vzaar authentication secret - typically your user name.
 @param token You Vzaar authentication token.
 @param version The API version to use.
 @result The created Vzaar API object.
 @brief   Create a Vzaar API object with the given endpoint URL authenticated with the given credentials and using the given API version.
 
 This method will create a Vzaar API object with the given endpoint URL and the given authentication details, and will
 use the given API version. This is the designated initializer for this class.
 */
-(id)initWithURL:(NSURL *)apiEndpoint oAuthSecret:(NSString *)secret oAuthToken:(NSString *)token APIVersion:(VzaarAPIVersion)version;

/*!
 @param username The user you'd like to get information for.
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result An NSDictionary containing details of the given user.
 @brief   Get information about a given user.
 
 This method will return an NSDictionary containing the following keys. See   for definitions.
 VZAPIVersionKey, VZUserNameKey, VZUserIdKey, VZUserDashboardURLKey, VZAccountIdKey, VZPlayCountKey, VZVideoCountKey, VZDateCreatedKey
 
 */
-(NSDictionary *)userDetailsForUsername:(NSString *)username error:(NSError **)error;

/*!
 @param accountId The account ID you'd like to get information for.
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result An NSDictionary containing details of the given account.
 @brief   Get information about a given account.
 
 This method will return an NSDictionary containing the following keys. See   for definitions.
 VZAPIVersionKey, VZVideoCountKey, VZAccountTitleKey, VZAccountBandwidthKey, VZAccountMonthlyCostKey, VZAccountBillingCurrencyKey, VZAccountAllowsBorderlessPlayerKey, VZAccountAllowsSearchEnhancerKey
 
 */
-(NSDictionary *)accountDetailsForAccountWithId:(NSUInteger)accountId error:(NSError **)error;

/*!
 @param userName The user you'd like to get the video list for.
 @param titleFilter A text filter to apply - only videos containing this string int heir title will be returned. Pass nil for no filter.
 @param page The page number to return.
 @param pageLength The number of videos on each page.
 @param reverseSort If YES, the sort order will be reversed from newest first to oldest first.
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result An NSArray containing a list of videos. Can be nil if no videos were returned.
 @brief  Get a list of videos based on the given criteria.
 
 This method will return an NSArray of NSDictionary objects, each containing the following keys. See   for definitions.
 VZAPIVersionKey, VZVideoIdKey, VZVideoTitleKey, VZDateCreatedKey, VZVideoURLKey, VZVideoThumbnailURLKey, VZPlayCountKey, VZVideoDurationKey, VZVideoWidthKey, VZVideoHeightKey, VZUserNameKey, VZUserDashboardURLKey, VZAccountIdKey, VZVideoCountKey
 
 */
-(NSArray *)videosForUser:(NSString *)userName
		  withTitleFilter:(NSString *)titleFilter
					 page:(NSUInteger)page 
		  ofPagesOfLength:(NSUInteger)pageLength 
		 reverseSortOrder:(BOOL)reverseSort 
					error:(NSError **)error;


/*!
 @param videoId The ID of the video to get details for.
 @param options Bit-wise ORed options from VzaarVideoDetailOptions - see   for definitions.
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result An NSDictionary containing details of the given video.
 @brief  Get details for a specific video.
 
 This method will return an NSDictionary object containing the following keys. See   for definitions.
 VZVideoTypeKey, VZVideoEmbedVersionKey, VZVideoTitleKey, VZVideoDescriptionKey, VZUserNameKey, VZUserDashboardURLKey, VZAccountIdKey, VZVideoProviderNameKey,
 VZVideoProviderURLKey, VZVideoThumbnailURLKey, VZVideoThumbnailWidthKey, VZVideoThumbnailHeightKey, VZVideoFrameGrabURLKey, VZVideoFrameGrabWidthKey, 
 VZVideoFrameGrabHeightKey, VZVideoEmbedCodeKey, VZVideoPlayerWidthKey, VZVideoPlayerHeightKey, VZVideoPlayerIsBorderless, VZVideoDurationKey, VZVideoStatusKey
 
 */
-(NSDictionary *)detailsOfVideoWithId:(NSUInteger)videoId options:(VzaarVideoDetailOptions)options error:(NSError **)error;

/*!
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result The username of the user currently authenticated as returned by the Vzaar API. 
 @brief  Get the current username as returned by the Vzaar API.
 
 This method is primarily used to test that you're successfully authenticated with the Vzaar API. 
 */
-(NSString *)userName:(NSError **)error;

/*!
 @param title The title of the video.
 @param videoDescription The description of the video, if any.
 @param videoProfile The VzaarVideoProfile that Zvaar should encode the video to - see   for definitions.
 @param location The path to the file to upload.
 @param existingVideoId If this video is replacing an existing one, pass the old video ID here. Pass kDoNotReplaceId to create a new video.
 @param delegate An object conforming to the VZVideoUploadDelegate protocol to receive progress and success/failure notifications. Can be nil.
 @result An object conforming to the VZVideoUploader protocol allowing cancellation of the upload.
 @brief  Start the upload of a video.
 
 This method will begin uploading the given video to Vzaar, notifying the given delegate of progress, success and failure.
 
 */
-(id <VZVideoUploader>)beginUploadOfVideoWithTitle:(NSString *)title
									   description:(NSString *)videoDescription
										   profile:(VzaarVideoProfile)videoProfile
										  filePath:(NSString *)location
							  replacingVideoWithId:(NSUInteger)existingVideoId
										  delegate:(id <VZVideoUploadDelegate>) delegate;

/*!
 @param videoId The ID of the video to edit.
 @param title The new title - pass nil to leave untouched.
 @param videoDescription The new description - pass nil to leave untouched.
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result A BOOL signifying if the call was successful.
 @brief  Change the title and/or description of a video.
 */
-(BOOL)updateVideoWithId:(NSUInteger)videoId withTitle:(NSString *)title description:(NSString *)videoDescription error:(NSError **)error;

/*!
 @param videoId The ID of the video to delete.
 @param error An NSError pointer, which will be filled with an NSError object should an error occur. Can be nil.
 @result A BOOL signifying if the call was successful.
 @brief  Delete a video from your Vzaar account.
 */
-(BOOL)deleteVideoWithId:(NSUInteger)videoId error:(NSError **)error;

/*!
 @property  apiVersion
 @brief The version of the Vzaar API this instance should run against. See   for definitions. 
 */
@property (nonatomic, readwrite) VzaarAPIVersion apiVersion;

/*!
 @property  apiURL
 @brief The URL this instance should use for requests. See   for predefined URLs.  
 */
@property (nonatomic, readwrite, copy) NSURL *apiURL;

/*!
 @property  oAuthSecret
 @brief The oAuth secret to be used for authentication - typically your Vzaar username.
 */
@property (nonatomic, readwrite, copy) NSString *oAuthSecret;

/*!
 @property  oAuthToken
 @brief The oAuth token used for authentication, obtained from the Vzaar account pages.  
 */
@property (nonatomic, readwrite, copy) NSString *oAuthToken;

/*!
 @property  allowUntrustedFiles
 @brief Whether the Vzaar instance should allow untrusted file formats. Defaults to NO.  
 */
@property (nonatomic, readwrite) BOOL allowUntrustedFiles;

@end
