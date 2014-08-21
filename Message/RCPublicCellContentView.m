//
//  RCPublicCellContentView.m
//  RCTemplate
//
//  Created by xuzepei on 11/25/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCPublicCellContentView.h"
#import "RCImageLoader.h"

@implementation RCPublicCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)dealloc
{
    self.item = nil;
    self.imageUrl = nil;
    self.image = nil;
    self.delegate = nil;
    self.selected = NO;
    self.token = nil;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateContent:(id)item delegate:(id)delegate token:(NSDictionary*)token
{
    self.item = item;
    self.delegate = delegate;
    self.token = token;
    
    [self setNeedsDisplay];
}

@end
