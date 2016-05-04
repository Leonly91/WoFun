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
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *homeurl;
@end
