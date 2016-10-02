//
//  UIImageView+Tag.h
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTagView.h"

@interface UIImageView (Tag)<ZYTagViewDelegate>

/** 添加标签 */
- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray;
/** 添加单个标签 */
- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point;
/** 设置标签是否可编辑 */
- (void)setAllTagsEditEnable:(BOOL)isEditEnabled;
/** 隐藏所有标签的删除按钮 */
- (void)hiddenAllTagsDeleteBtn;
/** 移除所有标签 */
- (void)removeAllTags;
/** 获取当前所有标签信息 */
- (NSArray *)getAllTagInfos;

@end
