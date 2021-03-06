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
#import <UIToast.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <JZLocationConverter.h>

@interface NewTweetViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) UIButton *delImgBtn;
@property (nonatomic) NSUInteger textHeight;
@property (nonatomic) UIBarButtonItem *locationTxt;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MKMapView *mapView;
@property (nonatomic, copy) NSString *location;
@property (nonatomic) CGFloat keyboardHeight;
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
    UIBarButtonItem *locationBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"] style:UIBarButtonItemStylePlain target:self action:@selector(getLocation:)];
    UIBarButtonItem *locatonTxt = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.locationTxt = locatonTxt;
    self.locationTxt.enabled = NO;
    UIBarButtonItem *spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *postBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(postTweet:)];
    self.toolBar.items = @[picBtn, locationBtn, locatonTxt, spaceBtn, postBtn];

    self.tweetTxtView.delegate = self;
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    
    self.tvHeight.constant = mainRect.size.height - self.toolBar.frame.size.height;//- self.navigationController.navigationBar.frame.size.height;
    self.contentViewHeight.constant = mainRect.size.height;
    self.scrollView.delegate = self;
//    NSLog(@"%@, %f", NSStringFromSelector(_cmd), self.tweetTxtView.frame.size.height);
    
    [self subscribeKeyboardNotificaion];
    
    if (self.mapView == nil){
        self.mapView = [[MKMapView alloc] init];
        self.mapView.hidden = YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        self.mapView.delegate = self;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.keyboardHeight = 0;
}

-(void)viewWillLayoutSubviews{
    [self.scrollView setContentSize: CGSizeMake([UIScreen mainScreen].bounds.size.width, self.contentViewHeight.constant + 1)];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.mapView setShowsUserLocation:YES];
    
    [self.tweetTxtView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.locationManager != nil){
        [self.locationManager stopUpdatingLocation];
    }
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

/**
 *  获取地理位置
 *
 *  @param sender <#sender description#>
 */
-(IBAction)getLocation:(id)sender{
    if (self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.locationManager.distanceFilter = 500;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"%@-%@ call.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

-(IBAction)getLocation2:(id)sender{
    [self.mapView setShowsUserLocation:YES];
    NSLog(@"%@-%@ call.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocation *location = userLocation.location;
    NSLog(@"coordinate:%f,%f", location.coordinate.latitude, location.coordinate.longitude);
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    NSLog(@"%@-%@ call.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    NSLog(@"%@ error:%@.", NSStringFromSelector(_cmd), error);
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"%@ error:%@.", NSStringFromSelector(_cmd), error);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@-%@ fail:%@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
    NSString *toastText = [NSString stringWithFormat:@"获取地理位置失败:%ld", (long)error.code];
    [[UIToast makeText:toastText] show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"%@-coordinate:count-%lu,%f-%f", NSStringFromSelector(_cmd), locations.count,currLocation.coordinate.latitude, currLocation.coordinate.longitude);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocationCoordinate2D wgs84Location = CLLocationCoordinate2DMake(currLocation.coordinate.latitude, currLocation.coordinate.longitude);
    CLLocationCoordinate2D gcj02Location = [JZLocationConverter gcj02ToWgs84:wgs84Location];
    NSLog(@"gcj01Location:{%f-%f}", gcj02Location.latitude, gcj02Location.longitude);
    [geocoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0){
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@ name:%@", NSStringFromSelector(_cmd), placemark.name);
            
            NSString *city = placemark.locality;
            if (!city){
                city = placemark.administrativeArea;
            }
            NSLog(@"%@ count:%lu city:%@, country:%@", NSStringFromSelector(_cmd), placemarks.count ,city, placemark.country);
            self.locationTxt.title = city;
            self.location = city;
        }else if (error == nil){
            [[UIToast makeText:@"返回结果为空"] show];
        }else{
            [[UIToast makeText:@"获取地理位置发生错误"] show];
        }
    }];
    
    [self.locationManager stopUpdatingLocation];
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

-(void)postTweet1:(id)sender{
    if (self.tweetTxtView.text.length == 0 && self.image == nil){
        NSLog(@"%@-%@ tweetTxtView txt & image is empty!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    NSString *txt = self.tweetTxtView.text;
    [NetworkUtil postTweet:txt image:self.image completeHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error){
            NSLog(@"%@-%@ failure.%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
            NSLog(@"response:%@", response);
        }else{
            NSLog(@"%@", response);
        }
    }];
}

-(void)postTweet:(id)sender{
    if (self.tweetTxtView.text.length == 0 && self.image == nil && self.imageUrl.length == 0){
        return ;
    }
    
    [NetworkUtil postNewTweet:self.tweetTxtView.text image:self.image location:self.location success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@ success.%@", NSStringFromSelector(_cmd), operation.responseString);
        
        NSString *text = @"发送成功";
        [[UIToast makeText:text] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ failure.code:%ld, %@, %@", NSStringFromSelector(_cmd), (long)operation.response.statusCode, operation.responseString, error);
    }];
    
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
    
    NSLog(@"%@.keyboard height:%f", NSStringFromSelector(_cmd), kbSize.height);
    self.keyboardHeight = kbSize.height;
    
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
    
    self.keyboardHeight = 0;
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

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"%@.%f.", NSStringFromSelector(_cmd), scrollView.contentInset.bottom);
    //fix 滚动时toolbar被keyboard覆盖

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    CGFloat toolbarHeight = self.keyboardHeight > 0? (self.toolBar.frame.size.height) : 0;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, self.keyboardHeight + toolbarHeight, 0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
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
