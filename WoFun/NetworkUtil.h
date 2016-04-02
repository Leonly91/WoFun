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
+ (NSDictionary *)queryString2Dic:(NSString *)queryString;
+ (NSString *)getTimeStamp;
+(NSMutableDictionary *)getAPIParameters;
@end

#endif
