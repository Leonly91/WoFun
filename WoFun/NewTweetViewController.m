//
//  NewTweetViewController.m
//  WoFun
//
//  Created by 林勇 on 16/5/7.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "NewTweetViewController.h"
#import "NetworkUtil.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "GlobalVar.h"
#import <NSString+URLEncode.h>

@interface NewTweetViewController ()
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) UIButton *delImgBtn;
@property (nonatomic) NSUInteger textHeight;
@end

//static NSString *postApi = @"http://rest.fanfou.com/statuses/";

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tweetTxtView.text = @"hello.";
    self.textHeight = self.tweetTxtView.contentSize.height;
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"no.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    ;
    self.navigationItem.title = @"发布推文";
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *picBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(photoPick:)];
    UIBarButtonItem *spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *postBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(postTweet:)];
    self.toolBar.items = @[picBtn, spaceBtn, postBtn];

    self.tweetTxtView.delegate = self;
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    
    self.tvHeight.constant = mainRect.size.height - self.toolBar.frame.size.height;//- self.navigationController.navigationBar.frame.size.height;
    self.contentViewHeight.constant = mainRect.size.height;
    self.scrollView.delegate = self;
//    NSLog(@"%@, %f", NSStringFromSelector(_cmd), self.tweetTxtView.frame.size.height);
    
    [self subscribeKeyboardNotificaion];
}

-(void)viewWillLayoutSubviews{
    [self.scrollView setContentSize: CGSizeMake([UIScreen mainScreen].bounds.size.width, self.contentViewHeight.constant + 1)];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.tweetTxtView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self unSubscribeKeyboardNotificaion];
}

-(void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Subscribe keyboard show event
-(void)subscribeKeyboardNotificaion{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)unSubscribeKeyboardNotificaion{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//UIImagePickerControllerDelegate
-(void)photoPick:(id)sender{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (self.imageView == nil){
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.cornerRadius = 8.0f;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
        self.imageView.layer.borderWidth = 3.0f;
        
        UIGestureRecognizer *reg = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(clickImgView:)];
        [self.imageView addGestureRecognizer:reg];
        self.imageView.userInteractionEnabled = YES;
    }
    self.imageView.frame = CGRectMake(0, self.tweetTxtView.contentSize.height, 200, 200);
    self.image = image;
    self.imageView.image = image;
    NSURL *imageUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    self.imageUrl = [imageUrl absoluteString];
    
    if (self.delImgBtn == nil){
        self.delImgBtn = [[UIButton alloc] init];
        UIImage *delImg = [UIImage imageNamed:@"delete-button.png"];
        self.delImgBtn.userInteractionEnabled = YES;
        [self.delImgBtn setImage:delImg forState:UIControlStateNormal];
        self.delImgBtn.titleLabel.text = @"Delete";
        [self.delImgBtn addTarget:self action:@selector(delImgBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.delImgBtn];
    }
    self.delImgBtn.frame = CGRectMake(self.imageView.frame.size.width - 35, 6, 28, 28);
    
    if (![self.tweetTxtView.subviews containsObject:self.imageView]){
        [self.tweetTxtView addSubview:self.imageView];
    }
//    NSLog(@"delImgBtn.frame.%f, %f", self.delImgBtn.frame.origin.x, self.delImgBtn.frame.origin.y);
//    NSLog(@"selected img.frame.%f, %f", self.imageView.frame.origin.x, self.delImgBtn.frame.origin.y);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)postTweet2:(id)sender{
    NSString *txt = @"中文1";
    [NetworkUtil postTweet:txt image:nil completeHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error){
            NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        }else{
            NSLog(@"%@", response);
        }
    }];
}

-(void)postTweet:(id)sender{
    static NSString *txtApi = @"http://api.fanfou.com/statuses/update.json";
    static NSString *photoApi = @"http://api.fanfou.com/photos/upload.json";
    
    if (self.tweetTxtView.text.length == 0 & self.image == nil){
        return;
    }
    NSString *apiUrl = @"";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *parameters = [NetworkUtil getAPIParameters];
    NSDictionary *para2 = [[NSDictionary alloc] initWithDictionary:parameters];
    if (self.tweetTxtView.text.length != 0){
        NSString *haha = @"hello.中文";//\u4E2D\u6587
        NSString *encodeTxt = [self.tweetTxtView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [parameters setObject:haha forKey:@"status"];
        apiUrl = txtApi;
    }
    
    if (self.image != nil && self.imageUrl != nil && self.imageUrl.length != 0){
        NSLog(@"imageUrl:%@", self.imageUrl);
        apiUrl = photoApi;
    }
    NSString *signautre = [NetworkUtil postOauthSignature:apiUrl parameters:parameters secretKey:[NetworkUtil getAPISignSecret]];
//    [parameters setObject:signautre forKey:@"oauth_signature"];
    [parameters setObject:[signautre URLEncode] forKey:@"oauth_signature"];
    
//    NSString *signautre2= [NetworkUtil postOauthSignature:apiUrl parameters:para2 secretKey:[NetworkUtil getAPISignSecret]];
//    [parameters setObject:signautre2 forKey:@"oauth_signature"];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *paraQueryString = [NetworkUtil dic2QueryString:parameters];
    apiUrl = [apiUrl stringByAppendingFormat:@"?%@", paraQueryString];
    
    NSLog(@"apiUrl:%@", apiUrl);
    AFHTTPRequestOperation *operation = [manager POST:apiUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (self.image != nil){
            NSData *imageData = UIImageJPEGRepresentation(self.image, 0.5);
            [formData appendPartWithFileData:imageData name:@"photo" fileName:@"tst.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ failure.code:%ld, %@, %@", NSStringFromSelector(_cmd), (long)operation.response.statusCode, operation.responseString, error);
    }];
    
    [operation start];
    
    [self cancelAction];
}

-(void)clickImgView:(id)sender{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)delImgBtnClick{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.imageView removeFromSuperview];
    self.image = nil;
    self.imageUrl = nil;
}

-(void)keyboardWillShow:(NSNotification *)notification{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.contentView.frame;
    aRect.size.height -= kbSize.height;
    CGRect toolBarRect = _toolBar.frame;
    toolBarRect.origin.y += _toolBar.frame.size.height;
    if (!CGRectContainsPoint(aRect, toolBarRect.origin)){
        [_scrollView scrollRectToVisible:toolBarRect animated:YES];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

/**
 *  检测textview文字变化，根据行数增减修改imageview位置
 *
 *  @param textView
 */
// TODO: 长度限制在140个字符之内
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.contentSize.height != self.textHeight){
//        NSLog(@"%@, %f, %lu", NSStringFromSelector(_cmd), textView.contentSize.height, (unsigned long)self.textHeight);
        
        self.textHeight = textView.contentSize.height;
        
        CGRect rect = self.imageView.frame;
        rect.origin.y = self.textHeight;
        self.imageView.frame = rect;
        [self.imageView setNeedsLayout];
    }
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
