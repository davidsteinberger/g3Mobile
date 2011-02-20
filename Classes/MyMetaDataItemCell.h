//
//  MyMetaDataItemCell.h
//  g3Mobile
//
//  Created by David Steinberger on 2/16/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyMetaDataItem.h"


@interface MyMetaDataItemCell : TTTableViewCell {
	MyMetaDataItem* _item;
	TTImageView* _background;
	
	UILabel* title;
	UILabel* description;
	UILabel* autor;
	UILabel* date;
	UILabel* tags;
}

@property (nonatomic, retain) TTImageView* background;
@property (nonatomic, retain) IBOutlet UILabel* title;
@property (nonatomic, retain) IBOutlet UILabel* description;
@property (nonatomic, retain) IBOutlet UILabel* autor;
@property (nonatomic, retain) IBOutlet UILabel* date;
@property (nonatomic, retain) IBOutlet UILabel* tags;

@end
