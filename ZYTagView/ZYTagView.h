//
//  ZYTagView.h
//  ImageTag
//
//  Created by ripper on 2016/9/27.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTagInfo.h"

@interface ZYTagView : UIView

/** 标记信息 */
@property (nonatomic, strong, readonly) ZYTagInfo *tagInfo;

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
/** 关闭删除按钮 */
- (void)hiddenDeleteBtn;
/** 切换删除按钮状态 */
- (void)switchDeleteState;

@end
