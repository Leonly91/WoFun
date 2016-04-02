//
//  NewMessageViewController.m
//  WoFun
//
//  Created by 林勇 on 16/3/13.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "NewMessageViewController.h"

@interface NewMessageViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"New Fun Message";
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(post:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Set Post button default to gray color
//    self.navigationItem.rightBarButtonItem setTitleTextAttributes:<#(NSDictionary *)#> forState:<#(UIControlState)#>
}

//Back to TimeLineView
-(IBAction)cancel:(id)sender
{
    [self backToTimeLine];
}

//Post a new message and then back to TimeLine
-(IBAction)post:(id)sender
{
    //Post a new message
    
    
    [self backToTimeLine];
}

-(void)backToTimeLine{
    [self dismissViewControllerAnimated:YES completion:nil];
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
