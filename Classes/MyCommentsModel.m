
#import "MyCommentsModel.h"

#import "MyComment.h"

#import <extThree20JSON/extThree20JSON.h>
#import "AppDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyCommentsModel

@synthesize searchQuery = _searchQuery;
@synthesize posts      = _posts;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
  if (self = [super init]) {
    self.searchQuery = searchQuery;
  }
	self.posts = [[NSMutableArray alloc] init];
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_searchQuery);
  TT_RELEASE_SAFELY(_posts);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading && TTIsStringWithAnyText(_searchQuery)) {
	  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	  NSString* url = [NSString stringWithString:_searchQuery];

    TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
	  
	  //set http-headers
	  [request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	  [request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	  
    //request.cachePolicy = cachePolicy | TTURLRequestCachePolicyEtag;
    //request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;

    TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);

    [request sendSynchronously];
  }
}

- (void)loadMembers:(NSString* )url {
	//NSLog(@"Members load");
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
//    request.cachePolicy = cachePolicy | TTURLRequestCachePolicyEtag;
    request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;
	
    TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
	
    [request sendSynchronously];
}

- (NSDictionary* )getUserDetails:(NSString* )author_id {
	//NSLog(@"Members load");
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    // setting up the request object
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:[[appDelegate.baseURL stringByAppendingString:@"/rest/user/"] stringByAppendingString:author_id]]];
	[request setHTTPMethod:@"GET"];
	
	// set needed headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	
	NSDictionary* jsonData = [returnData yajl_JSON];
	NSDictionary* entity = [jsonData objectForKey:@"entity"];
	NSString* tmpDisplayName = [entity objectForKey:@"display_name"];
	NSString* tmpAvatarUrl = [entity objectForKey:@"avatar_url"];
	
	if ((NSNull*)tmpDisplayName == [NSNull null]) {
		tmpDisplayName = @"Unknown User";
	}
	
	if ((NSNull*)tmpAvatarUrl == [NSNull null]) {
		tmpAvatarUrl = @"bundle://defaultPerson.png";
	}
	
	NSDictionary* array = [[[NSDictionary alloc] initWithObjectsAndKeys:
							tmpDisplayName, @"display_name", tmpAvatarUrl, @"avatar_url", nil]
						   autorelease];
	
	//[array setValue:tmpDisplayName forKey:@"display_name"];
	//[array setValue:tmpAvatarUrl forKey:@"avatar_url"];
	
	//NSString* displayName = [NSString stringWithString:tmpDisplayName];
	
	TT_RELEASE_SAFELY(request);
	return array;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLJSONResponse* response = request.response;
  //TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);

  NSDictionary* feed = response.rootObject;
  //TTDASSERT([[feed objectForKey:@"entity"] isKindOfClass:[NSArray class]]); 
	
	if (!self->_parentLoaded) {
		self->_parentLoaded = YES;
		NSMutableArray* members = [feed objectForKey:@"members"];		
		
		for (NSString *member in members) {
			
			NSString* commentsURL = member;
			commentsURL = [commentsURL stringByAddingPercentEscapesUsingEncoding:
						   NSASCIIStringEncoding];
			//NSLog(@"commentsURL: %@", commentsURL);
						
			[self loadMembers:commentsURL];		
		}
	} else {
		NSDictionary* entries = [feed objectForKey:@"entity"];
		MyComment* post = [[MyComment alloc] init];
		
		NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[entries objectForKey:@"created"] floatValue]];
		post.created = date;
		post.postId = [NSNumber numberWithLongLong:
					   [[entries objectForKey:@"id"] longLongValue]];
		post.text = [entries objectForKey:@"text"];
		
		// get the guest-name of the commment
		NSString* tmpName = [entries objectForKey:@"guest_name"];
		NSString* tmpAuthorID = [entries objectForKey:@"author_id"];
		
		if ((NSNull*)tmpName == [NSNull null]) {
			// get user-name from user_rest			
			if ((NSNull*)tmpAuthorID != [NSNull null]) {
				NSDictionary* otherValues = [self getUserDetails:tmpAuthorID];
				post.name = [otherValues objectForKey:@"display_name"];
				post.avatar_url = [otherValues objectForKey:@"avatar_url"];
			} else {
				post.name = @"Unknown User";
				post.avatar_url = @"bundle://defaultPerson.png";
			}
		} else {
			post.name = @"Unknown User";
			post.avatar_url = @"bundle://defaultPerson.png";
		}
		
		[self.posts addObject:post];
		[post release];
	}


  [super requestDidFinishLoad:request];
}

- (void)requestHandler:(id)sender {
	if ([sender isKindOfClass:[NSError class]]) {
		UIAlertView *errorView = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Error sending your info to the server" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		[errorView show];
		[errorView release];
	} else {
		//[avatar setImage:[UIImage imageWithData:sender]];
		[UIImage imageWithData:sender];
	}
}


@end

