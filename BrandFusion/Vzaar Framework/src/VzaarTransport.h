#import <Foundation/Foundation.h>
#import "Vzaar.h"

@protocol VZVideoUploadDelegate;
@protocol VZVideoUploader;

@protocol VzaarTransport <NSObject>

-(NSDictionary *)userDetailsForUsername:(NSString *)username error:(NSError **)error;
-(NSDictionary *)accountDetailsForAccountWithId:(NSUInteger)accountId error:(NSError **)error;

-(NSArray *)videosForUser:(NSString *)userName
		  withTitleFilter:(NSString *)titleFilter
					 page:(NSUInteger)page 
		  ofPagesOfLength:(NSUInteger)pageLength 
		 reverseSortOrder:(BOOL)reverseSort 
					error:(NSError **)error;


-(NSDictionary *)detailsOfVideoWithId:(NSUInteger)videoId options:(VzaarVideoDetailOptions)options error:(NSError **)error;
-(NSString *)userName:(NSError **)error;

-(id <VZVideoUploader>)beginUploadOfVideoWithTitle:(NSString *)title
									   description:(NSString *)videoDescription
										   profile:(VzaarVideoProfile)videoProfile
										  filePath:(NSString *)location
							  replacingVideoWithId:(NSUInteger)existingVideoId
							   allowUntrustedFiles:(BOOL)allowUntrusted
										  delegate:(id <VZVideoUploadDelegate>)delegate;

-(BOOL)updateVideoWithId:(NSUInteger)videoId withTitle:(NSString *)title description:(NSString *)videoDescription error:(NSError **)error;
-(BOOL)deleteVideoWithId:(NSUInteger)videoId error:(NSError **)error;

@end
