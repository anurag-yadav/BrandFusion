#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"

@interface VzaarAPI10Transport : NSObject {

	NSURL *apiURL;
	NSString *oAuthSecret;
	NSString *oAuthToken;
}

-(id)initWithURL:(NSURL *)url oAuthToken:(NSString *)token oAuthSecret:(NSString *)secret;

-(NSDictionary *)dictionaryForVzaarResponseData:(NSData *)data error:(NSError **)error;
-(NSDictionary *)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;
-(NSDictionary *)dictionaryForVzaarResponseData:(NSData *)data error:(NSError **)error;
-(NSDictionary *)sendPreparedRequest:(OAMutableURLRequest *)request error:(NSError **)error;
-(NSDictionary *)sendPostRequestToURL:(NSURL *)url withMethod:(NSString *)httpMethod parameters:(NSDictionary *)parameters error:(NSError **)error;

@property (nonatomic, readwrite, copy) NSURL *apiURL;
@property (nonatomic, readwrite, copy) NSString *oAuthSecret;
@property (nonatomic, readwrite, copy) NSString *oAuthToken;

@end
