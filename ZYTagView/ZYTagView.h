//
//  ZYTagView.h
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTagInfo.h"
@class ZYTagView;

@protocol ZYTagViewDelegate <NSObject>

@optional
/** 触发轻触手势 */
- (void)tagViewActiveTapGesture:(ZYTagView *)tagView;
/** 触发长按手势 */
- (void)tagViewActiveLongPressGesture:(ZYTagView *)tagView;

@end

@interface ZYTagView : UIView

/** 代理 */
@property (nonatomic, weak) id<ZYTagViewDelegate> delegate;
/** 标记信息 */
@property (nonatomic, strong, readonly) ZYTagInfo *tagInfo;
/** 是否可编辑 default is YES */
@property (nonatomic, assign) BOOL isEditEnabled;


/** 初始化 */
- (instancetype)initWithTagInfo:(ZYTagInfo *)tagInfo;
/** 更新标题 */
- (void)updateTitle:(NSString *)title;
/** 显示动画 */
- (void)showAnimationWithRepeatCount:(float)repeatCount;
/** 移除动画 */
- (void)removeAnimation;
/** 显示删除按钮 */
- (void)showDeleteBtn;
/** 隐藏删除按钮 */
- (void)hiddenDeleteBtn;
/** 切换删除按钮状态 */
- (void)switchDeleteState;

@end
