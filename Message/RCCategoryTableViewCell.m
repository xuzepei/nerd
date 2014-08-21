//
//  RCCategoryTableViewCell.m
//  Nerd
//
//  Created by xuzepei on 8/19/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCCategoryTableViewCell.h"

@implementation RCCategoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
