
#import "MyLoginModel.h"

#import "MyLogin.h"

#import "AppDelegate.h"
#import "MySettings.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyLoginModel


@synthesize credentials = _credentials;


- (void)dealloc {
    TT_RELEASE_SAFELY(_credentials);
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MyDatabaseRequestDelegate

- (void)login:(MyLogin *)settings {
	
	if ([settings.username isEqual:@""] || [settings.password isEqual:@""]) {
		// the model stores for all other controllers the credentials in singleton GlobalSettings
		[GlobalSettings save:settings.baseURL withUsername:settings.username withPassword:settings.password withChallenge:settings.challenge withImageQuality:settings.imageQuality];
		
		settings.challenge = @"";
		
		// notify the controller that we are done
		[super didUpdateObject:settings atIndexPath:nil];
	} else {
		NSString* url = [settings.baseURL stringByAppendingString:@"/rest"];
		TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:self];
		
		NSString *request_body = [NSString 
								  stringWithFormat:@"user=%@&password=%@",
								  [settings.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								  [settings.password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
								  ];
		//set request body into HTTPBody.
		request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding];
		
		request.httpMethod = @"POST";
		request.cachePolicy = TTURLRequestCachePolicyNone;
		//request.shouldHandleCookies = NO;
		
		request.contentType = @"application/x-www-form-urlencoded";
		
		id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);    
		
		request.userInfo = settings;
		
		[request send];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLDataResponse* dr = request.response;
	NSData* data = dr.data;

	MyLogin* login = request.userInfo;

	NSString* challenge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	login.challenge = nil;
	login.challenge = [[challenge substringFromIndex: 1] substringToIndex:[challenge length] - 2];
	TT_RELEASE_SAFELY(challenge);
	
	// the model stores for all other controllers the credentials in singleton GlobalSettings
	[GlobalSettings save:login.baseURL withUsername:login.username withPassword:login.password withChallenge:login.challenge withImageQuality:login.imageQuality];
	
	// notify the controller that we are done
	[super didUpdateObject:login atIndexPath:nil];
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	[super didFailLoadWithError:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel

/////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
    return YES;
}

- (BOOL)isLoading {
	return YES;
}


@end
