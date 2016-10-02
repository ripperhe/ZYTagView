//
//  UIImageView+Tag.m
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "UIImageView+Tag.h"

@implementation UIImageView (Tag)

- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray
{
    for (ZYTagInfo *tagInfo in tagInfoArray) {
        ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:tagInfo];
        tagView.delegate = self;
        [self addSubview:tagView];
        [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
    }
}

- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point
{
    ZYTagInfo *tagInfo = [ZYTagInfo tagInfo];
    tagInfo.point = point;
    tagInfo.title = title;
    ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:tagInfo];
    tagView.delegate = self;
    [self addSubview:tagView];
    [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
}

- (void)setAllTagsEditEnable:(BOOL)isEditEnabled
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZYTagView class]]) {
            ((ZYTagView *)view).isEditEnabled = isEditEnabled;
            if (isEditEnabled == NO) {
                [(ZYTagView *)view hiddenDeleteBtn];
            }
        }
    }
}

- (void)hiddenAllTagsDeleteBtn
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZYTagView class]]) {
            [(ZYTagView *)view hiddenDeleteBtn];
        }
    }
}

- (void)removeAllTags
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZYTagView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (NSArray *)getAllTagInfos
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZYTagView class]]) {
            [array addObject:((ZYTagView *)view).tagInfo];
        }
    }
    return array;
}

#pragma mark - ZYTagViewDelegate
- (void)tagViewActiveTapGesture:(ZYTagView *)tagView
{
    /** 可自定义点击手势的反馈 */
    [tagView switchDeleteState];
}

- (void)tagViewActiveLongPressGesture:(ZYTagView *)tagView
{
    /** 可自定义长按手势的反馈 */
    [tagView showDeleteBtn];
}
@end
