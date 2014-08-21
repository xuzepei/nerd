//
//  RCPublicCellContentView.h
//  RCTemplate
//
//  Created by xuzepei on 11/25/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCPublicCellContentView : UIView

@property(nonatomic, strong)id item;
@property(nonatomic, strong)NSString* imageUrl;
@property(nonatomic, strong)UIImage* image;
@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)BOOL selected;
@property(nonatomic, strong)NSDictionary* token;

- (void)updateContent:(id)item delegate:(id)delegate token:(NSDictionary*)token;

@end
