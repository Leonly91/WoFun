//
//  UILargeImgViewController.m
//  WoFun
//
//  Created by 林勇 on 16/5/7.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "UILargeImgViewController.h"

@interface UILargeImgViewController ()
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) BOOL doubleTapFlag;
@end

@implementation UILargeImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
//    self.view.alpha = 0.5;
    if (self.imageView){
        self.imageView = nil;
    }
    if (self.scrollView){
        self.scrollView = nil;
    }
    
    self.doubleTapFlag = NO;
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:mainRect];
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 3.0;
    scrollView.minimumZoomScale = 0.5;
    scrollView.zoomScale = 1;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:mainRect];
    imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.alpha = 1;
    imageView.userInteractionEnabled = YES;
    imageView.center = scrollView.center;
    scrollView.contentSize = imageView.frame.size;
    [scrollView addSubview:imageView];
    [self.view addSubview:scrollView];
    self.imageView = imageView;
    self.scrollView = scrollView;
    
    UILongPressGestureRecognizer *longTapReg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapImage:)];
    longTapReg.minimumPressDuration = 1.0f;
    [imageView addGestureRecognizer:longTapReg];
    
    UITapGestureRecognizer *doubleTapReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapImage:)];
    doubleTapReg.numberOfTapsRequired = 2;
    doubleTapReg.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:doubleTapReg];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTapReg];
    [self.view addGestureRecognizer:singleTap];
}

-(void)tap{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doubleTapImage:(id)sender{
    CGFloat currentScale = self.scrollView.zoomScale;
    NSLog(@"%@, %u, %f", NSStringFromSelector(_cmd), _doubleTapFlag, currentScale);
    CGFloat scale = currentScale == 1? (self.doubleTapFlag ?  1 : 2) : 1;
    [self.scrollView setZoomScale:scale animated:YES];
    self.doubleTapFlag = !self.doubleTapFlag;
}

-(IBAction)longTapImage:(UILongPressGestureRecognizer *)recogn{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (recogn.state == UIGestureRecognizerStateBegan){
        
        NSArray *items = @[self.image];
        UIActivityViewController * activityVc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        [self presentViewController:activityVc animated:YES completion:^{
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    if (scrollView.zoomScale >1){
        self.imageView.center = CGPointMake(scrollView.contentSize.width / 2, scrollView.contentSize.height / 2);
        NSLog(@"%@, zoomScale:%f", NSStringFromSelector(_cmd), scrollView.zoomScale);
    }else{
        self.imageView.center = scrollView.center;
        NSLog(@"%@, zoomScale:%f", NSStringFromSelector(_cmd), scrollView.zoomScale);
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
