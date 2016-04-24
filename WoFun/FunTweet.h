//
//  Tweet.h
//  WoFun
//
//  Created by 林勇 on 16/4/24.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#ifndef WoFun_Tweet_h
#define WoFun_Tweet_h

#import <Foundation/Foundation.h>

@interface FunTweet : NSObject
@property (nonatomic, weak) NSString *avatar;
@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSString *createTime;
@property (nonatomic, weak) NSString *content;
@end

#endif
