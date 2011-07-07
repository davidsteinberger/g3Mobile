/*
 * MyThumbsViewController2.m
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 15/3/2011.
 * Copyright (c) 2011 David Steinberger
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 */

#import "MyThumbsViewController2.h"

// RestKit
#import <RestKit/RestKit.h>
#import "RestKit/Three20/RKObjectLoaderTTModel.h"
#import "RKMItem.h"
#import "RKMTree.h"

// Datasource and custom cells (three20)
#import "MyViewController.h"
#import "MyThumbsViewDataSource2.h"
#import "MyAlbumItem.h"
#import "MyAlbumItemCell.h"
#import "MyItem.h"
#import "MyMetaDataItem.h"
#import "MyMetaDataItemCell.h"

// Rest Helper
#import "MyAlbumUpdater.h"
#import "MyItemDeleter.h"

// ViewControllers
#import "AddAlbumViewController.h"
#import "UpdateAlbumViewController.h"
#import "MyViewController.h"

// Settings
#import "MySettings.h"

// Others
#import "Three20UICommon/UIViewControllerAdditions.h"
#import "TTTableViewController+g3.h"
#import "UIImage+cropping.h"
#import "UIImage+scaleAndRotate.h"
#import "Three20UINavigator/private/TTBaseNavigatorInternal.h"
#import "NSData+base64.h"
#import "UIImage+resizing.h"
#import "Overlay.h"

@interface MyThumbsViewController2 ()

/*
 * Return the id of the current selected item. If the album is empty it delivers the id of the
 * album.
 */
- (NSString *)getItemID;

/*
 * Return the entity of the current selected item. If the album is empty it delivers the entity of
 * the album.
 */
- (RKMEntity *)getEntity;

// Removes any existing menu
- (void)removeContextMenu;

// Show/Hide the meta data of an album
- (void)setMetaDataHidden:(BOOL)answer;

// Disable all other buttons on the toolbar
- (void)disableToolbarItemsExceptButton:(UIButton*)button;

// Enable all buttons on the toolbar
- (void)enableToolbarItems;

// Sets the default button with default behavior
- (void)setStandartRightBarButtonItem;

@end

@implementation MyThumbsViewController2

@synthesize itemID = _itemID;
@synthesize selectedAlbumItem = _selectedAlbumItem;

@synthesize backViewOld = _backViewOld;
@synthesize selectedCell = _selectedCell;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelAllRequests];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	TT_RELEASE_SAFELY(_itemID);
	TT_RELEASE_SAFELY(_backViewOld);
	TT_RELEASE_SAFELY(_selectedCell);
	[super dealloc];
}


// Initializes view for given itemID (must be an album id)
- (id)initWithItemID:(NSString *)itemID {
	if ( (self = [self initWithNibName:nil bundle:nil]) ) {
		self.itemID = itemID;
    }

	return self;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController

// Create the datasource. Three20 will automatically start the async load of data!
- (void)createModel {
	self.dataSource = [[[MyThumbsViewDataSource2 alloc]
	                    initWithItemID:self.itemID] autorelease];
    [super createModel];
}


// Reloads the data -> resets the detail-view
- (void)reload {
	[super reload];
}


// Reloads after an action was taken
- (void)reloadViewController:(BOOL)goBack {
    _isInEditingState = NO;
    [self setMetaDataHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];      
    
    if (_isEmpty) {
        goBack = YES;
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }

	RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)[self.dataSource model];
	RKMTree *tree = (RKMTree *)[model.objects objectAtIndex:0];
	RKMEntity *entity = [tree root];

	if (![entity.thumb_url_public isEqualToString:@""] && entity.thumb_url_public != nil) {
		[[TTURLCache sharedCache] removeURL:entity.thumb_url_public fromDisk:YES];
	}
	if (![entity.thumb_url isEqualToString:@""] && entity.thumb_url != nil) {
		[[TTURLCache sharedCache] removeURL:entity.thumb_url fromDisk:YES];
	}

    MyThumbsViewController2* prev = ((MyThumbsViewController2 *)self.ttPreviousViewController);
    [self invalidateView];
    [prev invalidateView];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    TTViewController* viewController;
    if ([viewControllers count] > 1 && goBack) {
        viewController = [viewControllers objectAtIndex:[viewControllers count] - 2];
        [self.navigationController popToViewController:viewController animated:YES];
	}
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self.model
                                   selector:@selector(load) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2 target:prev.model
                                   selector:@selector(load) userInfo:nil repeats:NO];

	// Hide the network spinner ... might be activitated by a helper
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	[self removeContextMenu];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate

// The model has finished loading the data -> set the title of the view
- (void)modelDidFinishLoad:(id <TTModel>)model {
	if ([( (RKObjectLoaderTTModel *)self.model ).objects count] > 0) {
        [((MyThumbsViewDataSource2*)self.dataSource).itemModel load];
		RKMTree *tree = [( (RKObjectLoaderTTModel *)self.model ).objects objectAtIndex:0];
		RKMEntity *entity = [tree root];
		self.title = entity.title;
		[super modelDidFinishLoad:model];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewController

// Support drag-to-refresh functionality (yeah that's cool!)
- (id <UITableViewDelegate>)createDelegate {
	return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}


// Handle the event that the album is empty
- (void)showEmpty:(BOOL)show {
	RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)self.model;
	NSArray *objects = model.objects;

	/*
	 * We expect a tree-resource
	 * Should the resource have only 1 object the load was complete and  no children found
	 * --> empty album
	 */
	if ([objects count] == 1) {
		NSString *title = [_dataSource titleForEmpty];
		NSString *subtitle = [_dataSource subtitleForEmpty];

		if (title.length || subtitle.length) {
			TTErrorView *errorView = [[[TTErrorView alloc] initWithTitle:title
			                                                    subtitle:subtitle
			                                                       image:nil]
			                          autorelease];
			errorView.backgroundColor = _tableView.backgroundColor;

			TTView *buttonMenu = [( (TTTableViewController *)self )buildOverlayMenu];
			[errorView addSubview:buttonMenu];
			[errorView bringSubviewToFront:buttonMenu];

            self.emptyView = errorView;
            self.navigationItem.rightBarButtonItem = nil;
            self->_isEmpty = YES;
		}
		else {
			self.emptyView = nil;
            self->_isEmpty = NO;
		}
		_tableView.dataSource = nil;
		[_tableView reloadData];
	}
	else {
		self.emptyView = nil;
        self->_isEmpty = NO;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

// UIViewController standard init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
		self.title = @"Album View";
		self.variableHeightRows = YES;

		self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
		self.navigationBarStyle = UIBarStyleBlack;
		self.navigationBarTintColor = nil;
		self.wantsFullScreenLayout = NO;
		self.hidesBottomBarWhenPushed = NO;
    }

	return self;
}


// Set row height static to 90
- (void)loadView {
	[super loadView];
    self.tableView.rowHeight = 90;
}


// View has loaded -> add the navigation button
- (void)viewDidLoad {
	if ([self.itemID isEqual:@"1"]) {
		self.navigationItem.leftBarButtonItem
		        = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:
		            UIBarButtonItemStyleBordered
		                                           target:self action:@selector(setSettings)
		           ] autorelease];
	}

	[self setStandartRightBarButtonItem];
    
    self.navigationController.toolbar.barStyle = self.navigationBarStyle;
    [self.navigationController.toolbar sizeToFit];
    
    NSArray* toolbarItems = [Overlay buildToolbarWithDelegate:self];
	[self setToolbarItems:toolbarItems animated:YES]; 
    
    [self setMetaDataHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];      
    [self.navigationController setToolbarHidden:YES animated:YES];
}


// Support landscape mode of iPhone
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return TTIsSupportedOrientation(interfaceOrientation);
}


// If devices is turned we have to reload the data (and re-layout the subviews)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//[self updateTableLayout];
	[self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MyLongPressGestureDelegate

// MyLongPressGestureDelegate that handles long tabs on cell
- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
	// only when gesture was recognized, not when ended
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint gestureStartPoint = [recognizer
		                             locationInView:self.tableView];

		// get reference to the cell
		TTTableViewCell *cell =
		        (TTTableViewCell *)[self.tableView
		                            cellForRowAtIndexPath:[self.tableView
		                                                   indexPathForRowAtPoint:
		                                                   gestureStartPoint]];

		id <MyItem> albumItem =
		        [self.dataSource tableView:self.tableView
		           objectForRowAtIndexPath:[self.tableView
		                                  indexPathForRowAtPoint:gestureStartPoint]];
		self.selectedAlbumItem = albumItem;

		BOOL isAlbum = YES;
		NSString *type = nil;
		CGRect frame;

		if ([cell.object isKindOfClass:[MyAlbumItem class]]) {
			frame = CGRectMake(2,
			                   2,
			                   cell.frame.size.width - 4,
			                   cell.frame.size.height - 4);
			type = ( (MyAlbumItem *)cell.object ).type;
			isAlbum = ([type isEqual:@"album"]) ? YES : NO;
		}
		else {
			frame = CGRectMake(2,
			                   10,
			                   cell.frame.size.width - 4,
			                   75 + 2 * kTableCellSmallMargin - 2);
			isAlbum = YES;
		}

		TTView *backView = [Overlay buildOverlayMenuWithFrame:frame type:isAlbum withDelegate:self];

		// add overlay to cell (it's hidden at this point of time)
		[cell insertSubview:backView atIndex:0];

		// with some delay show the overlay with flip-from-left animation
		NSArray *object = [NSArray arrayWithObjects:cell, backView, nil];
		if (cell != self.selectedCell) {
			[self performSelector:@selector(showView:) withObject:object afterDelay:0.1
			];
		}
		else {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
			                       forView:self.backViewOld cache:YES];
			[UIView setAnimationDuration:1];
			self.backViewOld.hidden = YES;
			[UIView commitAnimations];
			self.selectedCell = nil;
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

// Show/hide details of album above the first album
- (void)toggleEditing:(id)sender {
    _isInEditingState = !_isInEditingState;
    
    if (_isInEditingState) {
        [self setMetaDataHidden:NO];
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self setMetaDataHidden:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}


- (void)setMetaDataHidden:(BOOL)answer {
    MyThumbsViewDataSource2 *ds = (MyThumbsViewDataSource2 *)self.dataSource;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    int childrenCount =
    [[((RKMTree*)[((RKObjectLoaderTTModel *)self.model).objects objectAtIndex:0]).rEntity allObjects] count];
        
    if (childrenCount == 0 || [ds.items count] == 0) {
        return;
    }
    
	if (![[ds.items objectAtIndex:0] isKindOfClass:[MyMetaDataItem class]] && !answer) {
        _isMetaDataShown = YES;
        
		RKObjectLoaderTTModel *model2 = ((RKObjectLoaderTTModel *)((MyThumbsViewDataSource2*)self.dataSource).itemModel);
		RKMItem *item = (RKMItem *)[model2.objects objectAtIndex:0];
        
		MyMetaDataItem *mdItem = [MyMetaDataItem
		                          itemWithTitle:item.rEntity.title
                                  model:item.rEntity
                                  description:item.rEntity.desc
                                  autor:@""
                                  timestamp:[NSDate dateWithTimeIntervalSince1970:[
                                                                                   item.rEntity.created floatValue]]
                                  tags:[item concatenatedTagInfo]];
        
		[ds.items insertObject:mdItem atIndex:0];
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:
		 UITableViewRowAnimationFade];
        
		NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView    scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:
		 UITableViewScrollPositionBottom animated:YES];
    } else if ([[ds.items objectAtIndex:0] isKindOfClass:[MyMetaDataItem class]]) {
        _isMetaDataShown = NO;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        MyThumbsViewDataSource2 *ds = (MyThumbsViewDataSource2 *)self.dataSource;
		//self.navigationItem.rightBarButtonItem.title = @"Show Details";
		[ds.items removeObjectAtIndex:0];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:
		 UITableViewRowAnimationFade];
	}
}


// Shows the context menu via a nice animation
- (void)showView:(NSArray *)object  {
	NSArray *array = (NSArray *)object;
	UIView *cell = [array objectAtIndex:0];
	UIView *view = [array objectAtIndex:1];

	// remove any existing overlay
	if (self.backViewOld != view) {
		[self.backViewOld removeFromSuperview];
	}

	[cell bringSubviewToFront:view];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
	                       forView:view cache:YES];
	[UIView setAnimationDuration:1];
	view.hidden = NO;
	[UIView commitAnimations];

	self.selectedCell = cell;
	self.backViewOld = view;

	return;
}


// Removes any existing menu
- (void)removeContextMenu {
	if (self.backViewOld) {
		[self.backViewOld removeFromSuperview];
		self.selectedCell = nil;
	}
}


// Shows the Login page with all the settings
- (void)setSettings {
	TTNavigator *navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"]
	                          applyAnimated:YES]];
}


// Handles initiates the camera/upload
- (void)uploadImage:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;

	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet addButtonWithTitle:@"Camera"];
	[actionSheet addButtonWithTitle:@"Library"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 2;
	
    if (_isEmpty) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];   
    }
}


// Handles the creation of a new album
- (void)createAlbum:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;

	NSString *itemID = [self getItemID];
	AddAlbumViewController *addAlbum =
	        [[AddAlbumViewController alloc] initWithParentAlbumID:itemID andDelegate:self];
	[self.navigationController pushViewController:addAlbum animated:YES];
	TT_RELEASE_SAFELY(addAlbum);

	[self removeContextMenu];
}


// Handles the modification of an album
- (void)editAlbum:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;

	NSString *itemID = [self getItemID];

	UpdateAlbumViewController *updateAlbum =
	        [[UpdateAlbumViewController alloc] initWithAlbumID:itemID andDelegate:self];
	[self.navigationController pushViewController:updateAlbum animated:YES];
	TT_RELEASE_SAFELY(updateAlbum);

	[self removeContextMenu];
}


// Handles comments for items
- (void)comment:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;

	NSString *itemID = [self getItemID];

	TTNavigator *navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://comments/"
	                                                          stringByAppendingString:itemID]]
	                          applyAnimated:YES]];

	[self removeContextMenu];
}


// Makes the current item the cover
- (void)makeCover:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;

	// Immediately show the network spinner as this can be lengthy ...
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)[self.dataSource model];
	RKMTree *tree = (RKMTree *)[model.objects objectAtIndex:0];
	RKMEntity *entity = [tree root];
	NSString *albumID = entity.itemID;

	MyAlbumUpdater *updater = [[MyAlbumUpdater sharedMyAlbumUpdater] initWithItemID:albumID andDelegate:self];
	[updater setValue:[[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"]
	                   stringByAppendingString:[self getItemID]] param:@"album_cover"];
	[updater update];
//	TT_RELEASE_SAFELY(updater);

//	[( (id < MyViewController >)self ) reloadViewController:NO];
}


// Saves the current item to the iPhone
- (void)save:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;

	// Immediately show the network spinner as this can be lengthy ...
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	RKMEntity *entity = [self getEntity];

	// fetch the image from the server
	TTURLRequest *request = [TTURLRequest
	                         requestWithURL:entity.resize_url
	                               delegate:self];

	//set http-headers
	[request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

	request.cachePolicy = TTURLRequestCachePolicyNone;

	TTURLImageResponse *response = [[TTURLImageResponse alloc] init];
	request.response = response;
	TT_RELEASE_SAFELY(response);

	[request send];
}


// Confirms via dialog that the current item should be deleted
- (void)deleteCurrentItem:(id)sender {
	// Set button to selected
	UIButton *button = (UIButton *)sender;
	button.selected = !button.selected;
    
    RKMEntity* entity = [self getEntity];
    
	UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
	dialog.delegate = self;
	dialog.title = @"Confirm Deletion";
    dialog.message = [[@"Do you really want to delete this " 
                       stringByAppendingString:entity.type] 
                      stringByAppendingString:@"?"];
	[dialog addButtonWithTitle:@"Cancel"];
	[dialog addButtonWithTitle:@"OK"];
	[dialog show];
}


// Deletes Item
- (void)deleteCurrentItem {
	NSString *itemID = [self getItemID];

    TTTableViewCell *cell = (TTTableViewCell *)self.selectedCell;
    
	[MyItemDeleter initWithItemID:itemID];

    if (cell == nil) {
        [( (id < MyViewController >)self ) reloadViewController:YES];    
    } else {
        [( (id < MyViewController >)self ) reloadViewController:NO];
    }
}

// Allows to reorder
- (void)reorder: (id)sender {
    [self setMetaDataHidden:YES];
    [self.navigationController setToolbarHidden:NO];
    
    [self disableToolbarItemsExceptButton:sender];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:
                                                                UIBarButtonItemStyleBordered
                                                                              target:self action:@selector(reorderDone:)
                                                                ] autorelease]; 
    
    [self.tableView setEditing:YES animated:YES];
}

- (void)reorderDone: (id)sender {
    [self setMetaDataHidden:NO];  
    [self.navigationController setToolbarHidden:NO];
    
    [self enableToolbarItems];
    [self setStandartRightBarButtonItem];
    [self.tableView setEditing:NO animated:YES];
}

- (void)disableToolbarItemsExceptButton:(UIButton*)button {
    for (UIBarButtonItem* item in self.toolbarItems) {
        if (item.customView != button) {
            item.enabled = NO;   
        }
    }
}

- (void)enableToolbarItems {
    for (UIBarButtonItem* item in self.toolbarItems) {
        item.enabled = YES;   
    }
}

- (void)setStandartRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toggleEditing:)] autorelease];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate

// Takes action based on alertview
- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView isKindOfClass:[UIAlertView class]]) {
		if (buttonIndex == 1) {
			// start the indicator ...
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[self performSelector:@selector(deleteCurrentItem) withObject:Nil
			           afterDelay:0.05];
		}
	}
}


- (NSString *)getItemID {
	TTTableViewCell *cell = (TTTableViewCell *)self.selectedCell;

	if ([[cell.object class] conformsToProtocol:@protocol(MyItem)]) {
		id <MyItem> item = cell.object;
		return item.model.itemID;
	}
	else {
		RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)[self.dataSource model];
		RKMTree *tree = (RKMTree *)[model.objects objectAtIndex:0];
		RKMEntity *entity = [tree root];
		return entity.itemID;
	}
	return nil;
}


- (RKMEntity *)getEntity {
	TTTableViewCell *cell = (TTTableViewCell *)self.selectedCell;

	if ([[cell.object class] conformsToProtocol:@protocol(MyItem)]) {
		id <MyItem> item = cell.object;
		return item.model;
	}
	else {
		RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)[self.dataSource model];
		RKMTree *tree = (RKMTree *)[model.objects objectAtIndex:0];
		RKMEntity *entity = [tree root];
		return entity;
	}
	return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    NSMutableDictionary* query = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
     self, @"delegate",
     [self getItemID], @"albumID",
     nil] autorelease];
    
    if (buttonIndex == 0) {
        [query setValue:@"UIImagePickerControllerSourceTypeCamera" forKey:@"sourceType"];
	}
    if (buttonIndex == 1) {
        [query setValue:@"UIImagePickerControllerSourceTypeSavedPhotosAlbum" forKey:@"sourceType"];
    }
    if (buttonIndex == 2) {
        return;
    }
    [[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:
                                              @"tt://nib/MyUploadViewController"]
                                             applyQuery:query] applyAnimated:YES]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate

/*
 * So far only used to fetch images
 * -> Save them to the camera roll
 */
- (void)requestDidFinishLoad:(TTURLRequest *)request {
	TTURLImageResponse *response = request.response;
	UIImageWriteToSavedPhotosAlbum(response.image, nil, nil, nil);

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self removeContextMenu];
}


@end