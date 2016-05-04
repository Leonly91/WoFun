//
//  Tweet.m
//  WoFun
//
//  Created by 林勇 on 16/4/24.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunTweet.h"

@implementation FunTweet

-(instancetype)initWithJson:(NSDictionary *)jsonObj{
    if (self = [super init]){
        self.rawId = jsonObj[@"rawid"];
        self.content = jsonObj[@"text"];
        self.username = jsonObj[@"user"][@"name"];
        self.createTime = jsonObj[@"created_at"];
        self.avatar = jsonObj[@"user"][@"profile_image_url_large"];
        self.photoUrl = jsonObj[@"photo"][@"largeurl"];
    }
    return self;
}

-(NSString*)getCreateTimeLabel{
    
    return _createTimeLabel;
}

@end