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

- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray;
- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point;
- (void)removeAllTags;
- (NSArray *)getAllTagInfo;


@end
