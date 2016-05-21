//
//  ConfigFileUtil.m
//  WoFun
//
//  Created by 林勇 on 16/4/24.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigFileUtil.h"
#import "GlobalVar.h"

static NSString *configFileName = @"config";

@implementation ConfigFileUtil

+(void)readOAuthConfig{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    NSString *token = [dictionary objectForKey:@"access_token"];
    NSString *secret = [dictionary objectForKey:@"access_token_secret"];
    NSString *user_id = [dictionary objectForKey:@"user_id"];
    if (token.length){
        access_token = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"access_token"]];
    }else{
        access_token = @"1277466-d4bf74db0b1a35b0a8e4af706e105c9b";
    }
    
    if (secret.length){
        access_token_secret = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"access_token_secret"]];
    }else{
        access_token_secret = @"46ce20e4adbc7868299f2ac10b55df16";
    }
    
    if (userId.length){
        userId = [NSString stringWithFormat:@"%@", user_id];
    }
    
    NSLog(@"readConfig. access_token = %@, access_secret = %@, userId = %@", access_token, access_token_secret, userId);
}

+(void)writeOAuthConfig{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [dictionary setValue:access_token forKey:@"access_token"];
    [dictionary setValue:access_token_secret forKey:@"access_token_secret"];
    [dictionary setValue:userId forKey:@"user_id"];
    
    [dictionary writeToFile:plistPath atomically:YES];
    
    NSLog(@"writeConfig. access_token = %@, access_secret = %@, userId = %@", access_token, access_token_secret, userId);
}


@end