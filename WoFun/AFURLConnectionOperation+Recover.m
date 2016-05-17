//
//  AFURLConnectionOperation+Recover.m
//  WoFun
//
//  Created by 林勇 on 16/5/15.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLConnectionOperation+Recover.h"

@implementation AFURLConnectionOperation (Recover)

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request{
    if ([request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]){
        return [request.HTTPBodyStream copy];
    }
    return nil;
}

@end