//
//  ProfileEditViewController.m
//  WoFun
//
//  Created by 林勇 on 16/4/16.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileEditViewController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "NetworkUtil.h"
#import <NSString+URLEncode.h>
#import <UIImageView+WebCache.h>

@interface ProfileEditViewController ()
@property (nonatomic) NSArray *array;
@property (nonatomic) NSMutableArray *valueArray;
@end

@implementation ProfileEditViewController

static NSString *cellId = @"editProfileCellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    self.view.backgroundColor = self.tableView.separatorColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.array = @[@"昵称", @"位置", @"主页"];
    self.valueArray = [[NSMutableArray alloc] init];
    self.valueArray[0] = self.username;
    self.valueArray[1] = self.location;
    self.valueArray[2] = self.homeurl;
    
    NSLog(@"value:%@", self.valueArray);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"EditProfile";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveProfile:)];
}

-(IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(IBAction)saveProfile:(id)sender{
    //SAVE PROFILE
    [self updateProfile];
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)updateProfile{
    NSString *url = @"http://api.fanfou.com/account/update_profile.json";
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    // TODO: urlencode
    NSString *username = self.valueArray[0];
    NSString *location = self.valueArray[1];
    NSString *homeurl = self.valueArray[2];
    
    [parameters setObject:username forKey:@"name"];
    [parameters setObject:location forKey:@"location"];
    [parameters setObject:homeurl forKey:@"url"];
    NSString *signautre = [NetworkUtil postOauthSignature:url parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded;charset=utf-8"];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"updateProfile success.%@", operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"updateProfile failure.code:%ld, %@", (long)operation.response.statusCode, operation.responseString);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0){
        return 1;
    }
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 20;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = @"ProfileEdit";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0){
        NSString *imageUrl = self.avatar;
//        UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        cell.textLabel.text = @"头像";
    }else if(indexPath.section == 1){
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", self.array[indexPath.row], self.valueArray[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"didSelectRow:%lu, section:%lu", indexPath.row, indexPath.section);

    if (indexPath.section == 0){
        UIAlertController *avatarAlert = [UIAlertController alertControllerWithTitle:@"Update Avatar" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        [avatarAlert addAction:photoAction];
        [avatarAlert addAction:cameraAction];
        [avatarAlert addAction:cancelAction];
        
        [self presentViewController:avatarAlert animated:TRUE completion:nil];
        
    }else if(indexPath.section == 1){
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:self.array[indexPath.row] message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.valueArray[indexPath.row];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            UITextField *textField = alertCtrl.textFields.firstObject;
            self.valueArray[indexPath.row] = textField.text;
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", self.array[indexPath.row], self.valueArray[indexPath.row]];
        }];
        [alertCtrl addAction:cancelAction];
        [alertCtrl addAction:okAction];
        
        [self presentViewController:alertCtrl animated:true completion:nil];
    }
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
