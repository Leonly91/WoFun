//
//  AFURLConnectionOperation+Recover.h
//  WoFun
//
//  Created by 林勇 on 16/5/15.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#ifndef WoFun_AFURLConnectionOperation_Recover_h
#define WoFun_AFURLConnectionOperation_Recover_h

#import <AFNetworking/AFURLConnectionOperation.h>

@interface AFURLConnectionOperation (Recover)
- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request;
@end

#endif
