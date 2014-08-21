//
//  RCMoreTableViewController.m
//  Message
//
//  Created by xuzepei on 8/11/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCMoreTableViewController.h"
#import "RCHttpRequest.h"
#import "UMFeedback.h"
#import "RCImageLoader.h"
#import <QuartzCore/QuartzCore.h>

@interface RCMoreTableViewController ()

@end

@implementation RCMoreTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:22]}];
    
    if(nil == _itemArray)
        _itemArray = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestContent];
}

- (void)requestContent
{
    [_itemArray removeAllObjects];
    
    NSArray* otherApps = [RCTool getOtherApps];
    if([otherApps count])
        [_itemArray addObjectsFromArray:otherApps];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
    if(1 == indexPath.section)
    {
        if(indexPath.row >= [_itemArray count])
            return nil;
        
        return [_itemArray objectAtIndex: indexPath.row];
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0 == section)
        return 3;
    else if(1 == section)
        return [self.itemArray count];
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(0 == section)
        return [RCTool getTextById:@"ti_0"];
    else if(1 == section && [_itemArray count])
        return [RCTool getTextById:@"ti_1"];;
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([RCTool isIpad])
    {
        if(0 == indexPath.section)
            return 70.0f;
        else if(1 == indexPath.section)
            return 70.0f;
    }
    else{
        if(0 == indexPath.section)
            return 60.0f;
        else if(1 == indexPath.section)
            return 60.0f;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"more_list_cell_id" forIndexPath:indexPath];
    //cell.imageView.layer.cornerRadius = 12;
    //cell.imageView.layer.masksToBounds = YES;
    
    if(0 == indexPath.section)
    {
        cell.imageView.image = nil;
        if(0 == indexPath.row)
        {
            cell.textLabel.text = [RCTool getTextById:@"ti_2"];
            cell.imageView.image = [UIImage imageNamed:@"clean"];
        }
        else if(1 == indexPath.row)
        {
            cell.textLabel.text = [RCTool getTextById:@"ti_3"];
            cell.imageView.image = [UIImage imageNamed:@"commend"];
        }
        else if(2 == indexPath.row)
        {
            cell.textLabel.text = [RCTool getTextById:@"ti_4"];
            cell.imageView.image = [UIImage imageNamed:@"feedback"];
        }
    }
    else if(1 == indexPath.section)
    {
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            cell.textLabel.text = [item objectForKey:@"name"];
            cell.detailTextLabel.text = [item objectForKey:@"desc"];
            
            NSString* imageUrl = [item objectForKey:@"img_url"];
            if([imageUrl length])
            {
                UIImage* image = [RCTool getImageFromLocal:imageUrl];
                if(image)
                {
                    image = [RCTool imageWithImage:image scaledToSize:CGSizeMake(40.0, 40.0)];
                    cell.imageView.image = image;
                }
                else
                {
                    [[RCImageLoader sharedInstance] saveImage:imageUrl
                                                     delegate:self
                                                        token:nil];
                }
            }
        }
    }
    
    return cell;
}


// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(0 == indexPath.section)
    {
        if(0 == indexPath.row)
            [self cleanCachedContent];
        else if(1 == indexPath.row)
            [self comment];
        else if(2 == indexPath.row)
            [self feedback];
    }
    else if(1 == indexPath.section)
    {
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            NSString* urlString = [item objectForKey:@"url"];
            if([urlString length])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
}

- (void)cleanCachedContent
{
    NSString* directoryPath = [NSString stringWithFormat:@"%@/images",[RCTool getUserDocumentDirectoryPath]];
    if([RCTool removeFile:directoryPath])
        [RCTool showAlert:@"提示" message:[RCTool getTextById:@"ti_5"]];
}

- (void)comment
{
    NSString* urlString = [RCTool getAppURL];
    if([urlString length])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)feedback
{
    [UMFeedback showFeedback:self withAppkey:UMENG_KEY];
}

- (void)succeedLoad:(id)result token:(id)token
{
	[self.tableView reloadData];
}

@end
