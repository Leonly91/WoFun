//
//  ConversationViewController.m
//  WoFun
//
//  Created by 林勇 on 16/7/3.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "ConversationViewController.h"
#import "ConversationCell.h"
#import "NetworkUtil.h"
#import "GlobalVar.h"
#import <AFHTTPRequestOperation.h>
#import <UIImageView+WebCache.h>

@interface ConversationViewController ()
@property (nonatomic) NSMutableArray *conversationArray;
@property (nonatomic) UITableViewCell *prototypeCell;
@property (nonatomic) NSMutableDictionary *heightInfo;
@end

@implementation ConversationViewController

static NSString *receiverCellId = @"receiverCellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.conversationArray = [[NSMutableArray alloc] init];
    self.heightInfo = [[NSMutableDictionary alloc] init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.prototypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:receiverCellId];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self getConversationMsg];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"对话";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}

-(void)getConversationMsg{
    [NetworkUtil getMessageConversation:self.userId page:0 count:0 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
        [self.conversationArray removeAllObjects];
        
        //根据时间排序
        NSArray *sortedArray = [[NetworkUtil parseJsonToArray:operation.responseString] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *dic1 = (NSDictionary *)obj1;
            NSDictionary *dic2 = (NSDictionary *)obj2;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
            NSDate *date1 = [dateFormatter dateFromString:dic1[@"created_at"]];
            NSDate *date2 = [dateFormatter dateFromString:dic2[@"created_at"]];
            return [date1 compare:date2];
        }];
        [self.conversationArray addObjectsFromArray:sortedArray];
        
        BOOL currentUserSenderFlag= [self.conversationArray[0][@"sender"][@"id"] isEqualToString:userId];//TODO :修改为对话人的昵称
        self.navigationItem.title = currentUserSenderFlag? self.conversationArray[0][@"recipient_screen_name"] : self.conversationArray[0][@"sender_screen_name"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@-%@ success.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation.responseString);
    }];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.conversationArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *number = [self.heightInfo objectForKey:indexPath];
    if (number != nil){
        return number.floatValue;
    }
    
    UITableViewCell *cell = self.prototypeCell;
    NSDictionary *conv = (NSDictionary *)self.conversationArray[indexPath.section];
    cell.textLabel.text = conv[@"created_at"];
    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.textLabel sizeToFit];
    cell.detailTextLabel.text = conv[@"text"];
    cell.detailTextLabel.numberOfLines = 0;
    [cell.detailTextLabel sizeToFit];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:16]];
    CGSize maxSize = CGSizeMake(tableView.bounds.size.width - 44, CGFLOAT_MAX);
    CGSize size = [cell.detailTextLabel sizeThatFits:maxSize];
    CGSize size2 = [cell.textLabel sizeThatFits:maxSize];
//    CGFloat h = [cell.contentView systemLayoutSizeFittingSize:UILautFittingCompressedSize].height + 1;
    CGFloat h1 = size.height + size2.height + 20;
    
    [self.heightInfo setObject:[NSNumber numberWithFloat:h1] forKey:indexPath];

    return h1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *senderCellId = @"senderCellId";
    NSDictionary *convDic = (NSDictionary *)self.conversationArray[indexPath.section];
    
    UITableViewCell *cell = nil;
    if (![convDic[@"sender_id"] isEqualToString:userId]){
        cell = [tableView dequeueReusableCellWithIdentifier:receiverCellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:receiverCellId];
        }
    }else{
        cell = (ConversationCell *)[tableView dequeueReusableCellWithIdentifier:senderCellId];
        if (cell == nil){
            cell = [[ConversationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:senderCellId];
            cell.textLabel.textAlignment = NSTextAlignmentRight;
//            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    // Configure the cell...
    
    NSLog(@"conv. imageWidth:%f", cell.imageView.frame.size.width);
    //异步加载图片，完成后需要刷新cell
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:convDic[@"sender"][@"profile_image_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell setNeedsLayout];
    }];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];//Sat Nov 29 13:29:14 +0000 2014
    NSDate *date = [dateFormatter dateFromString:convDic[@"created_at"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.textLabel.text = [dateFormatter stringFromDate:date];
    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
    cell.imageView.layer.cornerRadius = 4.0;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.detailTextLabel.text = convDic[@"text"];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:16]];
    cell.detailTextLabel.numberOfLines = 0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    //背景界面
    cell.detailTextLabel.backgroundColor = [UIColor lightGrayColor];
    cell.detailTextLabel.clipsToBounds = YES;
    cell.detailTextLabel.layer.cornerRadius = 8.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
