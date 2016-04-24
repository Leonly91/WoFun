//
//  ProfileViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "ProfileViewController.h"
#import <Foundation/Foundation.h>
#import "ProfileAvatarTableViewCell.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "NetworkUtil.h"
#import "GlobalVar.h"
#import "ProfileEditViewController.h"
#import <UIImageView+WebCache.h>

@interface ProfileViewController ()
@property (nonatomic) NSArray *array;
@property (nonatomic) NSArray *productArray;
@property (nonatomic) NSDictionary *profileDic;
@end

@implementation ProfileViewController

static NSString* avatarCellId = @"ProfileAvatarTableViewCell";
static NSString* cellId = @"cellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //[self.tableView registerClass:[ProfileAvatarTableViewCell class] forCellReuseIdentifier:tableCellId];
    
    self.view.backgroundColor = self.tableView.separatorColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.array = [[NSArray alloc] initWithObjects:@"BlackList", @"Favourite", @"关注请求", @"Setting", @"Photos",nil];
    self.productArray = [[NSArray alloc] initWithObjects:@"WoFun", @"Contract us", nil];
    
//    [self getFollowersList];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Profile";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    //Get Profile Data via Network
    if (oauth_consumer_key != nil){
        [self getProfile];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 1;
    }else if(section == 1){
        return self.array.count;
    }else if(section == 2){
        return self.productArray.count;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        return 110;
    }else{
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2){
        return 0;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:avatarCellId];
        if (cell == nil){
            //NSArray *nib = [[NSBundle mainBundle] loadNibNamed:tableCellId owner:self options:nil];
            [self.tableView registerNib:[UINib nibWithNibName:avatarCellId bundle:nil] forCellReuseIdentifier:avatarCellId];
            //cell = [nib objectAtIndex:0];
            cell = [tableView dequeueReusableCellWithIdentifier:avatarCellId forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            if (indexPath.section == 1){
                cell.textLabel.text = self.array[indexPath.row];
            }else{
                cell.textLabel.text = self.productArray[indexPath.row];
            }
//            cell.backgroundColor = [UIColor blueColor];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRow");
    if (indexPath.section == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            ProfileEditViewController *editView = [[ProfileEditViewController alloc] init];
            editView.username = self.profileDic[@"id"];
            editView.avatar = self.profileDic[@"profile_image_url_large"];
            editView.username = self.profileDic[@"name"];
            editView.homeurl = self.profileDic[@"url"];
            editView.location = self.profileDic[@"location"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editView];
            [self presentViewController:nav animated:TRUE completion:nil];
        });
    }
}

#pragma 获取用户个人资料
-(void)getProfile{
    NSString *url = @"http://api.fanfou.com/account/verify_credentials.json";
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    NSString *signature = [NetworkUtil getOauthSignature:url parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signature forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Profile. %@", operation.responseString);
        
        NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        self.profileDic =  [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@", self.profileDic);
        
        userId = self.profileDic[@"id"];//Save global user id
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        ProfileAvatarTableViewCell *avatarCell = (ProfileAvatarTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        avatarCell.follower.text = [NSString stringWithFormat:@"%@ Followers", self.profileDic[@"followers_count"]];
        avatarCell.following.text = [NSString stringWithFormat:@"%@ Following", self.profileDic[@"friends_count"]];
        avatarCell.username.text = self.profileDic[@"name"];
        avatarCell.messages.text = [NSString stringWithFormat:@"%@ Messages", self.profileDic[@"statuses_count"]];
        avatarCell.favouriteMsg.text = [NSString stringWithFormat:@"%@ Favourites", self.profileDic[@"favourites_count"]];
        
        NSString *imageUrl = self.profileDic[@"profile_image_url_large"];
//        UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [avatarCell.avatar sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Profile failure.%@", operation.responseString);
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
