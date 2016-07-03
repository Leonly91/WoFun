//
//  TweetPageViewController.m
//  WoFun
//
//  Created by 林勇 on 16/5/8.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#pragma 推文详细信息页面

#import "TweetPageViewController.h"
#import "ProfileAvatarTableViewCell.h"
#import "FunTweet.h"
#import <UIImageView+WebCache.h>
#import "NetworkUtil.h"
#import "GlobalVar.h"
#import <NSString+URLEncode.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <UIToast.h>

@interface TweetPageViewController ()
@property (nonatomic) UITextView *tweetContentTv;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIBarButtonItem *favoriteButtonItem;
@end

static NSString *favoriteCreateAPI = @"http://api.fanfou.com/favorites/create/";
static NSString *favoriteDestroyAPI = @"http://api.fanfou.com/favorites/destroy/";
static NSString *redirectMsgAPI = @"";

@implementation TweetPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem.title = @"dd";
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (0 <= section  && section <= 4){
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){//avatar
        return 110;
    }else if (indexPath.section == 1){//tweet content
//        NSLog(@"lalalal:%f", self.tweetContentTv.contentSize.height);
        return self.tweetContentTv.bounds.size.height;
    }else if (indexPath.section == 2){//tweet image
        return self.funTweet.photoUrl.length > 0? (self.imageView.bounds.size.height + 10):0;
    }else if (indexPath.section == 3){
        return UITableViewAutomaticDimension;
    }else{
        return 40;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tweetContentCellId = @"tweetContentCellId";
    static NSString *tweetImgCellId = @"tweetImgCellId";
    static NSString* avatarCellId = @"ProfileAvatarTableViewCell";
    static NSString *toolBarCellId = @"toolBarCellId";
    UITableViewCell *cell = nil;
    //User Avatar section cell
    if (indexPath.section == 0){
        // 头像，昵称
        [tableView registerNib:[UINib nibWithNibName:avatarCellId bundle:nil] forCellReuseIdentifier:avatarCellId];
        cell = [tableView dequeueReusableCellWithIdentifier:avatarCellId forIndexPath:indexPath];
        ProfileAvatarTableViewCell *avatar = (ProfileAvatarTableViewCell *)cell;
        avatar.following.text = @"";
        avatar.follower.text = @"";
        avatar.messages.text = @"";
        avatar.favouriteMsg.text = @"";
        [avatar.avatar sd_setImageWithURL:[NSURL URLWithString:self.funTweet.avatar]];
        avatar.avatar.layer.cornerRadius = 6.0f;
        avatar.avatar.layer.borderWidth = 1.0f;
//        avatar.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
//        avatar.avatar.backgroundColor = [UIColor whiteColor];
        avatar.avatar.clipsToBounds = YES;
        
        avatar.username.text = self.funTweet.username;
        avatar.username.font = [UIFont systemFontOfSize:15];
    }else if (indexPath.section == 1){
        // 推文内容
        cell = [tableView dequeueReusableCellWithIdentifier:tweetContentCellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tweetContentCellId];
            //        cell.backgroundColor = [UIColor redColor];
            //        NSLog(@"%@, %@, cell.frame.size.width = %f, conentwidth=%f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), cell.frame.size.height, tableView.bounds.size.width);
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 5, cell.frame.origin.y, tableView.bounds.size.width - 5 , cell.frame.size.height)];
            textView.editable = NO;
            textView.font = [UIFont systemFontOfSize:18];
            //        textView.backgroundColor = [UIColor blueColor];
            [cell.contentView addSubview:textView];
            self.tweetContentTv = textView;
            NSLog(@"fucfuck.%f", textView.contentSize.height);
        }
        self.tweetContentTv.text = self.funTweet.content;
        [self.tweetContentTv sizeToFit];
    }else if (indexPath.section == 2){
        // 推文照片
        cell = [tableView dequeueReusableCellWithIdentifier:tweetImgCellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tweetImgCellId];
             self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 300)];
            [cell.contentView addSubview:self.imageView];
//            self.imageView.contentMode = UIViewContentModeCenter;
            self.imageView.userInteractionEnabled = YES;
            self.imageView.clipsToBounds = YES;
            self.imageView.layer.cornerRadius = 4.0f;
        }
        if (self.funTweet.photoUrl != nil){
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.funTweet.photoUrl]];
        }
    }else if (indexPath.section == 3){
        // Tool
        cell = [tableView dequeueReusableCellWithIdentifier:toolBarCellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tweetContentCellId];
//            cell.backgroundColor = [UIColor greenColor];
            UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, cell.bounds.size.height)];
            NSMutableArray *btnTitle = [[NSMutableArray alloc] initWithArray:@[@"转发", @"回复"]];
            if (self.funTweet.favorited){
                [btnTitle addObject:@"取消收藏"];
            }else{
                [btnTitle addObject:@"收藏"];
            }
            NSMutableArray *btnArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < btnTitle.count; i++) {
                UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:btnTitle[i] style:UIBarButtonItemStylePlain target:self action:@selector(barBtnItemClick:)];
                btn.tag = i;
                [btnArray addObject:btn];
                if (i != btnTitle.count - 1){
                    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                    [btnArray addObject:btn];
                }
                if (i == btnTitle.count - 1){
                    self.favoriteButtonItem = btn;
                }
            }
            [toolBar setItems:btnArray animated:YES];
//            toolBar.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:toolBar];
        }
    }
    
    return cell;
}

- (void)barBtnItemClick:(UIBarButtonItem *)btn{
    switch (btn.tag) {
        case 0:
            [self redirectMsg:self.funTweet.id];
            break;
        case 1:
            [self replayMsg:self.funTweet.id];
            break;
        case 2:
            if (!self.funTweet.favorited){
                [self createFavorite:self.funTweet.id];
            }else{
                [self destroyFavorite:self.funTweet.id];
            }
            self.funTweet.favorited = !self.funTweet.favorited;
            break;
        default:
            NSLog(@"%@-%@ invalid tag:%lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), btn.tag);
            break;
    }
}

/**
 *  回复消息
 *
 *  @param msgId <#msgId description#>
 */
- (void)replayMsg:(NSString *)msgId{
    
}

/**
 *  转发消息
 *
 *  @param msgId <#msgId description#>
 */
- (void)redirectMsg:(NSString *)msgId{
    NSString *text = [NSString stringWithFormat:@"转%@ %@", self.funTweet.username, self.funTweet.content];
    UIImage *image = nil;
    if (self.funTweet.photoUrl != nil && self.funTweet.photoUrl.length != 0){
        NSURL *url = [NSURL URLWithString:self.funTweet.photoUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
    }
    
    NSString *url = @"http://api.fanfou.com/statuses/update.json?status=转飯否小字报 转@小吃轮 “爱一个人，是一件简单的事。就好像用杯子装满一杯水，清清凉凉地喝下去。你的身体需要它，感觉自己健康和愉悦。以此认定它是一个好习惯。所以愿意日日夜夜重复。”&oauth_signature=YSnrXG7LgYr%2FnEm8NoIXngFxHV4%3D&oauth_nonce=NXZGAGERZXFXGEPUYZZDCUWCYZWRSXXVOOCZKVAB&oauth_timestamp=1466340484&oauth_consumer_key=2c450ff5d3f7ee0a62348158b924a369&oauth_token=1277466-d4bf74db0b1a35b0a8e4af706e105c9b&oauth_signature_method=HMAC-SHA1";
    
    NSString *url2 = @"http://api.fanfou.com/statuses/update.json?status=我&oauth_signature=f6aMoVVIrTU3St7t39cptv%2BwoEc%3D&oauth_nonce=JNEHMLSIJGTMANUWCBKPYNKXXLQKSUHBUGCSGXHN&oauth_timestamp=1466342151&oauth_consumer_key=2c450ff5d3f7ee0a62348158b924a369&oauth_token=1277466-d4bf74db0b1a35b0a8e4af706e105c9b&oauth_signature_method=HMAC-SHA1";
    
    NSString *str = [[NSURL URLWithString:url2 relativeToURL:nil] absoluteString];
    
    [NetworkUtil postNewTweet:text image:image success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIToast makeText:@"转发成功"] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *jsonError = nil;
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        if (jsonObject != nil && jsonError == nil){
            NSString *text = jsonObject[@"error"];
            [[UIToast makeText:text] show];
        }

    }];
}

/**
 *  取消收藏
 *
 *  @param msgId <#msgId description#>
 */
- (void)destroyFavorite:(NSString *)msgId{
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    NSString *apiUrl = [NSString stringWithFormat:@"%@%@.json", favoriteDestroyAPI, msgId];
    NSLog(@"%@-%@, apiUrl:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), apiUrl);
    
    NSString *signautre = [NetworkUtil postOauthSignature:apiUrl parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *operation  = [manager POST:apiUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"%@-%@ success:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        NSString *text = @"取消收藏成功";
        [[UIToast makeText:text] show];
//        NSLog(@"%@", text);
        self.favoriteButtonItem.title = @"收藏";
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@-%@ failure:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        NSError *jsonError = nil;
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        if (jsonObject != nil && jsonError == nil){
            NSString *text = jsonObject[@"error"];
            [[UIToast makeText:text] show];
        }

    }];
    [operation start];
}

/**
 *  收藏消息
 *
 *  @param msgId 消息ID
 */
- (void)createFavorite:(NSString *)msgId{
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    NSString *apiUrl = [NSString stringWithFormat:@"%@%@.json", favoriteCreateAPI, msgId];
    NSLog(@"%@-%@, apiUrl:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), apiUrl);

    NSString *signautre = [NetworkUtil postOauthSignature:apiUrl parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *operation = [manager POST:apiUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        NSString *text = @"收藏成功";
        [[UIToast makeText:text] show];
        self.favoriteButtonItem.title = @"取消收藏";
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@-%@ failure:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        NSError *jsonError = nil;
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        if (jsonObject != nil && jsonError == nil){
            NSString *text = jsonObject[@"error"];
            [[UIToast makeText:text] show];
        }
    }];
    [operation start];
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
