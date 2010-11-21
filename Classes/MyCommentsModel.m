//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
	  
    request.cachePolicy = cachePolicy | TTURLRequestCachePolicyEtag;
    request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;

    TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);

    [request sendSynchronously];
  }
}

- (void)loadMembers:(NSString* )url {
	NSLog(@"Members load");
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLJSONResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);

  NSDictionary* feed = response.rootObject;
  //TTDASSERT([[feed objectForKey:@"entity"] isKindOfClass:[NSArray class]]); 
	
	if (!self->_parentLoaded) {
		self->_parentLoaded = YES;
		NSMutableArray* members = [[feed objectForKey:@"members"] retain];		
		
		for (NSString *member in members) {
			
			NSString* commentsURL = member;
			commentsURL = [commentsURL stringByAddingPercentEscapesUsingEncoding:
						   NSASCIIStringEncoding];
			NSLog(@"commentsURL: %@", commentsURL);
						
			[self loadMembers:commentsURL];		
		}
	} else {
		NSArray* entries = [feed objectForKey:@"entity"];

		NSMutableArray* posts = [[NSMutableArray alloc] initWithCapacity:[entries count]];
		
		MyComment* post = [[MyComment alloc] init];
		
		NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[entries objectForKey:@"created"] floatValue]];
		post.created = date;
		post.postId = [NSNumber numberWithLongLong:
					   [[entries objectForKey:@"id"] longLongValue]];
		post.text = [entries objectForKey:@"text"];
		post.name = [entries objectForKey:@"author_id"];
		post.name = @"Guest User";
		
		//[gravatar request:@"d.steinberger@gmx.at"];
		
		//NSLog(@"post: %@", post);
		//NSLog(@"post.postId: %@", post.postId);
		//NSLog(@"post.text: %@", post.text);
		
		[self.posts addObject:post];
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

