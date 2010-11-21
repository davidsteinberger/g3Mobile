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

#import "MyCommentsDataSource.h"

#import "MyCommentsModel.h"
#import "MyComment.h"

// Three20 Additions
#import <Three20Core/NSDateAdditions.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyCommentsDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
  if (self = [super init]) {
    _searchFeedModel = [[MyCommentsModel alloc] initWithSearchQuery:searchQuery];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_searchFeedModel);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _searchFeedModel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [[NSMutableArray alloc] init];
	
  for (MyComment* post in _searchFeedModel.posts) {
    [items addObject:[TTTableMessageItem itemWithTitle: post.name
                                               caption: nil
                                                  text: post.text
                                             timestamp: post.created
											  imageURL: @"http://www.gravatar.com/avatar/543e0e8031b09e7de6f7244cc4b8aac9?s=80"
												   URL: nil]];
  }
	
  if ([items count] == 0) {
	  [items addObject:[TTTableMessageItem itemWithTitle: nil
												 caption: @"No Comments yet"
													text: nil
											   timestamp: nil
												imageURL: nil
													 URL: nil]];
  }
/*	NSString* localImage = @"bundle://defaultPerson.png";
	[items addObject:[TTTableImageItem itemWithText:@"TTTableImageItem" imageURL:localImage
												URL:@"tt://tableItemTest"]];
*/
  self.items = items;
  TT_RELEASE_SAFELY(items);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return NSLocalizedString(@"Updating Facebook feed...", @"Facebook feed updating text");
  } else {
    return NSLocalizedString(@"Loading Facebook feed...", @"Facebook feed loading text");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return NSLocalizedString(@"No posts found.", @"Facebook feed no results");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Sorry, there was an error loading the Facebook stream.", @"");
}


@end

