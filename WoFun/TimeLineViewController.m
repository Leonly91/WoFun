//
//  TimeLineViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "TimeLineViewController.h"
#import "LoginViewController.h"
//#import "NewMessageViewController.h"
#import "NetworkUtil.h"
#import "TweetViewCell.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "GlobalVar.h"
#import "FunTweet.h"
#import <UIImageView+WebCache.h>
#import "UILargeImgViewController.h"
#import "NewTweetViewController.h"

@interface TimeLineViewController ()
@property (nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic) NSMutableDictionary *tweetsDic;
@property (nonatomic) UITableViewCell *prototypeCell;

@property (nonatomic) UIView *bgView;
@property (nonatomic) UIImageView *largeImgView;
@end

@implementation TimeLineViewController

static NSString *tweetCellId = @"TweetViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor blueColor];
    self.tweetsArray = [[NSMutableArray alloc] init];
    self.tweetsDic = [[NSMutableDictionary alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    //[self.tableView registerNib:[UINib nibWithNibName:tweetCellId bundle:nil] forCellReuseIdentifier:tweetCellId];
    
}

-(void)refresh:(id)sender{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self getTimeline];
}

-(IBAction)newFun:(id)sender{
    NewTweetViewController *newTweetVC = [[NewTweetViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:newTweetVC];
    [self presentViewController:nvc animated:YES completion:nil];
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
    return UITableViewAutomaticDimension;
//    TweetViewCell *cell = [[TweetViewCell alloc] init];
//    FunTweet *tweet = [self json2Tweet:self.tweetsArray[indexPath.row]];
//    cell.tweetContent.text = tweet.content;
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
//    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    CGSize textViewSize = [cell.tweetContent sizeThatFits:CGSizeMake(cell.tweetContent.frame.size.width, FLT_MAX)];
//    CGFloat defaultHeight = cell.contentView.frame.size.height;
//    CGFloat height = textViewSize.height > defaultHeight ? textViewSize.height : defaultHeight;
//    CGFloat h = size.height;
//    return 1 + h;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        cell.preservesSuperviewLayoutMargins = NO;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetViewCell *tableCell = (TweetViewCell *)[tableView dequeueReusableCellWithIdentifier:tweetCellId];
    if (tableCell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:tweetCellId owner:self options:nil];
        tableCell = [nib objectAtIndex:0];
    }
//    if (self.prototypeCell == nil){
        self.prototypeCell = tableCell;
//    }

    FunTweet *tweet = [[FunTweet alloc] initWithJson: self.tweetsArray[indexPath.row]];
    if (tweet != nil){
        tableCell.username.text = tweet.username;
        tableCell.tweetContent.text = tweet.content;
        [tableCell.tweetContent sizeToFit];
        [tableCell.avatar sd_setImageWithURL:[NSURL URLWithString:tweet.avatar]];
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
    
    return tableCell;
}

/**
 * 显示图片原图，支持手指缩放
 */
-(IBAction)tapPhoto:(id)sender{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    UITapGestureRecognizer *tapReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBgView:
    )];
    [self.bgView addGestureRecognizer:tapReg];
    
    TweetViewCell *cell = (TweetViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
//    UILongPressGestureRecognizer *longTapReg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapImage:)];
//    longTapReg.minimumPressDuration = 1.0f;
//    if (self.largeImgView == nil){
//        self.largeImgView = [[UIImageView alloc] initWithFrame:mainRect];
//    }
//    self.largeImgView.image = cell.photoImage.image;
//    self.largeImgView.contentMode = UIViewContentModeScaleAspectFit;
//    self.largeImgView.alpha = 1;
//    self.largeImgView.userInteractionEnabled = YES;
//    [self.largeImgView addGestureRecognizer:longTapReg];
//    [self.bgView addSubview:self.largeImgView];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [window addSubview:self.bgView];
    UILargeImgViewController *largeImgv = [[UILargeImgViewController alloc] init];
    largeImgv.image = cell.photoImage.image;
    [window.rootViewController presentViewController:largeImgv animated:YES completion:nil];
//    CGFloat y = self.tableView.contentOffset.y + self.tableView.contentInset.top - 20;
//    self.bgView.frame = CGRectMake(0, y, mainRect.size.width, mainRect.size.height);
//    [self.bgView setNeedsDisplay];
//    NSLog(@"%@, %f, %f, %f, %f", NSStringFromSelector(_cmd), y, self.tableView.contentOffset.y, self.tableView.contentInset.top, self.bgView.frame.origin.y);
//    
//    self.tableView.scrollEnabled = FALSE;
//    [self.view addSubview:self.bgView];
}


- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

-(IBAction)closeBgView:(id)sender{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.bgView != nil){
        [self.bgView removeFromSuperview];
        [self.bgView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    }
    self.tableView.scrollEnabled = TRUE;
}

-(NSArray *)json2TweetArray:(NSString *)jsonString{
    NSError *error = nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil || error != nil){
        NSLog(@"%@ failed.", NSStringFromSelector(_cmd));
        return nil;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray*)jsonObject;
//        NSLog(@"tweetArray:%lu, %@", (unsigned long)[array count], array);

        NSArray *tweetsArray = [NSArray arrayWithArray:array];
        return tweetsArray;
    }
    
    return nil;
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
    NSLog(@"%@ executes.access_token:%@, access_token_secret:%@", NSStringFromSelector(_cmd), access_token, access_token_secret);
    
    NSString *apiUrl = @"http://api.fanfou.com/statuses/home_timeline.json";
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    NSString *signature = [NetworkUtil getOauthSignature:apiUrl parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signature forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:apiUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);
        
        [self addObjects2DataSource:[self json2TweetArray:operation.responseString]];
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ failure.%@", NSStringFromSelector(_cmd), operation.responseString);
    }];
}

/**
 *  添加新的数据到数据源里：根据rawid查找是否已经存在
 *
 *  @param objects <#objects description#>
 */
-(void)addObjects2DataSource:(NSArray *)objects{
    if (!objects){
        return;
    }
    for (NSObject *obj in objects){
        FunTweet *tweet = [[FunTweet alloc] initWithJson: (NSDictionary *)obj];
        if (self.tweetsDic[tweet.rawId] == nil){
            self.tweetsDic[tweet.rawId] = obj;
            [self.tweetsArray addObject:obj];
        }
    }
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
