//
//  NewTweetViewController.h
//  WoFun
//
//  Created by 林勇 on 16/5/7.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTweetViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *tweetTxtView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
