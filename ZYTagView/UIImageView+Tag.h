//
//  UIImageView+Tag.h
//  Picooc
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 有品·PICOOC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTagView.h"

@interface UIImageView (Tag)

/** 添加标签 */
- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray;
/** 添加单个标签 */
- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point;
/** 移除所有标签 */
- (void)removeAllTags;
/** 获取当前所有标签信息 */
- (NSArray *)getAllTagInfos;

@end
