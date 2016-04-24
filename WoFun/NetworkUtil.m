//
//  NetworkUtil.m
//  WoFun
//
//  Created by 林勇 on 16/4/2.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <GTMBase64.h>
#import <NSString+URLEncode.h>
#import "NetworkUtil.h"
#import "GlobalVar.h"

@implementation NetworkUtil

const NSUInteger NUMBER_OF_CHARS = 40 ;

+(NSString *) createRandomString{
    unichar characters[NUMBER_OF_CHARS];
    for( int index=0; index < NUMBER_OF_CHARS; ++index )
    {
        characters[ index ] = 'A' + arc4random_uniform(26) ;
    }
    
    return [ NSString stringWithCharacters:characters length:NUMBER_OF_CHARS ] ;
}

/* *** **
 * The Base64Transcoder library is the work of Jonathan Wright,
 * available at http://code.google.com/p/oauth/.
 * *** **
 */
+ (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    NSData *base64 = [[NSData alloc] initWithBytes:result length:sizeof(result)];
    NSData *base64EncodedResult = [GTMBase64 encodeData:base64];
    NSString *base64String = [[NSString alloc] initWithData:base64EncodedResult encoding:NSUTF8StringEncoding];
    return base64String;
}

+(NSString *)convertOauthSignature:(NSString *)method baseUrl:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey{
    NSString *urlencode = [baseUrl URLEncode];
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    for (NSString *key in sortedKeys) {
        [sortedArray addObject: [NSString stringWithFormat:@"%@=%@", key, [[NSString stringWithFormat:@"%@", [parameters objectForKey: key]] URLEncode]  ]];
//        [sortedArray addObject: [NSString stringWithFormat:@"%@=%@", key, [parameters objectForKey: key] ]];
    }
    NSLog(@"sortedArray:%@", sortedArray);
    NSString *queryString = [sortedArray componentsJoinedByString:@"&"];
    NSLog(@"queyryString:%@", queryString);
    
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@", method, urlencode, [queryString URLEncode]];
    NSLog(@"baseString:%@", baseString);
    //NSLog(@"secretKey:%@", secretKey);
    return [self hmacsha1:baseString key: [NSString stringWithFormat:@"%@", secretKey]];//注意：后面加&号
}

+(NSString *)getOauthSignature:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey{
    return [self convertOauthSignature:@"GET" baseUrl:baseUrl parameters:parameters secretKey:secretKey];
}

+(NSString *)postOauthSignature:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey{
    return [self convertOauthSignature:@"POST" baseUrl:baseUrl parameters:parameters secretKey:secretKey];
}

+(NSString *)putOauthSignature:(NSString *)baseUrl parameters:(NSDictionary *)parameters secretKey:(NSString *)secretKey{
    return [self convertOauthSignature:@"PUT" baseUrl:baseUrl parameters:parameters secretKey:secretKey];
}

// TODO: Fetch to Utility
+(NSDictionary *)queryString2Dic:(NSString *)queryString
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *para in parameters) {
        NSArray *array = [para componentsSeparatedByString:@"="];
        [dic setObject:array[1] forKey:array[0]];
    }
    return dic;
}

+(NSString *)getTimeStamp
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long dTime = [[NSNumber numberWithDouble: time] longLongValue];
    NSString *timeStamp = [NSString stringWithFormat:@"%llu", dTime];
    return timeStamp;
}


+(NSMutableDictionary *)getAPIParameters{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                    oauth_consumer_key, @"oauth_consumer_key",
                    access_token, @"oauth_token",
                    @"HMAC-SHA1", @"oauth_signature_method",
                    [NetworkUtil getTimeStamp], @"oauth_timestamp",
                    [NetworkUtil createRandomString], @"oauth_nonce",
                    nil];
    return parameters;
}

+(NSString *)getAPISignSecret{
    return [NSString stringWithFormat:@"%@&%@",oauth_consumer_secret, access_token_secret];
}

@end
