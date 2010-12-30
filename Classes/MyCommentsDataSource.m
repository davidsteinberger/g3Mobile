#import "MyCommentsDataSource.h"

#import "MyCommentsModel.h"
#import "MyComment.h"

#import "MyItemDeleter.h"

// Three20 Additions
#import <Three20Core/NSDateAdditions.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyCommentsDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
  if (self = [super init]) {
    _model = [[MyCommentsModel alloc] initWithSearchQuery:searchQuery];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
	//[_model release];

	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [NSMutableArray arrayWithCapacity:[((MyCommentsModel*)_model).comments count]];
	
  for (MyComment* post in ((MyCommentsModel*)_model).comments) {
	  TTTableMessageItem* tmpMessageItem = [TTTableMessageItem itemWithTitle: post.name
                                               caption: nil
                                                  text: post.text
                                             timestamp: post.created
											  imageURL: post.avatar_url
												   URL: nil];
	  [items addObject:tmpMessageItem];
  }
	
  if ([items count] == 0) {
	  [items addObject:[TTTableTextItem itemWithText:@"No Comments Yet!" URL:nil]];
	  _canDelete = NO;
  } else {
	  _canDelete = YES;
  }

	
	self.items = items;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return NSLocalizedString(@"Updating Comments feed...", @"Comments feed updating text");
  } else {
    return NSLocalizedString(@"Loading Comments feed...", @"Comments feed loading text");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return NSLocalizedString(@"No posts found.", @"Comments feed no results");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Sorry, there was an error loading the Comments.", @"");
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
		NSArray *objects = [NSArray arrayWithObjects:indexPath, nil];

		if (_canDelete == NO) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		
		if (indexPath.row < [self.items count]) {
			MyComment* mc = [((MyCommentsModel*)_model).comments objectAtIndex:indexPath.row];
			[MyItemDeleter initWithItemID:[mc.postId stringValue] type:@"comment"];
			[self.items removeObjectAtIndex:indexPath.row];
			[tableView deleteRowsAtIndexPaths:objects
							 withRowAnimation:UITableViewRowAnimationBottom];			
		}
	}
}

@end

