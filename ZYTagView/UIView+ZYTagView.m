//
//  UIView+ZYTagView.m
//  ZYCategory
//
//  Created by ripper on 16/4/30.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "UIView+ZYTagView.h"
#import <objc/runtime.h>

const char *zy_leftBorderKey = "zy_leftBorderKey";
const char *zy_rightBorderKey = "zy_rightBorderKey";
const char *zy_topBorderKey = "zy_topBorderKey";
const char *zy_bottomBorderKey = "zy_bottomBorderKey";

@implementation UIView (ZYTagView)

#pragma mark - origin、size
- (CGPoint)zy_origin
{
    return self.frame.origin;
}

- (void)setZy_origin:(CGPoint)aPonit
{
    CGRect newframe = self.frame;
    newframe.origin = aPonit;
    self.frame = newframe;
}

- (CGSize)zy_size
{
    return self.frame.size;
}

- (void)setZy_size:(CGSize)aSize
{
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

#pragma mark - bottomRight、bottomLeft、topRight
- (CGPoint)zy_bottomRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)zy_bottomLeft
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)zy_topRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

#pragma mark - height、width、top、left、bottom、right、centerX、centerY
- (CGFloat)zy_height
{
    return self.frame.size.height;
}

- (void)setZy_height:(CGFloat)newHeight
{
    CGRect newframe = self.frame;
    newframe.size.height = newHeight;
    self.frame = newframe;
}

- (CGFloat)zy_width
{
    return self.frame.size.width;
}

- (void)setZy_width:(CGFloat)newWidth
{
    CGRect newframe = self.frame;
    newframe.size.width = newWidth;
    self.frame = newframe;
}

- (CGFloat)zy_x
{
    return self.frame.origin.x;
}

- (void)setZy_x:(CGFloat)newX
{
    CGRect newframe = self.frame;
    newframe.origin.x = newX;
    self.frame = newframe;
}

- (CGFloat)zy_y
{
    return self.frame.origin.y;
}

- (void)setZy_y:(CGFloat)newY
{
    CGRect newframe = self.frame;
    newframe.origin.y = newY;
    self.frame = newframe;
}

- (CGFloat)zy_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setZy_bottom:(CGFloat)newBottom
{
    CGRect newframe = self.frame;
    newframe.origin.y = newBottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)zy_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setZy_right:(CGFloat)newRight
{
    CGFloat delta = newRight - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

- (CGFloat)zy_centerX
{
    return self.center.x;
}

- (void)setZy_centerX:(CGFloat)centerX
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = centerX- newFrame.size.width/2 ;
    self.frame = newFrame;
}

- (CGFloat)zy_centerY
{
    return self.center.y ;
}

- (void)setZy_centerY:(CGFloat)centerY
{
    CGRect newFrame = self.frame;
    newFrame.origin.y = centerY - newFrame.size.height/2 ;
    self.frame = newFrame;
}

#pragma mark - methods
- (UIViewController *)zy_viewController
{
    id next =[self nextResponder];
    while (next != nil) {
        if ([next isKindOfClass:[UIViewController class]]) {
            return next;
        }
        next = [next nextResponder];
    }
    return nil;
}

- (void)zy_setCornerWithType:(ZYCorner)cornerType cornerRadius:(CGFloat)radius
{
    UIBezierPath *maskPath;
    switch (cornerType) {
        case ZYCornerTop:
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                             byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                   cornerRadii:CGSizeMake(radius, radius)];
        }
            break;
        case ZYCornerLeft:
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                             byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                                   cornerRadii:CGSizeMake(radius, radius)];
        }
            break;
        case ZYCornerBottom:
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                             byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                   cornerRadii:CGSizeMake(radius, radius)];
        }
            break;
        case ZYCornerRight:
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                             byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                                   cornerRadii:CGSizeMake(radius, radius)];

        }
            break;
        case ZYCornerAll:
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
        }
            break;

        default:
            break;
    }
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)zy_setBorders:(ZYBorder)Borders color:(UIColor *)color width:(CGFloat)width
{
    if((Borders & ZYBorderLeft) == ZYBorderLeft)
    {
        [self zy_showBorderViewWithKey:zy_leftBorderKey frame:CGRectMake(0, 0, width, self.frame.size.height) color:color];
    }
    if((Borders & ZYBorderRight) == ZYBorderRight)
    {
        [self zy_showBorderViewWithKey:zy_rightBorderKey frame:CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height) color:color];
    }
    if((Borders & ZYBorderTop) == ZYBorderTop)
    {
        [self zy_showBorderViewWithKey:zy_topBorderKey frame:CGRectMake(0, 0, self.frame.size.width, width) color:color];
    }
    if((Borders & ZYBorderBottom) == ZYBorderBottom)
    {
        [self zy_showBorderViewWithKey:zy_bottomBorderKey frame:CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width) color:color];
    }
}

#pragma mark - pravite methods
- (void)zy_showBorderViewWithKey:(const void *)key frame:(CGRect)frame color:(UIColor *)color
{
    UIView *border = objc_getAssociatedObject(self, key);
    if (border) {
        border.frame = frame;
        border.backgroundColor = color;
        border.hidden = NO;
    }else{
        UIView *newBorder = [[UIView alloc] initWithFrame:frame];
        newBorder.backgroundColor = color;
        [self addSubview:newBorder];
        objc_setAssociatedObject(self, key, newBorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


@end
