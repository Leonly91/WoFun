//
//  NetworkUtil.h
//  WoFun
//
//  Created by 林勇 on 16/4/2.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#ifndef WoFun_NetworkUtil_h
#define WoFun_NetworkUtil_h

@interface NetworkUtil : NSObject
+ (NSString *) createRandomString;
+ (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret ;
+ (NSString *)getOauthSignature:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey;
+ (NSString *)postOauthSignature:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey;
+ (NSString *)putOauthSignature:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey;
+ (NSDictionary *)queryString2Dic:(NSString *)queryString;
+ (NSString *)dic2QueryString:(NSDictionary *)parameters;
+ (NSString *)getTimeStamp;
+ (NSMutableDictionary *)getAPIParameters;
+ (NSString *)getAPISignSecret;
@end

#endif
