//
//  RCThirdViewController.h
//  Nerd
//
//  Created by xuzepei on 8/19/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@class Item;
@interface RCThirdViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView* tableView;
@property(nonatomic,strong)NSMutableArray* itemArray0;
@property(nonatomic,assign)int page0;
@property(nonatomic,strong)NSDictionary* category;

- (void)updateContent:(NSDictionary*)category page:(int)page type:(int)type;
- (IBAction)clickedRightBarButtonItem:(id)sender;

@end
