//
//  RCPublicCell.h
//  RCTemplate
//
//  Created by xuzepei on 11/25/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCPublicCellContentView.h"

@interface RCPublicCell : UITableViewCell

@property(nonatomic,strong)RCPublicCellContentView* myContentView;
@property(nonatomic,weak)id delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contentViewClass:(Class)contentViewClass;
- (void)updateContent:(id)item cellHeight:(CGFloat)cellHeight delegate:(id)delegate token:(id)token;


@end
