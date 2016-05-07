//
//  UILargeImgViewController.m
//  WoFun
//
//  Created by 林勇 on 16/5/7.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "UILargeImgViewController.h"

@interface UILargeImgViewController ()

@end

@implementation UILargeImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
//    self.view.alpha = 0.5;
    
    CGRect mainRect = [UIScreen mainScreen].bounds;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:mainRect];
    imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.alpha = 1;
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    UILongPressGestureRecognizer *longTapReg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapImage:)];
    longTapReg.minimumPressDuration = 1.0f;
    [imageView addGestureRecognizer:longTapReg];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tap];
}
-(void)tap{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self dismissViewControllerAnimated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
