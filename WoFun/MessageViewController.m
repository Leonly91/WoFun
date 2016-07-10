//
//  MessageViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "MessageViewController.h"
#import "NetworkUtil.h"
#import "GlobalVar.h"
#import "ConversationViewController.h"
#import "SearchFriendTable.h"
#import <AFHTTPRequestOperation.h>
#import <UIImageView+WebCache.h>

@interface MessageViewController ()

@property (nonatomic) NSMutableArray *messageArray;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.messageArray  = [[NSMutableArray alloc] init];
    
    [self getMessageArray];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *newConv = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newConv:)];
    self.tabBarController.navigationItem.rightBarButtonItem = newConv;
    self.tabBarController.navigationItem.title = @"私信";
    [self.tableView reloadData];
}

-(IBAction)newConv:(id)sender{
    SearchFriendTable *sft = [[SearchFriendTable alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:sft];
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)getMessageArray{
    [NetworkUtil getMessageConversationList:0 count:0 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        NSArray *array = [NetworkUtil parseJsonToArray:operation.responseString];
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:array];
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

-(void)parseJsonString2:(NSString *)string{
    if (string == nil)
        return;
    
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil || error != nil){
        NSLog(@"%@ failed.", NSStringFromSelector(_cmd));
        return;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]){
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:(NSArray *)jsonObject];
    }
}

#pragma UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.messageArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor whiteColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"conversationCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    NSDictionary *conversation = (NSDictionary *)self.messageArray[indexPath.section];
    
    cell.textLabel.text = conversation[@"dm"][@"sender_screen_name"];
    cell.detailTextLabel.text = conversation[@"dm"][@"text"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:conversation[@"dm"][@"sender"][@"profile_image_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell setNeedsLayout];
    }];
    cell.imageView.layer.cornerRadius = 4.0f;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.contentMode = UIViewContentModeCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
    conversationVC.conversationDic = (NSDictionary*)self.messageArray[indexPath.section];
    conversationVC.userId = conversationVC.conversationDic[@"dm"][@"sender"][@"id"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:conversationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
