//
//  FavoritedViewController.m
//  WoFun
//
//  Created by 林勇 on 16/6/27.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "FavoritedViewController.h"
#import "NetworkUtil.h"
#import "TweetViewCell.h"
#import "FunTweet.h"
#import "UILargeImgViewController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>

@interface FavoritedViewController ()
@property (nonatomic) NSMutableDictionary *tweetsDic;
@property (nonatomic) NSMutableArray *tweetsArray;
@end

@implementation FavoritedViewController

static NSString *tweetCellId = @"TweetViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tweetsDic = [[NSMutableDictionary alloc] init];
    self.tweetsArray = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:tweetCellId bundle:nil] forCellReuseIdentifier:tweetCellId];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"收藏";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    [self getAllFavoriteTweet];
}

-(void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma REST API CALL
/**
 *  获取用户的收藏消息
 */
- (void)getAllFavoriteTweet{
    [NetworkUtil getFavoriteTweetList:self.userId count:0 page:0 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        
        [self addObjects2DataSource:[NetworkUtil json2TweetArray:operation.responseString]];
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@-%@ failure: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.tweetsArray.count;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetViewCell *tableCell = (TweetViewCell *)[tableView dequeueReusableCellWithIdentifier:tweetCellId];
    if (tableCell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:tweetCellId owner:self options:nil];
        tableCell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
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
            
            UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto:)];
            [tableCell.photoImage addGestureRecognizer:tapRec];
        }
    }
    
    tableCell.tweetContent.scrollEnabled = false;
    
    return tableCell;
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

/**
 * 显示图片原图，支持手指缩放
 */
-(IBAction)tapPhoto:(id)sender{
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
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
//    [window.rootViewController presentViewController:largeImgv animated:YES completion:nil];
    [self.navigationController presentViewController:largeImgv animated:YES completion:nil];
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


@end
