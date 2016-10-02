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

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSArray *tagInfoArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"fan"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.zy_width = zy_kScreenW - 40;
    imageView.zy_height = imageView.zy_width * image.size.height/image.size.width;
    imageView.zy_y = 100;
    imageView.zy_centerX = zy_kScreenW / 2.0;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    //手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [imageView addGestureRecognizer:tap];
    imageView.userInteractionEnabled = YES;
    
    ZYTagInfo *info1 = [ZYTagInfo tagInfo];
    info1.point = CGPointMake(30, 40);
    info1.title = @"我是一个标签";
    
    ZYTagInfo *info2 = [ZYTagInfo tagInfo];
    info2.proportion = ZYPositionProportionMake(0.5, 0.8);
    info2.title = @"点击图片，添加标签";
    
    [imageView addTagsWithTagInfoArray:@[info1, info2]];
    
    
    
    //清除标签
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"清除标签" forState:UIControlStateNormal];
    [clearButton setTitle:@"恢复标签" forState:UIControlStateSelected];
    [clearButton addTarget:self action:@selector(clickClearBtn:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton sizeToFit];
    clearButton.zy_x = imageView.zy_x;
    clearButton.zy_y = imageView.zy_bottom + 10;
    [self.view addSubview:clearButton];
    
    //隐藏、显示标签
    
    //可编辑、不可编辑
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [editButton setTitle:@"不可编辑" forState:UIControlStateNormal];
    [editButton setTitle:@"允许编辑" forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(clickEditBtn:) forControlEvents:UIControlEventTouchUpInside];
    [editButton sizeToFit];
    editButton.zy_x = imageView.zy_x;
    editButton.zy_y = clearButton.zy_bottom + 10;
    [self.view addSubview:editButton];

    
    //允许更改title 允许传object
    
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

- (void)clickClearBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;

    if (btn.selected) {
        self.tagInfoArray = [self.imageView getAllTagInfos];
        [self.imageView removeAllTags];
    }else{
        [self.imageView addTagsWithTagInfoArray:self.tagInfoArray];
    }
}

- (void)clickEditBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    [self.imageView setAllTagsEditEnable:!btn.selected];
}



@end
