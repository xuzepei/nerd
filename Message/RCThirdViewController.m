//
//  RCThirdViewController.m
//  Nerd
//
//  Created by xuzepei on 8/19/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCThirdViewController.h"
#import "RCHttpRequest.h"
#import "RCPublicCell.h"
#import "Item.h"
#import "RCImageDisplayViewController.h"
#import "RCWebViewController.h"
#import "RCAppDelegate.h"

@interface RCThirdViewController ()

@end

@implementation RCThirdViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdBanner:) name:SHOW_ADBANNER_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdFullScreen:) name:SHOW_FULLSCREENAD_NOTIFICATION object:nil];
    
    if(nil == _itemArray0)
        _itemArray0 = [[NSMutableArray alloc] init];
    
    self.page0 = 1;
    
    [self initRefreshControl];
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

- (IBAction)clickedRightBarButtonItem:(id)sender
{
    [self updateContent:self.category page:1 type:0];
}

- (void)headerRereshing
{
    NSLog(@"headerRereshing");
    
    [self updateContent:self.category page:1 type:0];
}

- (void)footerRereshing
{
    NSLog(@"footerRereshing");
    
   [self updateContent:self.category page:self.page0 type:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)updateContent:(NSDictionary*)category page:(int)page type:(int)type
{
    if(nil == category)
        return;
    
    self.category = category;
    
    int cateId = [[category objectForKey:@"CateID"] intValue];
    
    self.title = [category objectForKey:@"CateName"];
    
    NSString* urlString = [NSString stringWithFormat:@"%@&page=%d&cateID=%d",[RCTool getUrlByType:1],page,cateId];
    
    NSDictionary* token = @{@"type":[NSNumber numberWithInt:type],@"page":[NSNumber numberWithInt:page]};
    
    RCHttpRequest* temp = [[RCHttpRequest alloc] init] ;
    BOOL b = [temp request:urlString delegate:self resultSelector:@selector(finishedContentRequest:) token:token];
    if(b)
    {
        if(0 == [self.itemArray0 count])
        {
            //[RCTool showIndicator:@"加载中..."];
        }
    }
}

- (void)finishedContentRequest:(NSDictionary*)result
{
    [RCTool hideIndicator];
    
    NSString* jsonString = [result objectForKey:@"json"];
    NSDictionary* token = [result objectForKey:@"token"];
    int type = [[token objectForKey:@"type"] intValue];
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
    
    if([RCTool isEncrypted:1])
        jsonString = [RCTool decrypt:jsonString];
    
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
    
    
    if([itemArray count])
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
        return [self.itemArray0 count];
    }
    
    return 0;
}

- (CGFloat)getCellHeight:(NSIndexPath*)indexPath
{
    if([RCTool isIpad])
        return 140.0f;
    else
        return 80.0f;
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
    
    static NSString *cellId0 = @"cellId0";
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellId0];
    if(cell == nil)
    {
        cell = [[RCPublicCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: cellId0 contentViewClass:NSClassFromString(@"RCPictureCellContentView")];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
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
