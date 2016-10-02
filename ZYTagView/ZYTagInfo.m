//
//  ZYTagInfo.m
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ZYTagInfo.h"

@implementation ZYTagInfo

ZYPositionProportion ZYPositionProportionMake(CGFloat x, CGFloat y)
{
    ZYPositionProportion p; p.x = x; p.y = y; return p;
}

+ (instancetype)tagInfo
{
    return [[self alloc] init];
}

@end
