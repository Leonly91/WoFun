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
#import <UIImageView+WebCache.h>

@interface TimeLineViewController ()
@property (nonatomic, strong) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UITableViewCell *prototypeCell;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *largeImgView;
@end

@implementation TimeLineViewController

static NSString *tweetCellId = @"TweetViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor blueColor];
    self.tweetsArray = [[NSMutableArray alloc] init];
    self.bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 1.0f;
    
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
    
    UILongPressGestureRecognizer *longTapReg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapImage:)];
    longTapReg.minimumPressDuration = 1.0f;
    if (self.largeImgView == nil){
        self.largeImgView = [[UIImageView alloc] initWithFrame:mainRect];
    }
    self.largeImgView.image = cell.photoImage.image;
    self.largeImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.largeImgView.alpha = 1;
    self.largeImgView.userInteractionEnabled = YES;
    [self.largeImgView addGestureRecognizer:longTapReg];
    [self.bgView addSubview:self.largeImgView];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.bgView];
//    CGFloat y = self.tableView.contentOffset.y + self.tableView.contentInset.top - 20;
//    self.bgView.frame = CGRectMake(0, y, mainRect.size.width, mainRect.size.height);
//    [self.bgView setNeedsDisplay];
//    NSLog(@"%@, %f, %f, %f, %f", NSStringFromSelector(_cmd), y, self.tableView.contentOffset.y, self.tableView.contentInset.top, self.bgView.frame.origin.y);
//    
//    self.tableView.scrollEnabled = FALSE;
//    [self.view addSubview:self.bgView];
}

/**
 *  长按图片，可以选择保存或复制
 *
 *  @param sender <#sender description#>
 */
-(IBAction)longTapImage:(UILongPressGestureRecognizer *)recogn{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (recogn.state == UIGestureRecognizerStateBegan){
    
        NSArray *items = @[self.largeImgView.image];
        UIActivityViewController * activityVc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window.rootViewController presentViewController:activityVc animated:YES completion:^{
        }];
    }
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
