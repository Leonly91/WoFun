//
//  BlockListViewController.m
//  WoFun
//
//  Created by 林勇 on 16/7/16.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "BlockListViewController.h"
#import "NetworkUtil.h"
#import "GlobalVar.h"
#import <AFHTTPRequestOperation.h>
#import <UIImageView+WebCache.h>

@interface BlockListViewController ()
@property (nonatomic) NSMutableArray *blockUserArray;
@end

@implementation BlockListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"黑名单";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadBlockList];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadBlockList{
    [NetworkUtil getBlockList:nil page:0 count:0 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        NSArray *array = [NetworkUtil parseJsonToArray:operation.responseString];
        [self.blockUserArray addObjectsFromArray:array];
        
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

-(NSMutableArray *)blockUserArray{
    if (_blockUserArray == nil){
        _blockUserArray = [[NSMutableArray alloc] init];
    }
    return _blockUserArray;
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
    return self.blockUserArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell){
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    // Configure the cell...
    NSDictionary *user = (NSDictionary *)self.blockUserArray[indexPath.row];
    cell.textLabel.text = user[@"screen_name"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user[@"profile_image_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell setNeedsLayout];
    }];
    
    return cell;
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

@end
