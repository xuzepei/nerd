//
//  RCSecondTableViewController.m
//  Message
//
//  Created by xuzepei on 8/6/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCSecondTableViewController.h"
#import "RCHttpRequest.h"
#import "RCPublicCell.h"
#import "Item.h"
#import "RCImageDisplayViewController.h"
#import "RCWebViewController.h"
#import "RCAppDelegate.h"
#import "RCImageLoader.h"
#import "RCCategoryTableViewCell.h"
#import "RCThirdViewController.h"

@interface RCSecondTableViewController ()

@end

@implementation RCSecondTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self showAdBanner:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"分类";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdBanner:) name:SHOW_ADBANNER_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdFullScreen:) name:SHOW_FULLSCREENAD_NOTIFICATION object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(clickedRightBarButtonItem:)];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:22]}];
    
    if(nil == _itemArray0)
        _itemArray0 = [[NSMutableArray alloc] init];
    
    [self updateContent];
}

- (void)clickedRightBarButtonItem:(id)sender
{
    [self updateContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Top

- (void)updateContent
{
    
    NSString* urlString = [NSString stringWithFormat:@"%@/GetJieCate.aspx?c=c&ver=1.5&appid=843664556&channel=appstore",BASE_URL];
    
    RCHttpRequest* temp = [[RCHttpRequest alloc] init];
    BOOL b = [temp request:urlString delegate:self resultSelector:@selector(finishedContentRequest:) token:nil];
    if(b)
    {
        if(0 == [self.itemArray0 count])
        {
            [RCTool showIndicator:@"加载中..."];
        }
    }
    
}

- (void)finishedContentRequest:(NSString*)jsonString
{
    [RCTool hideIndicator];
    
    if(0 == [jsonString length])
    {
        return;
    }
    
    NSDictionary* dict = [RCTool parseToDictionary:jsonString];
    NSArray* array = [dict objectForKey:@"list"];
    if([array count])
    {
        [_itemArray0 removeAllObjects];
        [_itemArray0 addObjectsFromArray:array];
        [self.tableView reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemArray0 count];
}

- (CGFloat)getCellHeight:(NSIndexPath*)indexPath
{
    return 86.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellHeight:indexPath];
}

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
    if(indexPath.row >= [_itemArray0 count])
        return nil;
    
    return [_itemArray0 objectAtIndex: indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RCCategoryTableViewCell *cell = (RCCategoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"category_cell_id" forIndexPath:indexPath];
    
    NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath: indexPath];
    if(item && [item isKindOfClass:[NSDictionary class]])
    {
        cell.myLabel.text = [item objectForKey:@"CateName"];
        cell.myDetailLabel.text = [item objectForKey:@"CateContent"];
        cell.myImageView.image = [UIImage imageNamed:@"pic_default"];
        
        NSString* imageUrl = [item objectForKey:@"CatePic"];
        if([imageUrl length])
        {
            UIImage* image = [RCTool getImageFromLocal:imageUrl];
            if(image)
                cell.myImageView.image = image;
            else
            {
                [[RCImageLoader sharedInstance] saveImage:imageUrl
                                                 delegate:self
                                                    token:nil];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)succeedLoad:(id)result token:(id)token
{
	[self.tableView reloadData];
}

#pragma mark -

- (void)showAdBanner:(NSNotification*)noti
{
//    UIView* adView = [RCTool getAdView];
//    if(adView)
//    {
//        CGRect rect = adView.frame;
//        rect.origin.y = self.view.frame.size.height-adView.bounds.size.height;
//        adView.frame = rect;
//        
//        [self.view addSubview:adView];
//    }
}

- (void)showAdFullScreen:(NSNotification*)noti
{
    RCAppDelegate* appDelegate = (RCAppDelegate*)[UIApplication sharedApplication].delegate;
    if(appDelegate)
    {
        [appDelegate showInterstitialAd:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    
    if([segue.identifier isEqualToString:@"to_third_vc"])
	{
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            RCThirdViewController* temp = (RCThirdViewController*)segue.destinationViewController;
            [temp updateContent:item page:1 type:0];
        }
	}
}


@end
