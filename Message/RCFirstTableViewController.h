//
//  RCFirstTableViewController.h
//  Message
//
//  Created by xuzepei on 8/5/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@class Item;
@interface RCFirstTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UISegmentedControl* segmentedControl;
@property(nonatomic,weak)IBOutlet UITableView* tableView;
@property(nonatomic,strong)NSMutableArray* itemArray0;
@property(nonatomic,strong)NSMutableArray* itemArray1;
@property(nonatomic,assign)int page0;
@property(nonatomic,assign)int page1;
@property(nonatomic,assign)int tryno;
@property(nonatomic,assign)int type;
@property(nonatomic,strong)Item* selectedItem;


- (IBAction)clickedLeftBarButtonItem:(id)sender;
- (IBAction)clickedRightBarButtonItem:(id)sender;
- (IBAction)segmentedControlValueChanged:(id)sender;

@end
