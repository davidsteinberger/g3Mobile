
#import "MyCommentsModel.h"

#import "MyComment.h"

#import <extThree20JSON/extThree20JSON.h>
#import "AppDelegate.h"

#import <CommonCrypto/CommonDigest.h>

NSString *md5 (NSString *str) {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", 
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyCommentsModel

@synthesize searchQuery = _searchQuery;
@synthesize itemID		= _itemID;
@synthesize comments    = _comments;
@synthesize userDetails = _userDetails;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
	if (self = [super init]) {
		self.searchQuery = searchQuery;
		self.comments = [NSMutableArray array];
		self->_count = 0;		
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
	self.searchQuery = nil;
	self.itemID = nil;
	self.comments = nil;
	self.userDetails = nil;
	
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark --
#pragma mark TTModel methods

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	self->_cacheExpirationAge = TT_DEFAULT_CACHE_EXPIRATION_AGE;
	
	done = NO;
	loading = YES;
	
	if (cachePolicy == TTURLRequestCachePolicyNetwork) {
		self->_cacheExpirationAge = 0;
		self.comments = nil;
		self.comments = [NSMutableArray array];
	}
	
	if (self.isLoading && TTIsStringWithAnyText(_searchQuery)) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString* url = [NSString stringWithString:_searchQuery];

		TTURLRequest* request = [TTURLRequest
							 requestWithURL: url
							 delegate: self];

		//set http-headers
		[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
		[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	

		request.cacheExpirationAge = self->_cacheExpirationAge;

		TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);
		
		request.userInfo = @"comments";

		[request send];
	}
}

- (BOOL)isLoaded {
	return done;
}

- (BOOL)isLoading {
	return loading;
}

- (void)loadMembers:(NSString* )url {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
    request.cacheExpirationAge = self->_cacheExpirationAge;
	
    TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
	
	request.userInfo = @"members";
	
    [request send];
}

- (void)getUserDetails:(NSString* )author_id {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	TTURLRequest* request = [TTURLRequest
                             requestWithURL: [[appDelegate.baseURL stringByAppendingString:@"/rest/user/"] stringByAppendingString:author_id]
                             delegate: self];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	request.cacheExpirationAge = self->_cacheExpirationAge;
	
	TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
	
	request.userInfo = @"userDetails";
	
    [request sendSynchronously];	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {

	NSString* userInfo = ((NSString*)request.userInfo);
	
	if ([userInfo isEqualToString: @"comments"]) {
		TTURLJSONResponse* response = request.response;
		NSDictionary* feed = response.rootObject;
		
		NSMutableArray* members = [feed objectForKey:@"members"];		
		_memberCount = [members count];
		
		for (NSString *member in members) {
			NSString* commentsURL = member;
			commentsURL = [commentsURL stringByAddingPercentEscapesUsingEncoding:
						   NSASCIIStringEncoding];
			[self loadMembers:commentsURL];
		}
	} else if ([userInfo isEqualToString: @"members"]) {
		_count++;
		TTURLJSONResponse* response = request.response;
		NSDictionary* feed = response.rootObject;
		
		if ([feed count] == 0) {
			return;
		}
		
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
		NSString* tmpEmail = [entries objectForKey:@"guest_email"];
		
		if ((NSNull*)tmpName == [NSNull null] || (NSNull*)tmpEmail == [NSNull null]) {
			// get user-name from user_rest			
			if ((NSNull*)tmpAuthorID != [NSNull null]) {
				[self getUserDetails:tmpAuthorID];
				NSDictionary* otherValues = self.userDetails;
				post.name = [otherValues objectForKey:@"display_name"];
				post.avatar_url = [otherValues objectForKey:@"avatar_url"];
			} else {
				post.name = @"Unknown User";
				post.avatar_url = @"bundle://defaultPerson.png";
			}
		} else if ((NSNull*)tmpEmail != [NSNull null]) {
			post.name = @"Unknown User";
			post.avatar_url = @"bundle://defaultPerson.png";
		}
		
		[self.comments addObject:post];
		[post release];
	} else if ([userInfo isEqualToString: @"userDetails"]) {
		TTURLJSONResponse* response = request.response;
		NSDictionary* feed = response.rootObject;
		
		NSDictionary* entity = [feed objectForKey:@"entity"];
		NSString* tmpDisplayName = [entity objectForKey:@"display_name"];
		NSString* tmpAvatarUrl = [entity objectForKey:@"avatar_url"];
		
		if ((NSNull*)tmpDisplayName == [NSNull null]) {
			tmpDisplayName = @"Unknown User";
		}
		
		if ((NSNull*)tmpAvatarUrl == [NSNull null]) {
			tmpAvatarUrl = @"bundle://defaultPerson.png";
		}
		
		NSDictionary* array = [[NSDictionary alloc] initWithObjectsAndKeys:
							   tmpDisplayName, @"display_name", tmpAvatarUrl, @"avatar_url", nil];
		
		self.userDetails = array;
		
		TT_RELEASE_SAFELY(array);
		return;
	}

	if(_memberCount == _count) {
		_count = 0;
		done = YES;
		loading = NO;
		[self didFinishLoad];
	}
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

