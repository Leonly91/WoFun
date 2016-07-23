//
//  AtMeViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "AtMeViewController.h"
#import "GlobalVar.h"
#import "NetworkUtil.h"
#import "FunTweet.h"
#import "UILargeImgViewController.h"
#import "TweetViewCell.h"
#import <AFHTTPRequestOperation.h>
#import <UIImageView+WebCache.h>
#import <UIToast.h>

@interface AtMeViewController ()
@property (nonatomic) NSMutableArray *messageArray;
@property (nonatomic) NSMutableDictionary *tweetsDic;
@property (nonatomic) UITableViewCell *prototypeCell;

@property (nonatomic) UIView *bgView;
@end

static NSString *tweetCellId = @"TweetViewCell";

@implementation AtMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:tweetCellId bundle:nil] forCellReuseIdentifier:tweetCellId];
    
    UIEdgeInsets tabInsets = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    self.tableView.contentInset = tabInsets;
    self.tableView.scrollIndicatorInsets = tabInsets;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"提到我";
    
    [self loadMentionMessages];
}

-(void)loadMentionMessages{
    [NetworkUtil getMentions:0 maxId:0 page:0 count:0 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        [self addObjects2DataSource:[NetworkUtil json2TweetArray:operation.responseString]];
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

-(void)addObjects2DataSource:(NSArray *)objects{
    if (!objects){
        return;
    }
    for (NSObject *obj in objects){
        FunTweet *tweet = [[FunTweet alloc] initWithJson: (NSDictionary *)obj];
        if (self.tweetsDic[tweet.rawId] == nil){
            self.tweetsDic[tweet.rawId] = obj;
            [self.messageArray addObject:obj];
        }
    }
}

-(NSMutableArray *)messageArray{
    if (_messageArray == nil){
        _messageArray = [[NSMutableArray alloc] init];
    }
    return _messageArray;
}

-(NSMutableDictionary*)tweetsDic{
    if (_tweetsDic == nil){
        _tweetsDic = [[NSMutableDictionary alloc] init];
    }
    return _tweetsDic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    static NSString *loadMoreCell = @"loadMoreCell";
    if (indexPath.row == self.messageArray.count){
        cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCell];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCell];
            cell.textLabel.text = @"加载更多";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }else{
        TweetViewCell *tableCell = (TweetViewCell *)[tableView dequeueReusableCellWithIdentifier:tweetCellId];
        if (tableCell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:tweetCellId owner:self options:nil];
            tableCell = [nib objectAtIndex:0];
        }
        
        self.prototypeCell = tableCell;
        
        FunTweet *tweet = [[FunTweet alloc] initWithJson: self.messageArray[indexPath.row]];
        if (tweet != nil){
            tableCell.username.text = tweet.username;
            tableCell.tweetContent.text = tweet.content;
            [tableCell.tweetContent sizeToFit];
            [tableCell.avatar sd_setImageWithURL:[NSURL URLWithString:tweet.avatar] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [tableCell setNeedsLayout];
            }];
            tableCell.avatar.layer.cornerRadius = 6.0f;
            tableCell.avatar.layer.borderWidth = 1.0f;
            tableCell.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
            tableCell.avatar.clipsToBounds = YES;
            tableCell.createTime.text = tweet.createTimeLabel;
            tableCell.photoHeight.constant = (tweet.photoUrl == nil)  %2 ? 0 : 110;
            if (tweet.photoUrl != nil){
                [tableCell.photoImage sd_setImageWithURL:[NSURL URLWithString:tweet.photoUrl]];
                tableCell.photoImage.layer.cornerRadius = 4.0f;
                tableCell.photoImage.clipsToBounds = YES;
                tableCell.photoImage.contentMode = UIViewContentModeCenter;
                tableCell.photoImage.userInteractionEnabled = YES;
                tableCell.photoImage.tag = indexPath.row;
                
                UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(
                                                                                                                      tapPhoto:)];
                [tableCell.photoImage addGestureRecognizer:tapRec];
            }
        }
        
        tableCell.tweetContent.scrollEnabled = false;
        cell = tableCell;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%@-%@:%lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), indexPath.row);
    
    FunTweet *tweet = [[FunTweet alloc] initWithJson: self.messageArray[self.messageArray.count - 1]];
    [NetworkUtil getMentions:nil maxId:tweet.id page:nil count:[NSNumber numberWithInt:20] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        NSArray *array = [NetworkUtil parseJsonToArray:operation.responseString];
        if (array.count == 0){
            NSString *text = @"没有更多了";
            [[UIToast makeText:text] show];
        }else{
            int preCount = (int)self.messageArray.count;
            [self addObjects2DataSource:array];
            int currentCount = (int)self.messageArray.count;
            
            NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
            for (int i = preCount; i < currentCount; i++){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPathArray addObject:indexPath];
            }
            [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationBottom];
        }
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

/**
 * 显示图片原图，支持手指缩放
 */
-(IBAction)tapPhoto:(id)sender{
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    UITapGestureRecognizer *tapReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBgView:
                                                                                                          )];
    [self.bgView addGestureRecognizer:tapReg];
    
    TweetViewCell *cell = (TweetViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //    [window addSubview:self.bgView];
    UILargeImgViewController *largeImgv = [[UILargeImgViewController alloc] init];
    largeImgv.image = cell.photoImage.image;
    //    [window.rootViewController presentViewController:largeImgv animated:YES completion:nil];
    [self.navigationController presentViewController:largeImgv animated:YES completion:nil];
}

-(IBAction)closeBgView:(id)sender{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.bgView != nil){
        [self.bgView removeFromSuperview];
        [self.bgView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    }
    self.tableView.scrollEnabled = TRUE;
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
