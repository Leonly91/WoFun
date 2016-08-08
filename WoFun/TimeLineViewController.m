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
#import "TweetPageViewController.h"
#import <UIToast.h>

@interface TimeLineViewController ()
@property (nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic) NSMutableDictionary *tweetsDic;
@property (nonatomic) UITableViewCell *prototypeCell;

@property (nonatomic) UIView *bgView;
//@property (nonatomic) UIImageView *largeImgView;
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
    UIEdgeInsets adjustForTabBar = UIEdgeInsetsMake(5, 0, self.tabBarController.tabBar.frame.size.height, 0);
    self.tableView.contentInset = adjustForTabBar;
    self.tableView.scrollIndicatorInsets = adjustForTabBar;
//    self.tableView.pagingEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:5 green:5 blue:5 alpha:0.8];
    //[self.tableView registerNib:[UINib nibWithNibName:tweetCellId bundle:nil] forCellReuseIdentifier:tweetCellId];
    [self getTimeline];
    
}

-(void)refresh:(id)sender{
    NSLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self getTimeline];
}

-(IBAction)newFun:(id)sender{
    NewTweetViewController *newTweetVC = [[NewTweetViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:newTweetVC];
    nvc.navigationBar.translucent = NO;
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)redirectLogin{
    LoginViewController *loginView = [[LoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginView];
    [self presentViewController:navi animated:TRUE completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
//    self.tabBarController.navigationItem.title = @"WoFun";
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    titleView.backgroundColor = [UIColor clearColor];
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [titleBtn setTitle:@"WoFun" forState:UIControlStateNormal];
    titleBtn.frame = titleView.frame;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:18];
    [titleBtn.titleLabel setFont:boldFont];
    [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titleBtn];
    self.tabBarController.navigationItem.titleView = titleView;
    
    UIImage *addImage = [UIImage imageNamed:@"write.png"];
    UIBarButtonItem *newFun = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStylePlain target:self action:@selector(newFun:)];
    self.tabBarController.navigationItem.rightBarButtonItem = newFun;
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:nil];
    
//    NSLog(@"TimeLineViewController %@. access_token = %@", NSStringFromSelector(_cmd), access_token);
    [self.tableView reloadData];
}

-(IBAction)titleBtnClick:(id)sender{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweetsArray.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
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
    static NSString *loadMoreCellId = @"loadMoreCellId";
    if (indexPath.row == self.tweetsArray.count){
        UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellId];
        if (tableCell == nil){
            tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellId];
            tableCell.textLabel.text = @"加载更多... ";
            tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
        }

        return tableCell;
    }else{
        TweetViewCell *tableCell = nil;
        tableCell = (TweetViewCell *)[tableView dequeueReusableCellWithIdentifier:tweetCellId];
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
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@, %lu", NSStringFromSelector(_cmd), indexPath.row);
    
    if (indexPath.row < self.tweetsArray.count){
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Homeline" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
        TweetPageViewController *tweetPage = [[TweetPageViewController alloc] initWithStyle:UITableViewStylePlain];
        FunTweet *tweet = [[FunTweet alloc] initWithJson: self.tweetsArray[indexPath.row]];
        if (tweet != nil){
            tweetPage.funTweet = tweet;
            [self.navigationController pushViewController:tweetPage animated:YES];
        }else{
            NSLog(@"%@:%@ fail.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }else{
        /* load more items */
        FunTweet *tweet = [[FunTweet alloc] initWithJson: self.tweetsArray[self.tweetsArray.count - 1]];
        NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
        format.numberStyle = NSNumberFormatterDecimalStyle;
//        NSNumber *maxId = [format numberFromString:tweet.rawId];
//        NSNumber *maxId = [NSNumber numberWithInteger:[tweet.rawId integerValue]];
        NSString *maxId = tweet.id;
        [NetworkUtil getTimeline:0 since_id:0 max_id:maxId  count:[NSNumber numberWithInt:30] page:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);
            
            
            NSArray *array = [NetworkUtil json2TweetArray:operation.responseString];
            if (array.count == 0){
                NSString *text = @"没有更多了";
                [[UIToast makeText:text] show];
            }else{
                int preCount = (int)self.tweetsArray.count;
                [self addObjects2DataSource:array];
                int currentCnt = (int)self.tweetsArray.count;
                
                NSLog(@"%@ success.%ld", NSStringFromSelector(_cmd), self.tweetsArray.count);
                
                //
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                for (int i = preCount; i < currentCnt; i++){
                    NSIndexPath *ipath = [NSIndexPath indexPathForRow:i inSection:0];
                    [indexPaths addObject:ipath];
                }
                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ failure.%@", NSStringFromSelector(_cmd), operation.responseString);
        }];
    }
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



-(FunTweet *)json2Tweet2:(NSDictionary *)jsonObj{
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
    
    [NetworkUtil getTimeline:nil since_id:nil max_id:nil count:[NSNumber numberWithInt:30] page:[NSNumber numberWithInt:1] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);

        [self addObjects2DataSource:[NetworkUtil json2TweetArray:operation.responseString]];
        
        NSComparisonResult (^sortTweetsById)(id obj1, id obj2) = ^(id obj1, id obj2){
            FunTweet *tweet1 = [[FunTweet alloc] initWithJson:(NSDictionary *)obj1];
            FunTweet *tweet2 = [[FunTweet alloc] initWithJson:(NSDictionary *)obj2];
            int rawId1 = [tweet1.rawId intValue];
            int rawId2 = [tweet2.rawId intValue];
            if (rawId1 > rawId2){
                return NSOrderedAscending;
            }else if (rawId1 < rawId2){
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        };
        NSArray *sortedArray = [self.tweetsArray sortedArrayUsingComparator:sortTweetsById];
        [self.tweetsArray removeAllObjects];
        [self.tweetsArray addObjectsFromArray:sortedArray];

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
