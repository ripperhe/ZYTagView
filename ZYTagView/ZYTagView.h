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

@property (nonatomic, strong, readonly) ZYTagInfo *tagInfo;


- (instancetype)initWithTagInfo:(ZYTagInfo *)tagInfo;
- (void)updateTitle:(NSString *)title;

@end
