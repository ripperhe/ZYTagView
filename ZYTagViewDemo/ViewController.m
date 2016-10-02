//
//  ViewController.m
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Tag.h"
#import "UIView+zy_Frame.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(20, 50, zy_kScreenW - 80, 300);
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [imageView addGestureRecognizer:tap];
    [self.view addSubview:imageView];
    imageView.zy_centerX = zy_kScreenW / 2.0;
    
    ZYTagInfo *info1 = [ZYTagInfo tagInfo];
    info1.point = CGPointMake(30, 40);
    info1.title = @"我是一个标签";
    ZYTagInfo *info2 = [ZYTagInfo tagInfo];
    info2.proportion = ZYPositionProportionMake(0.5, 0.8);
    info2.title = @"点击图片，添加标签";
    NSArray *array = @[info1, info2];
    [imageView addTagsWithTagInfoArray:array];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:tap.view];
    
    UIAlertController *alVC = [UIAlertController alertControllerWithTitle:@"添加标签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alVC addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *ac = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (((UITextField *)(alVC.textFields[0])).text.length) {
            [((UIImageView *)tap.view) addTagWithTitle:((UITextField *)(alVC.textFields[0])).text point:tapPoint];
        }
    }];
    [alVC addAction:ac];
    
    [self presentViewController:alVC animated:YES completion:nil];
}


@end
