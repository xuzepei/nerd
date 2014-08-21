//
//  RCPublicCell.m
//  RCTemplate
//
//  Created by xuzepei on 11/25/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCPublicCell.h"

@implementation RCPublicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contentViewClass:(Class)contentViewClass
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _myContentView = [[contentViewClass alloc]
						  initWithFrame:CGRectMake(0,0,[RCTool getScreenSize].width,0)];
		[self.contentView addSubview: _myContentView];
    }
    return self;
}

- (void)dealloc
{
    self.myContentView = nil;
    self.delegate = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
	_myContentView.selected = selected;
	[_myContentView setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	
	_myContentView.selected = highlighted;
	[_myContentView setNeedsDisplay];
}

- (void)updateContent:(id)item cellHeight:(CGFloat)cellHeight delegate:(id)delegate token:(id)token
{
    CGRect rect = _myContentView.frame;
    rect.size.height = cellHeight;
    _myContentView.frame = rect;
    self.delegate = delegate;
    
	[_myContentView updateContent:item delegate:delegate token:token];
}

@end
