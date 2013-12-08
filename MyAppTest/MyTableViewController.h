//
//  MyTableViewController.h
//  MyAppTest
//
//  Created by sjpsega on 13-12-4.
//  Copyright (c) 2013 sjpsega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
@interface MyTableViewController:UITableViewController
{

}

@property (strong,nonatomic) NSMutableArray *mArray;
//开始重新加载时调用的方法
- (void)reloadTableViewDataSource;
//完成加载时调用的方法
- (void)doneLoadingTableViewData;
@end