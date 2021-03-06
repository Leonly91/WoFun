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
@property (nonatomic) NSString *id;
@property (nonatomic) NSString *rawId;
@property (nonatomic, weak) NSString *avatar;
@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSString *createTime;
@property (nonatomic, weak) NSString *content;
@property (nonatomic, weak, readonly) NSString *createTimeLabel;
@property (nonatomic, weak) NSString *photoUrl;
@property (nonatomic) bool favorited;

-(instancetype)initWithJson:(NSDictionary *)jsonObj;
@end

#endif
