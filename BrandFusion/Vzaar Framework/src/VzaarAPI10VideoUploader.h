//
//  VzaarAPI10VideoUploader.h
//  Vzaar Framework
//
//  Created by Daniel Kennett on 28/04/2010.

//

#import <Foundation/Foundation.h>
#import "VzaarTransport.h"
#import "VzaarAPI10Transport.h"
#import "Vzaar.h"
#import "ASIHTTPRequest.h"

@interface VzaarAPI10VideoUploader : VzaarAPI10Transport <VZVideoUploader> {
	id <VZVideoUploadDelegate> delegate;
	NSString *sourceFileLocation;
	NSUInteger uploadedVideoId;
	
	NSString *videoTitle;
	NSString *videoDescription;
	VzaarVideoProfile videoProfile;

	ASIHTTPRequest *s3Uploader;

	NSUInteger replacedVideoId;
	NSString *transientUploadGuid;

}

-(void)beginUploadOfVideoWithTitle:(NSString *)title
					   description:(NSString *)desc
						   profile:(VzaarVideoProfile)profile
						  filePath:(NSString *)location
			  replacingVideoWithId:(NSUInteger)existingVideoId
						  delegate:(id <VZVideoUploadDelegate>)del;


@end
