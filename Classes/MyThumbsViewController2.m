//
//  MyThumbsViewController2.m
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyThumbsViewController2.h"
#import "MyThumbsViewDataSource2.h"
#import "MyMetaDataItem.h"
#import "MyMetaDataItemCell.h"
#import "MyAlbumItemCell.h"
#import "MyAlbumItem.h"
#import "MyItemDeleter.h"

#import "AddAlbumViewController.h"
#import "UpdateAlbumViewController.h"
#import "MyAlbumUpdater.h"
#import "MyAlbum.h"
#import "MySettings.h"
#import "MyAlbumItem.h"

#import <RestKit/RestKit.h>
#import "RestKit/Three20/RKRequestTTModel.h"
#import "MyItem.h"
#import "RKMTree.h"
#import "RKMItem.h"
#import "MyTagHelper.h"
#import "UIImage+cropping.h"

@interface MyThumbsViewController2 ()

- (void)tagsDidLoad:(NSArray*)objects;
- (void)toggleMetaData;
- (RKOEntity*)getEntity;
- (NSString*)getItemID;
- (void)controllerDidFinishAction:(BOOL)success;

@end

@implementation MyThumbsViewController2

@synthesize tagHelper = _tagHelper;
@synthesize itemID = _itemID;
@synthesize selectedAlbumItem = _selectedAlbumItem;
@synthesize tags = _tags;
@synthesize showDetails = _showDetails;

@synthesize backViewOld, selectedCell;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Album View";
		self.variableHeightRows = YES;
		
		self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
		self.navigationBarStyle = UIBarStyleBlack;
		self.navigationBarTintColor = nil;
		self.wantsFullScreenLayout = NO;
		self.hidesBottomBarWhenPushed = NO;	
		
		_pickerController = [[UIImagePickerController alloc] init];
		_pickerController.delegate = self;
		if ( [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] == YES) {
			_pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		} else {
			_pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		}
		
		self.tags = [[[NSString alloc] init] autorelease];
		
		self.showDetails = NO;
	}
	
	return self;
}

- (id)initWithItemID:(NSString*)itemID {
	self.itemID = itemID;
	return [self initWithNibName:nil bundle:nil];
}

- (void)modelDidFinishLoad:(id <TTModel>)model {
	RKMTree* response = [((RKRequestTTModel*)self.model).objects objectAtIndex:0];
	RKOEntity* entity = [response.entities objectAtIndex:0];
	
	self.title = entity.title;
	[super modelDidFinishLoad:model];
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_tagHelper);
	TT_RELEASE_SAFELY(_itemID);
	//TT_RELEASE_SAFELY(_selectedAlbumItem);
	TT_RELEASE_SAFELY(_tags);
	TT_RELEASE_SAFELY(backViewOld);
	TT_RELEASE_SAFELY(selectedCell);
	TT_RELEASE_SAFELY(_pickerController);
	[super dealloc];
}

- (void)viewDidLoad {
	
	if ([self.itemID isEqual:@"1"]) {
		self.navigationItem.leftBarButtonItem
		= [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered
										   target:self action:@selector(setSettings)] autorelease];	
	}

	UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem
	= [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return TTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//[self updateTableLayout];
	[self.tableView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
	self.dataSource = [[[MyThumbsViewDataSource2 alloc]
						initWithItemID:self.itemID] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
	return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

- (void)loadView {
	[super loadView];
	
	self.tableView.rowHeight = 90;
}

#pragma mark -
#pragma mark private

- (void)loadTags {
	NSString* itemResourcePath = [[@"" 
									stringByAppendingString:@"/rest/item/"] 
								   stringByAppendingString:self.itemID];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	MyTagHelper* tagHelper = [[MyTagHelper alloc] initWithResourcePath:itemResourcePath delegate:self];
	self.tagHelper = tagHelper;
	TT_RELEASE_SAFELY(tagHelper);
}

- (void)tagsDidLoad:(NSArray*)objects {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString* tags = @"";
	
	for (RKOTag* tag in objects) {
		tags = [[[[tags stringByAppendingString:tag.name] 
				 stringByAppendingString:@" ("]
				stringByAppendingString:tag.count]
				stringByAppendingString:@"), "];
	}
	
	self.tags = tags;
	[self toggleMetaData];
}

- (void)showDetails:(id)sender {
	self.showDetails = !self.showDetails;
	
	if (self.showDetails) {
		self.tags = ((NSNull*)self.tags == [NSNull null]) ? @"No Tags ..." : self.tags;
		[self loadTags];
	} else {
		self.tags = @"";
		[self toggleMetaData];
	}
}

- (void)toggleMetaData {
	MyThumbsViewDataSource2* ds = (MyThumbsViewDataSource2*)self.dataSource;
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
	
	if (self.showDetails) {
		self.navigationItem.rightBarButtonItem.title = @"Hide Details";
		RKRequestTTModel* model2 = (RKRequestTTModel*)[self.dataSource model];
		RKMTree* response = (RKMTree*)[model2.objects objectAtIndex:0];
		RKOEntity* entity = (RKOEntity*)[response.entities objectAtIndex:0];
		
		MyMetaDataItem* mdItem = [MyMetaDataItem 
								  itemWithTitle:entity.title 
								  model: entity
								  description:entity.description
								  autor:@"autor"
								  timestamp:[NSDate dateWithTimeIntervalSince1970:[entity.created floatValue]]
								  tags:self.tags];

		[ds.items insertObject:mdItem atIndex:0];													
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		[mdItem release];
		
		NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	} else {
		self.navigationItem.rightBarButtonItem.title = @"Show Details";
		[ds.items removeObjectAtIndex:0];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
	// only when gesture was recognized, not when ended
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint gestureStartPoint = [recognizer
									 locationInView:self.tableView];
		
		// get reference to the cell
		TTTableViewCell* cell = (TTTableViewCell*)[self.tableView
												   cellForRowAtIndexPath:[self.tableView
																		  indexPathForRowAtPoint:gestureStartPoint]];
		
		id<MyItem> albumItem = [self.dataSource tableView:self.tableView objectForRowAtIndexPath:[self.tableView
																			 indexPathForRowAtPoint:gestureStartPoint]];
		self.selectedAlbumItem = albumItem;
		
		BOOL isAlbum = YES;
		NSString* type = nil;
		CGRect frame;
		
		if ([cell.object isKindOfClass:[MyAlbumItem class]]) {
			frame = CGRectMake(2, 2, cell.frame.size.width - 4, cell.frame.size.height - 4);
			type = ((MyAlbumItem*)cell.object).type;
			isAlbum = ([type isEqual:@"album"]) ? YES : NO;
		} else {
			frame = CGRectMake(2, 10, cell.frame.size.width - 4, 75 + 2 * kTableCellSmallMargin - 2);
			isAlbum = YES;
		}
		
		TTView* backView = [self buildOverlayMenuWithFrame:frame type:isAlbum];
		
		// add overlay to cell (it's hidden at this point of time)
		[cell insertSubview:backView atIndex:0];
		
		// with some delay show the overlay with flip-from-left animation
		NSArray* object = [NSArray arrayWithObjects:cell, backView, nil];
		if (cell != self.selectedCell) {
			[self performSelector:@selector(showView:) withObject:object afterDelay:0.1 ];
		} else {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.backViewOld cache:YES];
			[UIView setAnimationDuration:1];
			self.backViewOld.hidden = YES;
			[UIView commitAnimations];			
			self.selectedCell = nil;
		}
	}
}

- (void)showView:(NSArray*)object  {
	NSArray* array = (NSArray*)object;
	UIView* cell = [array objectAtIndex:0];
	UIView* view = [array objectAtIndex:1];
	
	// remove any existing overlay
	if (self.backViewOld != view) {
		[self.backViewOld removeFromSuperview];
	}
	
	[cell bringSubviewToFront:view];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:YES];
	[UIView setAnimationDuration:1];
	view.hidden = NO;
	[UIView commitAnimations];
	
	self.selectedCell = cell;
	self.backViewOld = view;
	
	return;
}

#pragma mark -
#pragma mark private

- (TTView*)buildOverlayMenuWithFrame:(CGRect)frame type:(BOOL)album {
	// create overlay-view
	TTView* backView = [[TTView alloc]
						initWithFrame:frame];
	
	// style overlay-view
	UIColor* black = RGBCOLOR(158, 163, 172);
	backView.hidden = YES;
	backView.backgroundColor = [UIColor clearColor];
	backView.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
					  [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.8] next:
					   [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
	
	// create buttons
	int buttonHeight = 50;
	int buttonWidth = 50;
	int buttonY = backView.frame.size.height / 2 - (buttonWidth / 2);
	
	if (album) {
		int cntButtons = 5;
		int xDist = backView.frame.size.width / (cntButtons);
		int buttonX = xDist / 2 - (buttonHeight / 2);
		
		UIButton *button1 = [UIButton buttonWithType: UIButtonTypeCustom];
		button1.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button1 setBackgroundImage:[UIImage imageNamed:@"uploadIcon.png"] forState:UIControlStateNormal];
		[button1 addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
		button2.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button2 setBackgroundImage:[UIImage imageNamed:@"addIcon.png"] forState:UIControlStateNormal];
		[button2 addTarget:self action:@selector(createAlbum:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
		button3.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button3 setBackgroundImage:[UIImage imageNamed:@"editIcon.png"] forState:UIControlStateNormal];
		[button3 addTarget:self action:@selector(editAlbum:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
		button5.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button5 setBackgroundImage:[UIImage imageNamed:@"makeCoverIcon.png"] forState:UIControlStateNormal];
		[button5 addTarget:self action:@selector(makeCover:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
		button4.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button4 setBackgroundImage:[UIImage imageNamed:@"trashIcon.png"] forState:UIControlStateNormal];
		[button4 addTarget:self action:@selector(deleteCurrentItem:) forControlEvents:UIControlEventTouchUpInside];
		
		[backView addSubview:button1];		
		[backView addSubview:button2];
		[backView addSubview:button3];
		[backView addSubview:button4];
		[backView addSubview:button5];
	} else {
		int cntButtons = 4;
		int xDist = backView.frame.size.width / (cntButtons);
		int buttonX = xDist / 2 - (buttonHeight / 2);
		
		UIButton *button1 = [UIButton buttonWithType: UIButtonTypeCustom];
		button1.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button1 setBackgroundImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
		[button1 addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
		button2.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button2 setBackgroundImage:[UIImage imageNamed:@"makeCoverIcon.png"] forState:UIControlStateNormal];
		[button2 addTarget:self action:@selector(makeCover:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
		button3.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button3 setBackgroundImage:[UIImage imageNamed:@"saveIcon.png"] forState:UIControlStateNormal];
		[button3 addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
		
		buttonX += xDist;
		UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
		button4.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button4 setBackgroundImage:[UIImage imageNamed:@"trashIcon.png"] forState:UIControlStateNormal];
		[button4 addTarget:self action:@selector(deleteCurrentItem:) forControlEvents:UIControlEventTouchUpInside];
		
		[backView addSubview:button1];
		[backView addSubview:button2];
		[backView addSubview:button3];
		[backView addSubview:button4];
		
	}
	
	return [backView autorelease];
}

- (void)setSettings {
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"] applyAnimated:YES]];
}

- (void)uploadImage:(id)sender {
	[self presentModalViewController:_pickerController animated:YES];
}

- (void)createAlbum:(id)sender {	
	NSString* itemID = [self getItemID];
	AddAlbumViewController* addAlbum = [[AddAlbumViewController alloc] initWithParentAlbumID: itemID delegate: self];
	[self.navigationController pushViewController:addAlbum animated:YES];
	TT_RELEASE_SAFELY(addAlbum);
}

- (void)editAlbum:(id)sender {
	NSString* itemID = [self getItemID];

	//if (![itemID isEqualToString: @"1"]) {
		UpdateAlbumViewController* updateAlbum = [[UpdateAlbumViewController alloc] initWithAlbumID: itemID];
		[self.navigationController pushViewController:updateAlbum animated:YES];	
		TT_RELEASE_SAFELY(updateAlbum);
	//}
}

- (void)comment:(id)sender {
	NSString* itemID = [self getItemID];
	
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://comments/" stringByAppendingString:itemID]] applyAnimated:YES]];
}

- (void)makeCover:(id)sender {
	RKRequestTTModel* model = (RKRequestTTModel*)[self.dataSource model];
	RKMTree* response = (RKMTree*)[model.objects objectAtIndex:0];
	RKOEntity* entity = (RKOEntity*)[response.entities objectAtIndex:0];
	NSString* albumID = entity.id;
	
	MyAlbumUpdater* updater = [[MyAlbumUpdater alloc] initWithItemID:albumID];
	[updater setValue:[[GlobalSettings.baseURL stringByAppendingString: @"/rest/item/"] stringByAppendingString:[self getItemID]] param: @"album_cover"];
	[updater update];
	TT_RELEASE_SAFELY(updater);
	
	[self controllerDidFinishAction:YES];
}

- (void)controllerDidFinishAction:(BOOL)success {
	NSArray* viewControllers = [self.navigationController viewControllers];
	TTViewController* viewController = nil;
	if ([viewControllers count] > 1) {
			viewController = [viewControllers objectAtIndex:[viewControllers count]-2];
			[self.navigationController popToViewController:viewController animated:YES];
			[self performSelector:@selector(reload) withObject:nil afterDelay:0];				
			[viewController performSelector:@selector(reload) withObject:nil afterDelay:1];				
	} else {
		TTNavigator* navigator = [TTNavigator navigator];
		[navigator removeAllViewControllers];
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://album/1"] applyAnimated:YES]];		
	}
}

- (void)reload {
	self.showDetails = YES;
	[super reload];
}

- (void)save:(id)sender {
	RKOEntity* entity = [self getEntity];
	NSURL* imageURL = [NSURL URLWithString:entity.resize_url_public];
		
	NSData   *data = [NSData dataWithContentsOfURL:imageURL];		
	UIImage  *img  = [[UIImage alloc] initWithData:data];		
	
	UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
	TT_RELEASE_SAFELY(img);
}


- (void)deleteCurrentItem:(id)sender {	
	UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
	[dialog setDelegate:self];
	[dialog setTitle:@"Confirm Deletion"];
	[dialog addButtonWithTitle:@"Cancel"];
	[dialog addButtonWithTitle:@"OK"];
	[dialog show];
}

- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isKindOfClass:[UIAlertView class]]) {
		if (buttonIndex == 1) {
			// start the indicator ...
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[self performSelector:@selector(deleteCurrentItem) withObject:Nil afterDelay:0.05];
		}
	}
}

- (void)deleteCurrentItem {
	NSString* itemID = [self getItemID];

	[MyItemDeleter initWithItemID:itemID];

	MyAlbum* g3Album = [[MyAlbum alloc] initWithID:itemID];
	[MyAlbum updateFinishedWithItemURL:[g3Album.albumEntity valueForKey:@"parent"]];
	TT_RELEASE_SAFELY(g3Album);
	
	[self controllerDidFinishAction:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSString*)getItemID {
	TTTableViewCell* cell = (TTTableViewCell*)self.selectedCell;
	
	if ([[cell.object class] conformsToProtocol:@protocol(MyItem) ]) {
		id<MyItem> item = cell.object;
		return item.model.id;
	} else {
		RKRequestTTModel* model = (RKRequestTTModel*)[self.dataSource model];
		RKMTree* response = (RKMTree*)[model.objects objectAtIndex:0];
		RKOEntity* entity = (RKOEntity*)[response.entities objectAtIndex:0];
		return entity.id;
	}
	return nil;
}

- (RKOEntity*)getEntity {
	TTTableViewCell* cell = (TTTableViewCell*)self.selectedCell;

	if ([[cell.object class] conformsToProtocol:@protocol(MyItem) ]) {
		id<MyItem> item = cell.object;
		return item.model;
	} else {
		RKRequestTTModel* model = (RKRequestTTModel*)[self.dataSource model];
		RKMTree* response = (RKMTree*)[model.objects objectAtIndex:0];
		RKOEntity* entity = (RKOEntity*)[response.entities objectAtIndex:0];
		return entity;
	}
	return nil;
}

#pragma mark UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSString* itemID = [self getItemID];
	
	// get high-resolution picture (used for upload)
	UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
	// get screenshot (used for confirmation-dialog)
	UIWindow *theScreen = [[UIApplication sharedApplication].windows objectAtIndex:0];
	UIGraphicsBeginImageContext(theScreen.frame.size);
	[[theScreen layer] renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	screenshot = [UIImage imageByCropping:screenshot
								   toRect:CGRectMake(0, 0, 320, 426)];
	
	// prepare params
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
							self, @"delegate",
							image, @"image",
							screenshot, @"screenShot",
							itemID, @"albumID",
							nil];
	
	[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://nib/MyUploadViewController"]
											 applyQuery:params] applyAnimated:YES]];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}


@end
