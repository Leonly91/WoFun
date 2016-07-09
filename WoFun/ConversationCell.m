//
//  ConversationCell.m
//  WoFun
//
//  Created by 林勇 on 16/7/3.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "ConversationCell.h"

@implementation ConversationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect mainScreen = [UIScreen mainScreen].bounds;
    CGRect imageRect = self.imageView.frame;
    self.imageView.frame = CGRectMake(mainScreen.size.width - imageRect.size.width - 10, 0, imageRect.size.width, imageRect.size.height);
}

@end
