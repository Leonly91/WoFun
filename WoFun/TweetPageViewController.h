//
//  TweetPageViewController.h
//  WoFun
//
//  Created by 林勇 on 16/5/8.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FunTweet;

@interface TweetPageViewController : UITableViewController
@property (nonatomic) NSString *msgId;
@property (nonatomic) FunTweet *funTweet;
@end
