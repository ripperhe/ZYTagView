//
//  UIImageView+Tag.m
//  Picooc
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 有品·PICOOC. All rights reserved.
//

#import "UIImageView+Tag.h"

@implementation UIImageView (Tag)

- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray
{
    for (ZYTagInfo *tagInfo in tagInfoArray) {
        ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:tagInfo];
        [self addSubview:tagView];
    }
}

- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point
{
    ZYTagInfo *tagInfo = [ZYTagInfo tagInfo];
    tagInfo.point = point;
    tagInfo.title = title;
    ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:tagInfo];
    [self addSubview:tagView];
    [tagView showAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tagView closeAnimation];
    });
}

- (void)removeAllTags
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZYTagView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (NSArray *)getAllTagInfo
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZYTagView class]]) {
            [array addObject:((ZYTagView *)view).tagInfo];
        }
    }
    return array;
}


@end
