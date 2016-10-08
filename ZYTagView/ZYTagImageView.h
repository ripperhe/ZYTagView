//
//  ZYTagImageView.h
//  ZYTagViewDemo
//
//  Created by ripper on 2016/10/3.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTagView.h"
@class ZYTagImageView;

@protocol ZYTagImageViewDelegate <NSObject>

/** 轻触imageView空白区域 */
- (void)tagImageView:(ZYTagImageView *)tagImageView activeTapGesture:(UITapGestureRecognizer *)tapGesture;
@optional
/** 轻触标签 */
- (void)tagImageView:(ZYTagImageView *)tagImageView tagViewActiveTapGesture:(ZYTagView *)tagView;
/** 长按标签 */
- (void)tagImageView:(ZYTagImageView *)tagImageView tagViewActiveLongPressGesture:(ZYTagView *)tagView;

@end

@interface ZYTagImageView : UIImageView

@property (nonatomic, weak) id<ZYTagImageViewDelegate> delegate;
@property (nonatomic, assign) BOOL isEditEnable;

/** 添加标签 */
- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray;
/** 添加单个标签 */
- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point object:(id)object;
/** 设置标签是否可编辑 */
- (void)setAllTagsEditEnable:(BOOL)isEditEnabled;
/** 隐藏所有标签的删除按钮 */
- (void)hiddenAllTagsDeleteBtn;
/** 移除所有标签 */
- (void)removeAllTags;
/** 获取当前所有标签信息 */
- (NSArray *)getAllTagInfos;

@end
