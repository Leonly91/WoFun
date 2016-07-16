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
#import <AFNetworking/AFHTTPRequestOperationManager.h>

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

+ (NSString *)dic2QueryString:(NSDictionary *)parameters{
    NSMutableString *queryString = [[NSMutableString alloc] init];
    int count = 0;
    for (NSString *key in parameters){
        [queryString appendFormat:@"%@=%@", key, parameters[key]];
        count++;
        if (count != parameters.count){
            [queryString appendString:@"&"];
        }
    }
    return [NSString stringWithString:queryString];
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


+(NSArray *)json2TweetArray:(NSString *)jsonString{
    NSError *error = nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil || error != nil){
        NSLog(@"%@ failed.", NSStringFromSelector(_cmd));
        return nil;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray*)jsonObject;
        //        NSLog(@"tweetArray:%lu, %@", (unsigned long)[array count], array);
        
        NSArray *tweetsArray = [NSArray arrayWithArray:array];
        return tweetsArray;
    }
    
    return nil;
}

+ (NSArray *)parseJsonToArray:(NSString *)jsonString{
    if (jsonString == nil)
        return nil;
    
    NSError *error = nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil || error != nil){
        NSLog(@"%@ failed.", NSStringFromSelector(_cmd));
        return nil;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]){
        return (NSArray *)jsonObject;
    }
    return nil;
}

#pragma Common SDK functions
+ (void)postNewTweet:(NSString *)text
               image:(UIImage *)image
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    static NSString *txtApi = @"http://api.fanfou.com/statuses/update.json";
    static NSString *photoApi = @"http://api.fanfou.com/photos/upload.json";
    
    NSString *apiUrl = @"";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    if (text.length != 0){
        [parameters setObject:text forKey:@"status"];
        apiUrl = txtApi;
    }
    if (image != nil){
        apiUrl = photoApi;
    }
    NSString *signautre = [NetworkUtil postOauthSignature:apiUrl parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    //    [parameters setObject:signautre forKey:@"oauth_signature"];
    [parameters setObject:[signautre URLEncode] forKey:@"oauth_signature"];
    
    NSString *paraQueryString = [NetworkUtil dic2QueryString:parameters];
    apiUrl = [apiUrl stringByAppendingFormat:@"?%@", paraQueryString];
    
    NSLog(@"apiUrl:%@", apiUrl);
    AFHTTPRequestOperation *operation = [manager POST:apiUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (image != nil){
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData name:@"photo" fileName:@"tst.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ failure.code:%ld, %@, %@", NSStringFromSelector(_cmd), (long)operation.response.statusCode, operation.responseString, error);
        failure(operation, error);
    }];
    
    [operation start];

}

+ (void)getFavoriteTweetList:(NSString *)userId
                       count:(NSInteger)count
                        page:(NSInteger)page
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
//    static NSString *favoritesListAPI = @"http://rest.fanfou.com/favourites/user_timeline/%@/";
    static NSString *favoritesListAPI = @"http://api.fanfou.com/favorites/%@.json";
    
    NSString *callAPI = [NSString stringWithFormat:favoritesListAPI, userId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    if (0 < count && count <= 60){
        [parameters setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    }
    if (page > 0){
        [parameters setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    }
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];
}

+ (void)getFollowRequest:(NSString *)userId
                    page:(NSInteger)page
                   count:(NSInteger)count
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, id responseObject))failure{
    static NSString *callAPI = @"http://api.fanfou.com/friendships/requests.json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];

}

+ (void)getMessageConversationList:(NSInteger)page
                             count:(NSInteger)count
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, id responseObject))failure{
    static NSString *callAPI = @"http://api.fanfou.com/direct_messages/conversation_list.json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];
}

+ (void)getMessageConversation:(NSString *)userId
                          page:(NSInteger)page
                         count:(NSInteger)count
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, id responseObject))failure{
    static NSString *callAPI = @"http://api.fanfou.com/direct_messages/conversation.json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    if (userId != nil){
        [parameters setObject:userId forKey:@"id"];   
    }
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];
}

+ (void)getFriendList:(NSString *)userId
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation ,id responseObject))failure{
    static NSString *callAPI = @"http://api.fanfou.com/friends/ids.json";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    if (userId != nil){
        [parameters setObject:userId forKey:@"id"];
    }
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];

}

+ (void)getFollowerList:(NSString *)userId
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation ,id responseObject))failure{
    static NSString *callAPI = @"http://api.fanfou.com/followers/ids.json";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    if (userId != nil){
        [parameters setObject:userId forKey:@"id"];
    }
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];
    
}

+ (void)getUserInfo:(NSString *)userId
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation ,id responseObject))failure{
    static NSString *callAPI = @"http://api.fanfou.com/users/show.json";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    if (userId != nil){
        [parameters setObject:userId forKey:@"id"];
    }
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];
}

+ (void)getBlockList:(NSString *)userId
                page:(NSUInteger)page
               count:(NSUInteger)count
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *, id))failure{
    static NSString *callAPI = @"http://api.fanfou.com/blocks/blocking.json";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    
    NSString *signautre = [NetworkUtil getOauthSignature:callAPI parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
    [parameters setObject:signautre forKey:@"oauth_signature"];
    
    AFHTTPRequestOperation *operation = [manager GET:callAPI parameters:parameters success:success failure:failure];
    [operation start];

}

@end
