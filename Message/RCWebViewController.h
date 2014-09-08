//
//  RCWebViewController.h
//  RCFang
//
//  Created by xuzepei on 4/4/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"
#import "Item.h"
#import "RCHttpRequest.h"

@class MBProgressHUD;
@interface RCWebViewController : UIViewController<UIWebViewDelegate,UMSocialUIDelegate>


@property(nonatomic,strong)NSString* urlString;
@property(nonatomic,strong)UIWebView* webView;
@property(nonatomic,strong)UIActivityIndicatorView* indicator;
@property(nonatomic,strong)UIToolbar* toolbar;
@property(nonatomic,strong)UIBarButtonItem* backwardItem;
@property(nonatomic,strong)UIBarButtonItem* forwardItem;
@property(nonatomic,assign)BOOL hideToolbar;
@property(nonatomic,strong)Item* item;
@property(nonatomic,strong)MBProgressHUD* indicator2;
@property(nonatomic,strong)NSString* content;


- (id)init:(BOOL)hideToolbar;
- (void)initToolbar;
- (void)initWebView;
- (void)updateContent:(NSString *)urlString item:(Item*)item;
- (void)updateToolbarItem;

@end
