//
//  MyTableViewController.m
//  MyAppTest
//
//  Created by sjpsega on 13-12-4.
//  Copyright (c) 2013 sjpsega. All rights reserved.
//

#import "MyTableViewController.h"
#import "Reachability.h"
#import "UIImageView+WebCache.h"
#import "AFJSONRequestOperation.h"
#import "Pods-environment.h"
#import "SBJsonParser.h"
#import "AFHTTPClient.h"
#import "LoadMoreTableFooterView.h"
#import "MovieDetailViewController.h"
#import "GlobalScript.h"

static const NSString *MOVIE_SEARCH = @"https://api.douban.com/v2/movie/search?tag=";

@interface MyTableViewController()<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshTableView;
    LoadMoreTableFooterView *_loadMoreFooterView;
    BOOL _reloading;
    int moreDataCount;
}

@end

@implementation MyTableViewController
@synthesize mArray = _mArray;

#pragma mark -
#pragma mark View life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];

    moreDataCount = 0;
    //设置导航条标题
    self.navigationItem.title = @"Pull Refresh";
    if (_refreshTableView == nil) {
        //初始化下拉刷新控件
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                CGRectMake(0.0f, 0.0f - self.tableView.frame.size.height, self.view.frame.size.width, self.tableView.frame.size.height)];
        refreshView.delegate = self;
        //将下拉刷新控件作为子控件添加到UITableView中
        [self.tableView addSubview:refreshView];
        _refreshTableView = refreshView;
    }

    if (_loadMoreFooterView == nil) {
        LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, self.tableView.contentSize.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _loadMoreFooterView = view;
    }
    
    //初始化用于填充表格的数据
//    NSArray *dataArray = [NSArray arrayWithObjects:@"11",@"22",@"33",@"44",@"55",nil];
//    self.array = dataArray;

    //重新加载表格数据
//    [self.tableView reloadData];


    //添加网络监听
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
    
    [self loadNewData];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

//网络监听
-(void)reachabilityChanged:(NSNotification*)notification{
    NSString *nameString = [notification name];
    Reachability *curReach = [notification object];
    NetworkStatus status = [curReach currentReachabilityStatus];
    NSLog(@"name = %@,object = %i",nameString,status);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark -
# pragma mark UITableViewDataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.mArray[indexPath.row];
    MovieDetailViewController *detailViewController = [[MovieDetailViewController alloc] initWithData:data];
    [self.navigationController pushViewController:detailViewController animated:YES];

//    [self presentViewController:detailViewController animated:YES completion:^{
//
//
//    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

//    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:@"blackArrow.png"];

//    NSURL *imageUrl = [NSURL URLWithString:@"http://tp4.sinaimg.cn/1925471775/50/40025833074/1"];
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
//    cell.imageView.image = image;

    id data = [self.mArray objectAtIndex:indexPath.row];
//    [cell.imageView setImageWithURL:[NSURL URLWithString:data[@"images"][0]] placeholderImage:[UIImage imageNamed:@"blueArrow.png"]];
    [cell.imageView setImageWithURL:data[@"images"][@"small"] placeholderImage:[UIImage imageNamed:@"blueArrow.png"]];
//    cell.textLabel.text = [data objectForKey:@"title"];
    cell.textLabel.text = data[@"title"];

    return cell;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
//开始重新加载时调用的方法
- (void)reloadTableViewDataSource{
    _reloading = YES;
    //开始刷新后执行后台线程，在此之前可以开启HUD或其他对UI进行阻塞
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}

//完成加载时调用的方法
- (void)doneLoadingTableViewData{
    NSLog(@"doneLoadingTableViewData");

    [self loadNewData];
}


- (void)loadNewData {
    __weak MyTableViewController *weakself = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[self generateURLWithTag:@"喜剧" start:0 count:20]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSDictionary *dataDic =(NSDictionary *)JSON;
                                                                                            weakself.mArray = [[dataDic objectForKey:@"subjects"] mutableCopy];
                                                                                            [weakself.tableView reloadData];
                                                                                   
                                                                                            NSLog(@"Success :%@", JSON);
                                                                                            _reloading = NO;
                                                                                            [_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"Failure: %@", error);
            }];
    [operation start];
}

-(void)doneLoadingMoreTableViewData{
    moreDataCount++;
    __weak MyTableViewController *weakself = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[self generateURLWithTag:@"喜剧" start:(0+20*moreDataCount) count:20]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSDictionary *dataDic =(NSDictionary *)JSON;
                                                                                            [weakself.mArray addObjectsFromArray:[dataDic objectForKey:@"subjects"]];
                                                                                            [weakself.tableView reloadData];
                                                                                            NSLog(@"Success :%@", JSON);
                                                                                            _reloading = NO;
                                                                                            [_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:self.tableView];
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"Failure: %@", error);
            }];
    [operation start];
}

-(NSURL *)generateURLWithTag:(NSString *)tag start:(int)start count:(int)count{
    NSString *url = [NSString stringWithFormat:@"https://api.douban.com/v2/movie/search?tag=%@&start=%i&count=%i",tag,start,count];
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
#pragma mark Background operation
//这个方法运行于子线程中，完成获取刷新数据的操作
-(void)doInBackground
{
    NSLog(@"doInBackground");

//    [NSThread sleepForTimeInterval:3];

    //后台操作线程执行完后，到主线程更新UI
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉被触发调用的委托方法
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
}

//返回当前是刷新还是无刷新状态
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

//返回刷新时间的回调方法
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark LoadMoreTableFooterDelegate Methods

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view {
    [self performSelector:@selector(doneLoadingMoreTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
    return _reloading;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
//滚动控件的委托方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];
    [_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
    [_loadMoreFooterView loadMoreScrollViewDidEndDragging:scrollView];
}


@end
