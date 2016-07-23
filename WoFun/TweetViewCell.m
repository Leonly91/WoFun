//
//  TweetViewCell.m
//  WoFun
//
//  Created by 林勇 on 16/4/24.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "TweetViewCell.h"

@implementation TweetViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame{
    frame.origin.x += 5;
    frame.size.width -= 10;
    [super setFrame:frame];
}

-(void)layoutSubviews{
    //上下边界分割线
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor grayColor].CGColor;
    bottomBorder.opacity = 0.2;
    bottomBorder.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 3);
//    [self.layer addSublayer:bottomBorder];
    
    //两边阴影效果
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0, 0, 0.5, self.frame.size.height);
    leftBorder.backgroundColor = [UIColor grayColor].CGColor;
    leftBorder.opacity = 0.5;
    leftBorder.shadowColor = [UIColor blackColor].CGColor;
    leftBorder.shadowOffset = CGSizeMake(-3, 0);
    leftBorder.shadowOpacity = 1.0;
//    [self.layer addSublayer:leftBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(self.frame.size.width - 0.5, 0, 0.5, self.frame.size.height);
    rightBorder.backgroundColor = [UIColor grayColor].CGColor;
    rightBorder.shadowColor = [UIColor grayColor].CGColor;
    rightBorder.shadowOffset = CGSizeMake(3, 0);
    rightBorder.shadowOpacity = 1.0;
//    [self.layer addSublayer:rightBorder];
}

@end
