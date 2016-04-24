//
//  LoginViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "LoginViewController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "GlobalVar.h"
#import "NetworkUtil.h"
#import "ConfigFileUtil.h"

@interface LoginViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, readonly, copy) NSString *consumer_key;
@property (nonatomic, readonly, copy) NSString *consumer_secret;
@property (nonatomic, copy) NSString *callbackUrl;
@end

static NSString *requestTokenURL = @"http://fanfou.com/oauth/request_token";
static NSString *requestTokenAuthUrl = @"http://m.fanfou.com/oauth/authorize";
static NSString *accessTokenAuthUrl = @"http://fanfou.com/oauth/access_token";

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.callbackUrl = @"www.terrytell.com";
    
    CGRect frame = [UIScreen mainScreen].bounds;
    //frame.size.height -= 300;
    //frame.origin.y += 50;
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    self.webView.delegate = self;
    
    NSLog(@"oauth_token:%@", self.oauth_token);
    if (!self.oauth_token){
        [self OAuthVerify];
    }

    self.navigationItem.title = @"我饭-饭否客户端";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelLogin:)];
    [self.view.window makeKeyAndVisible];
}

-(IBAction)cancelLogin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
}

-(void)OAuthVerify{
    NSString *timeStamp = [NetworkUtil getTimeStamp];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        oauth_consumer_key, @"oauth_consumer_key",
                        @"HMAC-SHA1", @"oauth_signature_method",
                        timeStamp, @"oauth_timestamp",
                        [NetworkUtil createRandomString], @"oauth_nonce", nil];
    //NSLog(@"%@", parameters);

    NSString *signKey = [NSString stringWithFormat:@"%@&", oauth_consumer_secret];
    NSString *oauth_signature = [NetworkUtil getOauthSignature:requestTokenURL parameters:parameters secretKey:signKey];
    [parameters setObject:oauth_signature forKey:@"oauth_signature"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:requestTokenURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"OAuthVerify success:%@", operation.responseString);
        NSDictionary *respon = [NetworkUtil queryString2Dic: operation.responseString];
        self.oauth_token = [respon objectForKey:@"oauth_token"];
        self.oauth_token_secret = [respon objectForKey:@"oauth_token_secret"];
        
        //Show webview to login
        [self.view addSubview:self.webView];
        [self.webView setKeyboardDisplayRequiresUserAction:YES];
        NSString *authorize_url = [NSString stringWithFormat:@"%@?oauth_token=%@&oauth_callback=%@", requestTokenAuthUrl, self.oauth_token, self.callbackUrl];
        NSLog(@"authorize url:%@", authorize_url);
        NSURL *url = [NSURL URLWithString: authorize_url];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Response data:%@", operation.responseData);
        NSLog(@"Response String:%@", operation.responseString);
        NSLog(@"OAuthVerify failure:%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//使用授权过的Request Token换取Access Token
- (void)OAuthAccessToken{
    NSString *timeStamp = [NetworkUtil getTimeStamp];
    NSString *secretKey = [NSString stringWithFormat:@"%@&%@", oauth_consumer_secret, self.oauth_token_secret];
    NSMutableDictionary *parameters= [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      oauth_consumer_key, @"oauth_consumer_key",
                                      self.oauth_token, @"oauth_token",
                                      @"HMAC-SHA1", @"oauth_signature_method",
                                      timeStamp, @"oauth_timestamp",
                                      [NetworkUtil createRandomString], @"oauth_nonce",
                                      nil];
    
    NSString *oauth_signature = [NetworkUtil getOauthSignature:accessTokenAuthUrl parameters:parameters secretKey:secretKey];
    [parameters setObject:oauth_signature forKey:@"oauth_signature"];
    
    NSLog(@"OAuthAccessToken paras:%@", parameters);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:accessTokenAuthUrl parameters:parameters
    success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"OAuthAccessToken success:%@", operation.responseString);
        NSDictionary *respon = [NetworkUtil queryString2Dic: operation.responseString];
        
        access_token = [respon objectForKey:@"oauth_token"];
        access_token_secret = [respon objectForKey:@"oauth_token_secret"];
        
        [ConfigFileUtil writeOAuthConfig];
        
        //Redirect to Home
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"OAuthAccessToken failure.%@", operation.responseString);
        //NSLog(@"%@", error);
    }];
    
}

#pragma UIWebview Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *reqString = [request.URL host];
    NSLog(@"callbakc = %@", [request.URL absoluteString]);
    //access token oauth success
    if ([reqString isEqualToString:self.callbackUrl]){
        //1. Get Access Token
        [self OAuthAccessToken];
        
    }
    
    return true;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
