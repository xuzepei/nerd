//
//  RCFirstTableViewController.m
//  Message
//
//  Created by xuzepei on 8/5/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCFirstTableViewController.h"
#import "RCHttpRequest.h"
#import "RCPublicCell.h"
#import "Item.h"
#import "RCImageDisplayViewController.h"
#import "RCWebViewController.h"
#import "RCAppDelegate.h"
#import "RCSecondTableViewController.h"

@interface RCFirstTableViewController ()

@end

@implementation RCFirstTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:30]}];
    
    [self showAdBanner:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"宅男的福利";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdBanner:) name:SHOW_ADBANNER_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdFullScreen:) name:SHOW_FULLSCREENAD_NOTIFICATION object:nil];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(clickedRightBarButtonItem:)];
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"category"] style:UIBarButtonItemStylePlain target:self action:@selector(clickedLeftBarButtonItem:)];
    
    if([RCTool systemVersion] >= 7.0)
        self.segmentedControl.tintColor = [UIColor clearColor];
    
    [self.segmentedControl setDividerImage:[UIImage imageNamed:@"sg_0"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self.segmentedControl setDividerImage:[UIImage imageNamed:@"sg_1"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    if(nil == _itemArray0)
        _itemArray0 = [[NSMutableArray alloc] init];
    
    if(nil == _itemArray1)
        _itemArray1 = [[NSMutableArray alloc] init];
    
    self.page0 = 1;
    self.page1 = 1;
    self.tryno = 0;
    self.type = 0;
    
    [self updateContent:nil page:1 type:0];
    
    [self initRefreshControl];
}

- (IBAction)clickedLeftBarButtonItem:(id)sender
{
    RCSecondTableViewController* temp = [[RCSecondTableViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:temp animated:YES];
}

- (IBAction)clickedRightBarButtonItem:(id)sender
{
    [self updateContent:nil page:1 type:0];
}

#pragma mark - UISegmentControl

- (IBAction)segmentedControlValueChanged:(id)sender
{
    NSLog(@"segmentedControlValueChanged");
    
    self.type = self.segmentedControl.selectedSegmentIndex;
    
    if(1 == self.type && 0 == [self.itemArray1 count])
        [self updateContent:nil page:1 type:0];
    else if(0 == self.type && 0 == [self.itemArray0 count])
        [self updateContent:nil page:1 type:0];
    
    [self.tableView reloadData];
}

#pragma mark - Refresh Control

- (void)initRefreshControl
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = [RCTool getTextById:@"ti_6"];
    self.tableView.headerReleaseToRefreshText = [RCTool getTextById:@"ti_7"];
    self.tableView.headerRefreshingText = [RCTool getTextById:@"ti_8"];
    
    self.tableView.footerPullToRefreshText = [RCTool getTextById:@"ti_9"];
    self.tableView.footerReleaseToRefreshText = [RCTool getTextById:@"ti_10"];
    self.tableView.footerRefreshingText = [RCTool getTextById:@"ti_11"];
}

- (void)headerRereshing
{
    NSLog(@"headerRereshing");
    
    [self updateContent:nil page:1 type:0];
}

- (void)footerRereshing
{
    NSLog(@"footerRereshing");
    
    if(0 == _type)
        [self updateContent:nil page:self.page0 type:1];
    else
        [self updateContent:nil page:self.page1 type:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Top

- (void)updateContent:(NSString*)timestamp page:(int)page type:(int)type
{
    NSString* cateId = @"0";
    if(1 == _type)
        cateId = @"8";
    
    NSString* urlString = [NSString stringWithFormat:@"%@/GetJieList.aspx?c=c&page=%d&cateID=%@&ver=1.5&appid=843664556&channel=appstore&lasttime=",BASE_URL,page,cateId];
    
    NSDictionary* token = @{@"type":[NSNumber numberWithInt:type],@"page":[NSNumber numberWithInt:page],@"segment_index":[NSNumber numberWithInt:_type]};
    
    RCHttpRequest* temp = [[RCHttpRequest alloc] init] ;
    BOOL b = [temp request:urlString delegate:self resultSelector:@selector(finishedContentRequest:) token:token];
    if(b)
    {
        if(0 == [self.itemArray0 count] && 0 == _type)
        {
            [RCTool showIndicator:@"加载中..."];
        }
        else if(0 == [self.itemArray1 count] && 1 == _type)
        {
            [RCTool showIndicator:@"加载中..."];
        }
    }
}

- (void)finishedContentRequest:(NSDictionary*)result
{
    [RCTool hideIndicator];
    
    NSString* jsonString = [result objectForKey:@"json"];
    NSDictionary* token = [result objectForKey:@"token"];
    int type = [[token objectForKey:@"type"] intValue];
    int segment_index = [[token objectForKey:@"segment_index"] intValue];
    if(0 == type)
    {
        [self.tableView headerEndRefreshing];
    }
    else
    {
        [self.tableView footerEndRefreshing];
    }
    
    if(0 == [jsonString length])
    {
        return;
    }
    
    NSDictionary* dict = [RCTool parseToDictionary:jsonString];
    if(nil == dict || NO == [dict isKindOfClass:[NSDictionary class]])
        return;
    
    NSArray* array = [dict objectForKey:@"list"];
    
    NSMutableArray* itemArray = [[NSMutableArray alloc] init];
    for(NSDictionary* tempDict in array)
    {
        NSString* id = @"";
        NSString* name = @"";
        NSString* time = @"";
        NSString* text = @"";
        NSString* imgurl = @"";
        NSString* videourl = @"";
        NSString* cateid = @"";
        NSString* sharecount = @"";
        NSString* viewcount = @"";
        NSString* youkuid = @"";
        NSString* youkuweburl = @"";
        NSString* commentscount = @"";
        NSString* collectcount = @"";
        
        NSString* temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"JieID"] intValue]];
        if([temp length])
        {
            if([temp isEqualToString:@"32691"])
                continue;
            
            id = temp;
        }
        
        temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"CateID"] intValue]];
        if([temp length])
            cateid = temp;
        
        temp = [tempDict objectForKey:@"HeadPic"];
        if([temp isKindOfClass:[NSString class]] && [temp length])
            imgurl = temp;
        
        temp = [tempDict objectForKey:@"JieTitle"];
        if([temp isKindOfClass:[NSString class]] && [temp length])
            text = temp;
        
        
        temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"ShareCount"] intValue]];
        if([temp length])
            sharecount = temp;
        
        
        temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"ViewCount"] intValue]];
        if([temp length])
            viewcount = temp;
        
        temp = [tempDict objectForKey:@"PublishTime"];
        if([temp length])
            time = temp;
        
        temp = [tempDict objectForKey:@"VideoUrl"];
        if([temp isKindOfClass:[NSString class]] && [temp length])
            videourl = temp;
        
        temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"YouKuID"] intValue]];
        if([temp length])
            youkuid = temp;
        
        temp = [tempDict objectForKey:@"YouKuWebURL"];
        if([temp isKindOfClass:[NSString class]] && [temp length])
            youkuweburl = temp;
        
        temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"CommentsCount"] intValue]];
        if([temp length])
            commentscount = temp;
        
        temp = [NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"CollectCount"] intValue]];
        if([temp length])
            collectcount = temp;
        
        temp = [tempDict objectForKey:@"CateName"];
        if([temp isKindOfClass:[NSString class]] && [temp length])
            name = temp;
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@",id];
        NSManagedObjectID* objectID = [RCTool getExistingEntityObjectIDForName: @"Item"
                                                                     predicate: predicate
                                                               sortDescriptors: nil
                                                                       context: [RCTool getManagedObjectContext]];
        
        
        Item* item = nil;
        if(nil == objectID)
        {
            item = [RCTool insertEntityObjectForName:@"Item"
                                managedObjectContext:[RCTool getManagedObjectContext]];
            
            item.id = id;
        }
        else
        {
            item = (Item*)[RCTool insertEntityObjectForID:objectID
                                     managedObjectContext:[RCTool getManagedObjectContext]];
        }
        
        item.name = name;
        item.time = time;
        item.text = text;
        item.imgurl = imgurl;
        item.videourl = videourl;
        item.sharecount = sharecount;
        item.viewcount = viewcount;
        item.youkuid = youkuid;
        item.youkuweburl = youkuweburl;
        item.commentscount = commentscount;
        item.collectcount = collectcount;
        
        [itemArray addObject:item];
        
    }
    
    
    if([itemArray count] && 0 == segment_index)
    {
        self.page0++;
        
        if(0 == type)
        {
            [_itemArray0 removeAllObjects];
            self.page0 = 2;
        }
        
        [_itemArray0 addObjectsFromArray:itemArray];
        [self.tableView reloadData];
    }
    else if([itemArray count] && 1 == segment_index)
    {
        self.page1++;
        
        if(0 == type)
        {
            [_itemArray1 removeAllObjects];
            self.page1 = 2;
        }
        
        [_itemArray1 addObjectsFromArray:itemArray];
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
    if(0 == section)
    {
        if(0 == _type)
            return [self.itemArray0 count];
        else
            return [self.itemArray1 count];
    }
    
    return 0;
}

- (CGFloat)getCellHeight:(NSIndexPath*)indexPath
{
    //    CGFloat offset_width = 8.0f;
    //    CGFloat offset_height = 8.0f;
    //    CGFloat header_height = 30.0f;
    //    CGFloat name_height = 20.0f;
    //    CGFloat name_font_size = 14.0f;
    //    CGFloat text_font_size = 17.0f;
    //    CGFloat button_height = 45.0f;
    //    CGFloat image_height = 160.0f;
    //
    //    CGFloat height = offset_height*7 + header_height + button_height;
    //
    //    Item* item = (Item*)[self getCellDataAtIndexPath:indexPath];
    //    if(item)
    //    {
    //        NSString* text = item.text;
    //        if([text length])
    //        {
    //            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:text_font_size] constrainedToSize:CGSizeMake([RCTool getScreenSize].width - offset_width*4,CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    //            height += size.height;
    //        }
    //
    //        NSString* imageUrl = item.imgurl;
    //        NSString* videourl = item.videourl;
    //        if([imageUrl length] || [videourl length])
    //        {
    //            height += image_height;
    //        }
    //    }
    
    if(0 == _type)
    {
        if([RCTool isIpad])
            return 140.0f;
        else
            return 80.0f;
    }
    else
    {
        if([RCTool isIpad])
            return 170.0f;
        else
            return 100.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellHeight:indexPath];
}

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
    if(0 == _type)
    {
        if(indexPath.row >= [_itemArray0 count])
            return nil;
        
        return [_itemArray0 objectAtIndex: indexPath.row];
    }
    else
    {
        if(indexPath.row >= [_itemArray1 count])
            return nil;
        
        return [_itemArray1 objectAtIndex: indexPath.row];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId0 = @"cellId0";
    static NSString *cellId1 = @"cellId1";
    
    UITableViewCell *cell = nil;
    
    if(0 == _type)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId0];
        if(cell == nil)
        {
            cell = [[RCPublicCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: cellId0 contentViewClass:NSClassFromString(@"RCPictureCellContentView")];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
        if(cell == nil)
        {
            cell = [[RCPublicCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: cellId1 contentViewClass:NSClassFromString(@"RCVideoCellContentView")];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    
    NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath: indexPath];
    RCPublicCell* temp = (RCPublicCell*)cell;
    if(temp)
    {
        [temp updateContent:item cellHeight:[self getCellHeight:indexPath] delegate:self token:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    static int times = 1;
    if(0 == times % [RCTool getScreenAdRate])
    {
        times = 1;
        [self showAdFullScreen:nil];
        return;
    }
    else
        times++;
    
    
    Item* item = (Item*)[self getCellDataAtIndexPath:indexPath];
    if(item)
    {
        NSString* id = item.id;
        NSString* urlString = [NSString stringWithFormat:@"http://m.jiecaojie.com/MJieInfo_%@.html?appid=843664556&newappid=843664556&ver=1.5&channel=appstore",id];
        RCWebViewController* temp = [[RCWebViewController alloc] initWithNibName:nil bundle:nil];
        temp.hideToolbar = YES;
        [temp updateContent:urlString item:item];
        temp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
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
