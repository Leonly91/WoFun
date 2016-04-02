//
//  LoginViewController.h
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, copy) NSString *oauth_token;
@property (nonatomic, copy) NSString *oauth_token_secret;
@end
