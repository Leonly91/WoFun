//
//  ProfileAvatarTableViewCell.h
//  WoFun
//
//  Created by 林勇 on 16/4/2.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileAvatarTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *username;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *follower;
@property (weak, nonatomic) IBOutlet UILabel *following;
@property (weak, nonatomic) IBOutlet UILabel *messages;
@property (weak, nonatomic) IBOutlet UILabel *favouriteMsg;

@end
