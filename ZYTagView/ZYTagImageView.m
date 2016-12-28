//
//  ZYTagImageView.m
//  ZYTagViewDemo
//
//  Created by ripper on 2016/10/3.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ZYTagImageView.h"

@interface ZYTagImageView ()<ZYTagViewDelegate>

@end


@implementation ZYTagImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.isEditEnable = YES;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tap];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    if (self.isEditEnable == NO) {
        return;
    }

    if (tap.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(tagImageView:activeTapGesture:)]) {
            [self.delegate tagImageView:self activeTapGesture:tap];
        }
    }
}

#pragma mark - public methods
- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray
{
    for (ZYTagInfo *tagInfo in tagInfoArray) {
        ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:tagInfo];
        tagView.delegate = self;
        tagView.isEditEnabled = self.isEditEnable;
        [self addSubview:tagView];
        [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
    }
}

- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point object:(id)object
{
    ZYTagInfo *tagInfo = [ZYTagInfo tagInfo];
    tagInfo.point = point;
    tagInfo.title = title;
    tagInfo.object = object;
    ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:tagInfo];
    tagView.delegate = self;
    tagView.isEditEnabled = self.isEditEnable;
    [self addSubview:tagView];
    [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
}

- (void)setAllTagsEditEnable:(BOOL)isEditEnabled
{
    self.isEditEnable = isEditEnabled;
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
    if ([self.delegate respondsToSelector:@selector(tagImageView:tagViewActiveTapGesture:)]) {
        [self.delegate tagImageView:self tagViewActiveTapGesture:tagView];
    }else{
        // 默认
        [tagView switchDeleteState];
    }
}

- (void)tagViewActiveLongPressGesture:(ZYTagView *)tagView
{
    if ([self.delegate respondsToSelector:@selector(tagImageView:tagViewActiveLongPressGesture:)]) {
        [self.delegate tagImageView:self tagViewActiveLongPressGesture:tagView];
    }
}


@end
