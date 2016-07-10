//
//  SearchFriendTable.m
//  WoFun
//
//  Created by 林勇 on 16/7/9.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "SearchFriendTable.h"
#import "NetworkUtil.h"
#import "GlobalVar.h"
#import <AFHTTPRequestOperation.h>
#import <UIImageView+WebCache.h>

@interface SearchFriendTable ()
@property (nonatomic) NSMutableArray *userArray;
@property (nonatomic) NSMutableDictionary *userInfo;
@property (nonatomic) NSMutableArray *searchUserArray;
//@property (nonatomic) NSMutableDictionary *searchUserInfo;
@property (nonatomic) dispatch_group_t group;
@property (nonatomic) NSIndexPath *selectedRow;
//@property (nonatomic) UISearchBar *searchBa
@property (nonatomic) UISearchController *searchController;
@end

@implementation SearchFriendTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userArray = [[NSMutableArray alloc] init];
    self.userInfo = [[NSMutableDictionary alloc] init];
    self.group = dispatch_group_create();
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.selectedRow = nil;
    self.searchUserArray = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backTo:)];
    self.navigationItem .rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
//    CGRect rect = [UIScreen mainScreen].bounds;
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 44)];
//    self.searchBar.delegate = self;
//    self.tableView.tableHeaderView = self.searchBar;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    [self loadFriendList];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.searchController.active){
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

-(IBAction)next:(id)sender{
    if (self.selectedRow == nil){
        NSLog(@"%@-%@ error.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    NSString *seletcedUserId = self.searchController.active ? self.searchUserArray[self.selectedRow.row] : self.userArray[self.selectedRow.row];
    NSLog(@"%@-%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), seletcedUserId);
}

-(IBAction)backTo:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"收信人";
}

-(void)loadUserInfo:(NSString *)userId{
    [NetworkUtil getUserInfo:userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *userInfo =  [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        [self.userInfo setObject:userInfo forKey:userId];
        
        dispatch_group_leave(self.group);
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        dispatch_group_leave(self.group);
    }];
}

/**
 *  通过dispatch_group等待所有异步请求完成后再统一reloadData
 */
-(void)loadFriendList{
    [NetworkUtil getFriendList:userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        [self.userArray addObjectsFromArray:[NetworkUtil parseJsonToArray:operation.responseString]];
        
        
        for(NSString *userId in self.userArray){
            dispatch_group_enter(self.group);
            [self loadUserInfo:userId];
        }
        
        dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.searchController.active){
        return self.searchUserArray.count;
    }
    return self.userArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    // Configure the cell...
    NSString *userId = self.searchController.active? self.searchUserArray[indexPath.row] : self.userArray[indexPath.row];
    NSDictionary *userInfo = (NSDictionary *)[self.userInfo objectForKey:userId];
    cell.textLabel.text = userInfo[@"screen_name"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.imageView.layer.cornerRadius = 4.0;
        cell.imageView.clipsToBounds = YES;
        [cell setNeedsLayout];
    }];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if (self.selectedRow != nil && (self.selectedRow.row == indexPath.row && self.selectedRow.section == indexPath.section)){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (self.selectedRow != nil && (self.selectedRow.row != indexPath.row || self.selectedRow.section != indexPath.section)){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedRow];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedRow = indexPath;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma UISearchResultUpdating delegate
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    if (!searchController.active){//CANCEL
        self.selectedRow = nil;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [self.searchUserArray removeAllObjects];
    
    [self.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary * obj, BOOL *stop) {
        NSRange range = [obj[@"screen_name"] rangeOfString:self.searchController.searchBar.text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
        if (range.location != NSNotFound){
            [self.searchUserArray addObject:key];
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
