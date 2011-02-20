//
//  MyRest.m
//  g3Mobile
//
//  Created by David Steinberger on 1/30/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyRest.h"
#import "Three20/Three20.h"
#import "NSObject+YAJL.h"
#import "extThree20JSON/extThree20JSON.h"
#import "MyRestResource.h"
#import "MySettings.h"

typedef enum {
	kLogin,
	kGet,
	kPost,
	kPut,
	kDelete
} RequestMethod;

@interface MyRest()

@property (nonatomic, readwrite, retain) MyRestResource* restResource;
@property (nonatomic, retain) NSString* baseURL;
@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* challenge;

- (void)request:(NSString*)url withType:(RequestMethod)type andCacheExpiration:(NSTimeInterval)age async:(BOOL)async;
- (void)login;
- (NSString *)urlEncodeValue:(NSString *)str;

@end


@implementation MyRest

@synthesize delegate = _delegate;
@synthesize restResource = _restResource;
@synthesize baseURL = _baseURL;
@synthesize username = _username;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize params = _params;

- (id) init {
	if( self = [super init] ) {
		self.baseURL = GlobalSettings.baseURL;
		//self.baseURL = @"http://192.168.1.89/~David/gallery3/index.php";
		self.challenge = GlobalSettings.challenge;
		
		_params = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithUrl:(NSString*)baseUrl withUser:(NSString*)username andPassword:(NSString*)password {
	if( self = [super init] ) {
		self.baseURL = baseUrl;
		self.username = username;
		self.password = password;
		
		[self login];
		
		_params = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_restResource);
	TT_RELEASE_SAFELY(_baseURL);
	TT_RELEASE_SAFELY(_username);
	TT_RELEASE_SAFELY(_password);
	TT_RELEASE_SAFELY(_challenge);
	TT_RELEASE_SAFELY(_params);
	
	[super dealloc];
}

- (NSString*)login:(NSString*)url withUser:(NSString*)username andPassword:(NSString*)password {
	self.username = username;
	self.password = password;
	
	[self login];
	//self.challenge = @"c3608c34c6fcf2b8824a186904ca5766";
	return [NSString stringWithString:self.challenge];
}

- (void)request:(NSString*)url withType:(RequestMethod)type andCacheExpiration:(NSTimeInterval)age async:(BOOL)async {
	NSString* g3Url = url;

	if (url == nil) {
		g3Url = [GlobalSettings.baseURL stringByAppendingString: @"/rest/tree/1?depth=1"];
	}
	
	TTURLRequest* request = [TTURLRequest
                             requestWithURL: g3Url
                             delegate: self];
	
    //request.cachePolicy = TTURLRequestCachePolicyEtag;
	// cache for 1 week
    request.cacheExpirationAge = age;
	
	TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
	
	switch (type) {
		case kLogin:
			request.httpMethod = @"POST";
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			
			NSString *request_body = [NSString 
									  stringWithFormat:@"user=%@&password=%@",
									  [self.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
									  [self.password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
									  ];
			//set request body into HTTPBody.
			request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding];
			
			id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
			request.response = response;
			TT_RELEASE_SAFELY(response);
			break;
		case kGet:
			request.httpMethod = @"GET";
			if (self.challenge != nil)
				[request setValue:self.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
			//[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			
			//json-encode & urlencode parameters
			NSString *requestString = [self.params yajl_JSONString];
			if (requestString != nil) {
				requestString = [@"entity=" stringByAppendingString:[self urlEncodeValue:requestString]];
				request.httpBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
				//NSLog(@"requestString: %@", requestString);
				
			}
			
			//
			
			break;
		case kPost:
			request.httpMethod = @"POST";
			if (self.challenge != nil)
				[request setValue:self.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
			[request setValue:@"post" forHTTPHeaderField:@"X-Gallery-Request-Method"];
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			break;
		case kPut:
			request.httpMethod = @"POST";
			[request setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			break;
		default:
			break;
	}
	
	request.response = response;
	TT_RELEASE_SAFELY(response);
	
	request.userInfo = [NSString stringWithFormat:@"%d", type ];
	
	if (async == YES) {
		[request send];
	} else {
		[request sendSynchronously];
	}
	
	return;
}

- (void)login {
	//NSLog(@"url: %@", [self.baseURL stringByAppendingString:@"/rest"]);
	[self request:[self.baseURL stringByAppendingString:@"/rest"] withType:kLogin andCacheExpiration:0 async:NO];	
	return;
}

- (MyRestResource*)get:(NSString*)url {
	self.params = nil;
	//TT_DEFAULT_CACHE_EXPIRATION_AGE
	//TTURLRequestCachePolicyNetwork
	[self request:url withType:kGet andCacheExpiration:TT_DEFAULT_CACHE_EXPIRATION_AGE async:NO];

	MyRestResource* copy = [self.restResource copyWithZone:nil];
	
	return [copy autorelease];
}

- (void)get:(NSString*)url withCallback:(id)callback {
	return;
}

- (MyRestResource*)post:(NSString*)url {
	[self request:url withType:kPost andCacheExpiration:0 async:NO];
	
	MyRestResource* copy = [self.restResource copyWithZone:nil];
	
	return [copy autorelease];
}

- (void)post:(NSString*)url withCallback:(id)callback {
	self.delegate = callback;
	[self request:url withType:kPost andCacheExpiration:0 async:YES];
	return;
}

- (void)put:(NSString*)url {
	return;
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	NSLog(@"error: %@", error);
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	//NSLog(@"request.userInfo: %@", request.userInfo);
	if ([request.userInfo isEqual:@"0"]) {
		//NSLog(@"login");
		
		TTURLDataResponse* dr = request.response;
		NSData* data = dr.data;
		
		NSString* challenge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSString* strippedChallenge = [[challenge substringFromIndex: 1] substringToIndex:[challenge length] - 2];

		//NSLog(@"challenge: %@", strippedChallenge);
		[GlobalSettings save:self.baseURL withUsername:self.username withPassword:self.password withChallenge:strippedChallenge withImageQuality:1];
		
		self.challenge = strippedChallenge;		
		TT_RELEASE_SAFELY(challenge);
	}
	if ([request.userInfo isEqual:@"1"]) {
		//NSLog(@"get");
		
		TTURLJSONResponse* response = request.response;
		
		MyRestResource* restResource = [[MyRestResource alloc] init];
		//NSLog(@"rootObject: %@", response.rootObject);
		
		restResource.rootObject = response.rootObject;
		restResource.url = [response.rootObject objectForKey:@"url"];
		restResource.entity = [response.rootObject objectForKey:@"entity"];
		restResource.members = [response.rootObject objectForKey:@"members"];
		restResource.relationships = [response.rootObject objectForKey:@"relationships"];
			
		self.restResource = restResource;
		TT_RELEASE_SAFELY(restResource);
		
		MyRestResource* copy = [self.restResource copyWithZone:nil];
		
		[self.delegate requestDidFinishLoad:[copy autorelease]];
	}
	if ([request.userInfo isEqual:@"2"]) {
		//NSLog(@"post");
		
		TTURLJSONResponse* response = request.response;
		MyRestResource* restResource = [[MyRestResource alloc] init];
		restResource.url = [response.rootObject objectForKey:@"url"];
		restResource.entity = [response.rootObject objectForKey:@"entity"];
		restResource.members = [response.rootObject objectForKey:@"members"];
		restResource.relationships = [response.rootObject objectForKey:@"relationships"];
		
		self.restResource = restResource;
		TT_RELEASE_SAFELY(restResource);
		
		MyRestResource* copy = [self.restResource copyWithZone:nil];
		[self.delegate requestDidFinishLoad:[copy autorelease]];
	}
	if ([request.userInfo isEqual:@"3"]) {
		NSLog(@"put");		
	}
	return;
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
