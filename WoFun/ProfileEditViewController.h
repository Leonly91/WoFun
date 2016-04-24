//
//  ProfileEditViewController.h
//  WoFun
//
//  Created by 林勇 on 16/4/16.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileEditViewController : UITableViewController
@property (nonatomic) NSUInteger *userid;
@property (nonatomic, weak) NSString *avatar;
@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSString *location;
@property (nonatomic, weak) NSString *homeurl;
@end
