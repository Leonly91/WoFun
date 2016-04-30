//
//  TimeLineViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "TimeLineViewController.h"
#import "LoginViewController.h"
#import "NewMessageViewController.h"
#import "NetworkUtil.h"
#import "TweetViewCell.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "GlobalVar.h"
#import "FunTweet.h"

@interface TimeLineViewController ()
@property (nonatomic, strong) NSMutableArray *tweetsArray;
@end

@implementation TimeLineViewController

static NSString *tweetCellId = @"TweetViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor blueColor];
    self.tweetsArray = [[NSMutableArray alloc] init];
    
    //[self.tableView registerNib:[UINib nibWithNibName:tweetCellId bundle:nil] forCellReuseIdentifier:tweetCellId];
    
}

-(IBAction)newFun:(id)sender
{
//    NewMessageViewController *newMessageView = [[NewMessageViewController alloc] init];
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:newMessageView];
//    [self presentViewController:navi animated:TRUE completion:nil];
    
    [self redirectLogin];
}

-(void)redirectLogin{
    LoginViewController *loginView = [[LoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginView];
    [self presentViewController:navi animated:TRUE completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"WoFun";
    UIBarButtonItem *newFun = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newFun:)];
    self.tabBarController.navigationItem.rightBarButtonItem = newFun;
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:nil];
    
//    NSLog(@"TimeLineViewController %@. access_token = %@", NSStringFromSelector(_cmd), access_token);
    [self getTimeline];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweetsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetViewCell *tableCell = (TweetViewCell *)[tableView dequeueReusableCellWithIdentifier:tweetCellId];
    if (tableCell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:tweetCellId owner:self options:nil];
        tableCell = [nib objectAtIndex:0];
    }

    FunTweet *tweet = [self json2Tweet:self.tweetsArray[indexPath.row]];
    if (tweet != nil){
        tableCell.username.text = tweet.username;
        tableCell.tweetContent.text = tweet.content;
        tableCell.avatar.image = [[UIImage alloc] init];
//        tableCell.createTime.text = tweet.createTime;
    }
    
    tableCell.tweetContent.scrollEnabled = false;
    return tableCell;
}

-(void)json2TweetArray:(NSString *)jsonString{
    NSError *error = nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil || error != nil){
        NSLog(@"%@ failed.", NSStringFromSelector(_cmd));
        return;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray*)jsonObject;
        NSLog(@"tweetArray:%lu, %@", (unsigned long)[array count], array);
        
        [self.tweetsArray addObjectsFromArray:array];
    }
    
    [self.tableView reloadData];
}

-(FunTweet *)json2Tweet:(NSDictionary *)jsonObj{
//    NSLog(@"json2Tweet:%@", jsonObj);
    FunTweet *tweet = nil;
    tweet = [[FunTweet alloc] init];
    tweet.content = jsonObj[@"text"];
    tweet.username = jsonObj[@"repost_screen_name"];
    tweet.createTime = jsonObj[@"created_at"];// 需要转换

    return tweet;
}

#pragma REST
- (void)getTimeline{
    if (!access_token.length || [access_token isEqualToString:@"(null)"]){
        [self redirectLogin];
        return;
    }
    NSLog(@"access_token:%@", access_token);
    
    NSString *apiUrl = @"http://api.fanfou.com/statuses/home_timeline.json";
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    NSString *signature = [NetworkUtil getOauthSignature:apiUrl parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signature forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:apiUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);
        
        [self json2TweetArray:operation.responseString];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ failure.%@", NSStringFromSelector(_cmd), operation.responseString);
    }];
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
