//
//  ViewController.m
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ViewController.h"
#import "UIView+ZYTagView.h"
#import "ZYTagImageView.h"

@interface ViewController ()<ZYTagImageViewDelegate>

@property (nonatomic, weak) ZYTagImageView *imageView;
@property (nonatomic, strong) NSArray *tagInfoArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"fan"];

    ZYTagImageView *imageView = [[ZYTagImageView alloc] initWithImage:image];
    imageView.delegate = self;
    imageView.zy_width = zy_kScreenW - 40;
    imageView.zy_height = imageView.zy_width * image.size.height/image.size.width;
    imageView.zy_y = 100;
    imageView.zy_centerX = zy_kScreenW / 2.0;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    //添加标签
    ZYTagInfo *info1 = [ZYTagInfo tagInfo];
    info1.point = CGPointMake(30, 40);
    info1.title = @"我是一个标签";
    
    ZYTagInfo *info2 = [ZYTagInfo tagInfo];
    info2.proportion = ZYPositionProportionMake(0.5, 0.8);
    info2.title = @"点击图片，添加标签";
    
    ZYTagInfo *info3 = [ZYTagInfo tagInfo];
    info3.proportion = ZYPositionProportionMake(0.9, 0.9);
    info3.title = @"长按图片，修改标签";
    
    [imageView addTagsWithTagInfoArray:@[info1, info2, info3]];
    
    //清除标签 恢复标签
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"清除标签" forState:UIControlStateNormal];
    [clearButton setTitle:@"恢复标签" forState:UIControlStateSelected];
    [clearButton addTarget:self action:@selector(clickClearBtn:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton sizeToFit];
    clearButton.zy_x = imageView.zy_x;
    clearButton.zy_y = imageView.zy_bottom + 10;
    [self.view addSubview:clearButton];
    
    //浏览模式 编辑模式
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [editButton setTitle:@"浏览模式" forState:UIControlStateNormal];
    [editButton setTitle:@"编辑模式" forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(clickEditBtn:) forControlEvents:UIControlEventTouchUpInside];
    [editButton sizeToFit];
    editButton.zy_x = imageView.zy_x;
    editButton.zy_y = clearButton.zy_bottom + 10;
    [self.view addSubview:editButton];

}

#pragma mark - event repsonse
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


#pragma mark - ZYTagImageViewDelegate
- (void)tagImageView:(ZYTagImageView *)tagImageView activeTapGesture:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:tagImageView];
    
    UIAlertController *alVC = [UIAlertController alertControllerWithTitle:@"添加标签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alVC addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *ac = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = ((UITextField *)(alVC.textFields[0])).text;
        if (text.length) {
            //添加标签
            [tagImageView addTagWithTitle:text point:tapPoint object:nil];
        }
    }];
    [alVC addAction:ac];
    [self presentViewController:alVC animated:YES completion:nil];
}

- (void)tagImageView:(ZYTagImageView *)tagImageView tagViewActiveTapGesture:(ZYTagView *)tagView
{
    /** 可自定义点击手势的反馈 */
    if (tagView.isEditEnabled) {
        NSLog(@"编辑模式 -- 轻触");
        [tagView switchDeleteState];
    }else{
        NSLog(@"预览模式 -- 轻触");
    }
}

- (void)tagImageView:(ZYTagImageView *)tagImageView tagViewActiveLongPressGesture:(ZYTagView *)tagView
{
    /** 可自定义长按手势的反馈 */
    if (tagView.isEditEnabled) {
        NSLog(@"编辑模式 -- 长按");
        
        UIAlertController *alVC = [UIAlertController alertControllerWithTitle:@"修改标签" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = tagView.tagInfo.title;
        }];
        UIAlertAction *ac = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (((UITextField *)(alVC.textFields[0])).text.length) {
                [tagView updateTitle:((UITextField *)(alVC.textFields[0])).text];
            }
        }];
        [alVC addAction:ac];
        [self presentViewController:alVC animated:YES completion:nil];

    }else{
        NSLog(@"预览模式 -- 长按");
    }
}


@end
