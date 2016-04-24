//
//  ConfigFileUtil.h
//  WoFun
//
//  Created by 林勇 on 16/4/24.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#ifndef WoFun_ConfigFileUtil_h
#define WoFun_ConfigFileUtil_h

@interface ConfigFileUtil : NSObject
+(void)readOAuthConfig;
+(void)writeOAuthConfig;
@end

#endif
