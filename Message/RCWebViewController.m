//
//  RCWebViewController.m
//  RCFang
//
//  Created by xuzepei on 4/4/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCWebViewController.h"
#import "RCTool.h"
#import "MBProgressHUD.h"
#import "RCAppDelegate.h"

@interface RCWebViewController ()

@end

@implementation RCWebViewController

- (id)init:(BOOL)hideToolbar
{
    self.hideToolbar = hideToolbar;
    
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UIBarButtonItem* shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"repost"] style:UIBarButtonItemStylePlain  target:self action:@selector(clickedShareButtonItem:)];
        
        UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(clickedRefreshButtonItem:)];

        self.navigationItem.rightBarButtonItems = @[refreshItem,shareItem];
        
        [self initWebView];
        
        //[self initToolbar];
        
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.urlString = nil;
    
    if(self.webView)
        self.webView.delegate = nil;
    self.webView = nil;
    
    self.indicator = nil;
    self.toolbar = nil;
    self.backwardItem = nil;
    self.forwardItem = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self showAdBanner:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdBanner:) name:SHOW_ADBANNER_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdFullScreen:) name:SHOW_FULLSCREENAD_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if(self.webView)
        self.webView.delegate = nil;
    self.webView = nil;
    
    self.indicator = nil;
    self.toolbar = nil;
    self.backwardItem = nil;
    self.forwardItem = nil;
}

- (void)clickedRefreshButtonItem:(id)sender
{
    [self clickRefreshItem:nil];
}

#pragma mark - Share

- (void)clickedShareButtonItem:(id)token
{
    if(nil == self.item)
        return;
    
    NSString* text = self.item.text;
    if(0 == [text length])
        text = @"";
    
    NSString* videourl = self.item.videourl;
    if([videourl length])
        videourl = [NSString stringWithFormat:@"(点链接看视频)%@",videourl];
    else
    {
        NSString* urlString = [NSString stringWithFormat:@"(点链接看详情) http://m.jiecaojie.com/MJieInfo_%@.html?appid=843664556&newappid=843664556&ver=1.5&channel=appstore",self.item.id];
        
        videourl = urlString;
    }
    
    NSString* imageUrl = self.item.imgurl;
    
    NSString* imagePath = [RCTool getImageLocalPath:imageUrl];
    
    id image = [NSData dataWithContentsOfFile:imagePath];
    NSString* message = [NSString stringWithFormat:@"%@%@",text,videourl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMENG_KEY
                                      shareText:message
                                     shareImage:image
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToEmail,UMShareToSms,nil]
                                       delegate:self];
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController");
    
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

#pragma mark -

- (void)updateContent:(NSString *)urlString item:(Item*)item
{
    if(0 == [urlString length])
        return;
    
    self.item = item;
    self.urlString = urlString;

    if(_webView)
    {
//        if([RCTool isOpenAll])
//        {
//            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
//            [_webView loadRequest:request];
//        }
//        else{
        
            if(0 == [self.content length])
            {
                RCHttpRequest* temp = [[RCHttpRequest alloc] init];
                BOOL b = [temp request:_urlString delegate:self resultSelector:@selector(requestHttpContentFinished:) token:nil];
                if(b)
                {
                    if(nil == _indicator2)
                    {
                        _indicator2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        _indicator2.labelText = @"加载中...";
                        [_indicator2 show:YES];
                    }
                    else
                        [_indicator2 show:YES];
                }
            }
            else
            {
                [_webView loadHTMLString:self.content baseURL:[NSURL URLWithString:_urlString]];
            }
            
        }
    //}
}

- (void)requestHttpContentFinished:(NSString*)jsonString
{
    if(self.indicator2)
        [self.indicator2 hide:YES];
    
    if([jsonString length])
    {
        NSString* temp = @"class='cate'>";
        if(NO == [RCTool isOpenAll])
            temp = @"相关推荐</div>";
        NSRange range = [jsonString rangeOfString:temp];
        if(range.location != NSNotFound)
        {
            jsonString = [jsonString substringToIndex:range.location];
            
//            range = [jsonString rangeOfString:@"<div class='more'" options:NSBackwardsSearch|NSCaseInsensitiveSearch];
//            if(range.location != NSNotFound)
//            jsonString = [jsonString substringToIndex:range.location];
        }
    }
    else
        return;
    
    self.content = [NSString stringWithFormat:@"%@</div></div></body></html>",jsonString];
    if([self.content length])
    {
//        NSString *path = [[NSBundle mainBundle] resourcePath];
//        path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
//        path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [_webView loadHTMLString:self.content baseURL:[NSURL URLWithString:_urlString]];
    }
}

#pragma mark - Toolbar

- (void)initToolbar
{
    if (nil == _toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,[RCTool getScreenSize].height - NAVIGATION_BAR_HEIGHT*2 - STATUS_BAR_HEIGHT,[RCTool getScreenSize].width,NAVIGATION_BAR_HEIGHT)];
        
        _toolbar.barStyle = UIBarStyleBlack;
        
        UIBarButtonItem* fixedSpaceItem0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                          target:nil
                                                                                          action:nil];
        fixedSpaceItem0.width = 180;
        
        UIBarButtonItem* fixedSpaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                          target:nil
                                                                                          action:nil];
        fixedSpaceItem1.width = 50;
        
        
//        UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                                                                     target:self
//                                                                                     action:@selector(clickRefreshItem:)];
        
        self.backwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse_backward"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(clickBackwardItem:)];
        _backwardItem.enabled = NO;
        
        self.forwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse_forward"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(clickForwardItem:)];
        
        _forwardItem.enabled = NO;
        
        [_toolbar setItems:[NSArray arrayWithObjects: /*refreshItem,*/fixedSpaceItem0,_backwardItem,fixedSpaceItem1,_forwardItem,nil]
                  animated: NO];

    }
	
	[self.view addSubview:_toolbar];

}

- (void)updateToolbarItem
{
	_backwardItem.enabled = _webView.canGoBack? YES:NO;
	_forwardItem.enabled = _webView.canGoForward? YES:NO;
}

- (void)clickRefreshItem:(id)sender
{
//    if(_webView)
//        [_webView reload];
    
    self.content = nil;
    [self updateContent:self.urlString item:self.item];

}

- (void)clickBackwardItem:(id)sender
{
    if(_webView)
        [_webView goBack];
	
}

- (void)clickForwardItem:(id)sender
{
    if(_webView)
        [_webView goForward];
}

#pragma mark - WebView

- (void)initWebView
{
    if (nil == _webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,[RCTool getScreenSize].width,[RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
        _webView.delegate = self;
    }

    [self.view addSubview: _webView];
    
    if (nil == _indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = CGPointMake([RCTool getScreenSize].width/2.0, [RCTool getScreenSize].height/2.0);
    }
    
    [_webView addSubview: _indicator];
}



#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
	if(request)
	{
		NSURL* url = [request URL];
		NSString* urlString = [url absoluteString];
        
        if(NO == [urlString isEqualToString:self.urlString])
        {
            //url decode
            urlString = [[urlString
                    stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSRange range = [urlString rangeOfString:@"http://m.jiecaojie.com/jieapp_art|" options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound)
            {
                NSString* id = [urlString substringFromIndex:range.location + range.length];
                if([id length])
                {
                    range = [id rangeOfString:@"|"];
                    if(range.location != NSNotFound)
                    {
                        id = [id substringToIndex:range.location];
                        
                        NSString* urlString = [NSString stringWithFormat:@"http://m.jiecaojie.com/MJieInfo_%@.html?appid=843664556&newappid=843664556&ver=1.5&channel=appstore",id];
                        RCWebViewController* temp = [[RCWebViewController alloc] initWithNibName:nil bundle:nil];
                        temp.hideToolbar = YES;
                        [temp updateContent:urlString item:nil];
                        temp.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:temp animated:YES];
                        
                        return NO;
                    }
                }
            }

            
        }
	}
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(nil == _indicator2)
    {
        _indicator2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _indicator2.labelText = @"加载中...";
        [_indicator2 show:YES];
    }
    else
        [_indicator2 show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.indicator2)
        [self.indicator2 hide:YES];
    
//    if(NO == [RCTool isOpenAll])
//    {
//        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('more').style.visibility='hidden'"];
//    }
//    
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('bigbutton').style.visibility='hidden'"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(self.indicator2)
        [self.indicator2 hide:YES];
}


#pragma mark -

- (void)showAdBanner:(NSNotification*)noti
{
    UIView* adView = [RCTool getAdView];
    if(adView)
    {
        CGRect rect = adView.frame;
        rect.origin.y = [RCTool getScreenSize].height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT-adView.bounds.size.height;
        adView.frame = rect;
        
        [self.view addSubview:adView];
    }
}

- (void)showAdFullScreen:(NSNotification*)noti
{
    RCAppDelegate* appDelegate = (RCAppDelegate*)[UIApplication sharedApplication].delegate;
    if(appDelegate)
    {
        [appDelegate showInterstitialAd:self];
    }
}


@end
