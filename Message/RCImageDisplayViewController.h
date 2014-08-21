//
//  RCImageDisplayViewController.h
//  Message
//
//  Created by xuzepei on 8/7/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGIFImage.h"
#import "YLImageView.h"

@class Item;
@interface RCImageDisplayViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView* scrollView;
@property(nonatomic,strong)YLImageView* gifImageView;
@property(nonatomic,strong)Item* theItem;

- (void)updateContent:(Item*)item;

@end
