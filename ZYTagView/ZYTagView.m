//
//  ZYTagView.m
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ZYTagView.h"
#import "UIView+ZYTagView.h"

#define kXSpace 8.0                              /** 距离父视图边界横向最小距离 */
#define kYSpace 0.0                              /** 距离俯视图边界纵向最小距离 */
#define kTagHorizontalSpace 20.0                 /** 标签左右空余距离 */
#define kTagVerticalSpace 10.0                   /** 标签上下空余距离 */
#define kPointWidth 8.0                          /** 白点直径 */
#define kPointSpace 2.0                          /** 白点和阴影尖角距离 */
#define kAngleLength (self.zy_height / 2.0 - 2)  /** 黑色阴影尖交宽度 */
#define kDeleteBtnWidth self.zy_height           /** 删除按钮宽度 */
#define kBackCornerRadius 2.0                    /** 黑色背景圆角半径 */

typedef NS_ENUM(NSUInteger, ZYTagViewState) {
    ZYTagViewStateArrowLeft,
    ZYTagViewStateArrowRight,
    ZYTagViewStateArrowLeftWithDelete,
    ZYTagViewStateArrowRightWithDelete,
};

@interface ZYTagView ()

/** 状态 */
@property (nonatomic, assign) ZYTagViewState state;
/** tag信息 */
@property (nonatomic, strong) ZYTagInfo *tagInfo;
/** 拖动手势记录初始点 */
@property (nonatomic, assign) CGPoint panTmpPoint;
/** 白点中心 */
@property (nonatomic, assign) CGPoint arrowPoint;

/** 黑色背景 */
@property (nonatomic, weak) CAShapeLayer *backLayer;
/** 白点 */
@property (nonatomic, weak) CAShapeLayer *pointLayer;
/** 白点动画阴影 */
@property (nonatomic, weak) CAShapeLayer *pointShadowLayer;
/** 标题 */
@property (nonatomic, weak) UILabel *titleLabel;
/** 删除按钮 */
@property (nonatomic, weak) UIButton *deleteBtn;
/** 分割线 */
@property (nonatomic, weak) UIView *cuttingLine;

@end


@implementation ZYTagView

- (instancetype)initWithTagInfo:(ZYTagInfo *)tagInfo
{
    self = [super init];
    if (self) {
        
        self.tagInfo = tagInfo;
        self.isEditEnabled = YES;
        
        // 子控件
        [self createSubviews];
        // 手势处理
        [self setupGesture];
    }
    return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 调整UI
    [self layoutWithTitle:self.tagInfo.title superview:newSuperview];
}


#pragma mark - getter and setter
- (CGPoint)arrowPoint
{
    CGPoint arrowPoint;
    if (self.state == ZYTagViewStateArrowLeft) {
        arrowPoint = CGPointMake(self.zy_x + kPointWidth / 2.0, self.zy_centerY);
    }else if (self.state == ZYTagViewStateArrowRight) {
        arrowPoint = CGPointMake(self.zy_right - kPointWidth / 2.0, self.zy_centerY);
    }else if (self.state == ZYTagViewStateArrowLeftWithDelete) {
        arrowPoint = CGPointMake(self.zy_x + kPointWidth / 2.0, self.zy_centerY);
    }else if(self.state == ZYTagViewStateArrowRightWithDelete) {
        arrowPoint = CGPointMake(self.zy_right - kPointWidth / 2.0, self.zy_centerY);
    }
    return arrowPoint;
}

- (void)setArrowPoint:(CGPoint)arrowPoint
{
    self.zy_centerY = arrowPoint.y;
    if (self.state == ZYTagViewStateArrowLeft) {
        self.zy_x = arrowPoint.x - kPointWidth / 2.0;
    }else if (self.state == ZYTagViewStateArrowRight) {
        self.zy_right = arrowPoint.x + kPointWidth / 2.0;
    }else if (self.state == ZYTagViewStateArrowLeftWithDelete) {
        self.zy_x = arrowPoint.x - kPointWidth / 2.0;
    }else if(self.state == ZYTagViewStateArrowRightWithDelete) {
        self.zy_right = arrowPoint.x + kPointWidth / 2.0;
    }
}

#pragma mark - private methods
- (void)createSubviews
{
    CAShapeLayer *backLayer = [[CAShapeLayer alloc] init];
    backLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:.7].CGColor;
    backLayer.shadowOffset = CGSizeMake(0, 2);
    backLayer.shadowColor = [UIColor blackColor].CGColor;
    backLayer.shadowRadius = 3;
    backLayer.shadowOpacity = 0.5;
    [self.layer addSublayer:backLayer];
    self.backLayer = backLayer;
    
    CAShapeLayer *pointShadowLayer = [[CAShapeLayer alloc] init];
    pointShadowLayer.hidden = YES;
    pointShadowLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;;
    [self.layer addSublayer:pointShadowLayer];
    self.pointShadowLayer = pointShadowLayer;

    CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
    pointLayer.backgroundColor =[UIColor whiteColor].CGColor;
    pointLayer.shadowOffset = CGSizeMake(0, 1);
    pointLayer.shadowColor = [UIColor blackColor].CGColor;
    pointLayer.shadowRadius = 1.5;
    pointLayer.shadowOpacity = 0.2;
    [self.layer addSublayer:pointLayer];
    self.pointLayer = pointLayer;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn addTarget:self action:@selector(clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
    [self addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    
    UIView *cuttingLine = [[UIView alloc] init];
    cuttingLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    [self addSubview:cuttingLine];
    self.cuttingLine = cuttingLine;
}

- (void)setupGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *lop = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:lop];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:pan];
}

- (void)layoutWithTitle:(NSString *)title superview:(UIView *)superview
{
    // 调整label的大小
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel sizeToFit];
    self.titleLabel.zy_width += kTagHorizontalSpace;
    self.titleLabel.zy_height += kTagVerticalSpace;
    
    // 调整子控件UI
    ZYTagViewState state = self.state;
    CGPoint point = self.tagInfo.point;
    
    if (CGPointEqualToPoint(self.tagInfo.point, CGPointZero)) {
        // 没有point,利用位置比例proportion
        CGFloat x = superview.zy_width * self.tagInfo.proportion.x;
        CGFloat y = superview.zy_height * self.tagInfo.proportion.y;
        point = CGPointMake(x, y);
    }
    
    if (self.tagInfo.direction == ZYTagDirectionNormal) {
        if (point.x < superview.zy_width / 2.0) {
            state = ZYTagViewStateArrowLeft;
        }else{
            state = ZYTagViewStateArrowRight;
        }
    }else{
        if (self.tagInfo.direction == ZYTagDirectionLeft) {
            state = ZYTagViewStateArrowLeft;
        }else{
            state = ZYTagViewStateArrowRight;
        }
    }
    [self layoutSubviewsWithState:state arrowPoint:point];
    
    // 处理特殊初始点情况
    if (state == ZYTagViewStateArrowLeft) {
        if (self.zy_x < kXSpace) {
            self.zy_x = kXSpace;
        }
    }else{
        if (self.zy_x > superview.zy_width - kXSpace - self.zy_width) {
            self.zy_x = superview.zy_width - kXSpace - self.zy_width;
        }
    }
    if (self.zy_y < kYSpace) {
        self.zy_y = kYSpace;
    }else if (self.zy_y > (superview.zy_height - kYSpace - self.zy_height)){
        self.zy_y = superview.zy_height - kYSpace - self.zy_height;
    }
    
    // 更新tag信息
    [self updateLocationInfoWithSuperview:superview];
}

- (void)layoutSubviewsWithState:(ZYTagViewState)state arrowPoint:(CGPoint)arrowPoint
{
    self.state = state;

    // 利用事务关闭隐式动画
    [CATransaction setDisableActions:YES];

    UIBezierPath *backPath = [UIBezierPath bezierPath];
    self.pointLayer.bounds = CGRectMake(0, 0, kPointWidth, kPointWidth);
    self.pointLayer.cornerRadius = kPointWidth / 2.0;
    self.zy_height = self.titleLabel.zy_height;
    self.zy_centerY = arrowPoint.y;
    self.titleLabel.zy_y = 0;

    
    if (state == ZYTagViewStateArrowLeft || state == ZYTagViewStateArrowRight) {
        // 无关闭按钮
        self.zy_width = self.titleLabel.zy_width + kAngleLength + kPointWidth + kPointSpace;
        // 隐藏关闭及分割线
        self.deleteBtn.hidden = YES;
        self.cuttingLine.hidden = YES;
    }else{
        // 有关闭按钮
        self.zy_width = self.titleLabel.zy_width + kAngleLength + kPointWidth + kPointSpace +kDeleteBtnWidth;
        // 关闭按钮
        self.deleteBtn.hidden = NO;
        self.cuttingLine.hidden = NO;
    }

    if (state == ZYTagViewStateArrowLeft || state == ZYTagViewStateArrowLeftWithDelete) {
        // 根据字调整控件大小
        self.zy_x = arrowPoint.x - kPointWidth / 2.0;
        // 背景
        [backPath moveToPoint:CGPointMake(kPointWidth + kPointSpace, self.zy_height / 2.0)];
        [backPath addLineToPoint:CGPointMake(kPointWidth + kPointSpace + kAngleLength, 0)];
        [backPath addLineToPoint:CGPointMake(self.zy_width - kBackCornerRadius, 0)];
        [backPath addArcWithCenter:CGPointMake(self.zy_width - kBackCornerRadius, kBackCornerRadius) radius:kBackCornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
        [backPath addLineToPoint:CGPointMake(self.zy_width, self.zy_height - kBackCornerRadius)];
        [backPath addArcWithCenter:CGPointMake(self.zy_width - kBackCornerRadius, self.zy_height - kBackCornerRadius) radius:kBackCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [backPath addLineToPoint:CGPointMake(kPointWidth + kPointSpace + kAngleLength, self.zy_height)];
        [backPath closePath];
        // 点
        self.pointLayer.position = CGPointMake(kPointWidth / 2.0, self.zy_height / 2.0);
        // 标签
        self.titleLabel.zy_x = kPointWidth + kAngleLength;

        if (state == ZYTagViewStateArrowLeftWithDelete) {
            // 关闭
            self.deleteBtn.frame = CGRectMake(self.zy_width - kDeleteBtnWidth, 0, kDeleteBtnWidth, kDeleteBtnWidth);
            self.cuttingLine.frame = CGRectMake(self.deleteBtn.zy_x - 0.5, 0, 0.5, self.zy_height);
        }
        
    }else if(state == ZYTagViewStateArrowRight || state == ZYTagViewStateArrowRightWithDelete) {
        // 根据字调整控件大小
        self.zy_right = arrowPoint.x + kPointWidth / 2.0;
        // 背景
        [backPath moveToPoint:CGPointMake(self.zy_width - kPointWidth - kPointSpace, self.zy_height / 2.0)];
        [backPath addLineToPoint:CGPointMake(self.zy_width - kAngleLength - kPointWidth - kPointSpace, self.zy_height)];
        [backPath addLineToPoint:CGPointMake(kBackCornerRadius, self.zy_height)];
        [backPath addArcWithCenter:CGPointMake(kBackCornerRadius, self.zy_height - kBackCornerRadius) radius:kBackCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [backPath addLineToPoint:CGPointMake(0, kBackCornerRadius)];
        [backPath addArcWithCenter:CGPointMake(kBackCornerRadius, kBackCornerRadius) radius:kBackCornerRadius startAngle:M_PI endAngle:M_PI + M_PI_2 clockwise:YES];
        [backPath addLineToPoint:CGPointMake(self.zy_width - kAngleLength - kPointWidth - kPointSpace, 0)];
        [backPath closePath];
        // 点
        self.pointLayer.position = CGPointMake(self.zy_width - kPointWidth / 2.0, self.zy_height / 2.0);

        if (state == ZYTagViewStateArrowRight) {
            // 标签
            self.titleLabel.zy_x = 0;
        }else{
            // 标签
            self.titleLabel.zy_x = kDeleteBtnWidth;
            // 关闭
            self.deleteBtn.frame = CGRectMake(0, 0, kDeleteBtnWidth, kDeleteBtnWidth);
            self.cuttingLine.frame = CGRectMake(self.deleteBtn.zy_right + 0.5, 0, 0.5, self.zy_height);
        }
    }
    
    self.backLayer.path = backPath.CGPath;
    self.pointShadowLayer.bounds = self.pointLayer.bounds;
    self.pointShadowLayer.position = self.pointLayer.position;
    self.pointShadowLayer.cornerRadius = self.pointLayer.cornerRadius;

    [CATransaction setDisableActions:NO];
}

- (void)changeLocationWithGestureState:(UIGestureRecognizerState)gestureState locationPoint:(CGPoint)point
{
    if (self.isEditEnabled == NO) {
        return;
    }
    
    CGPoint referencePoint = CGPointMake(0, point.y + self.zy_height / 2.0);
    switch (self.state) {
        case ZYTagViewStateArrowLeft:
        case ZYTagViewStateArrowLeftWithDelete:
            referencePoint.x = point.x + kPointWidth / 2.0;
            break;
        case ZYTagViewStateArrowRight:
        case ZYTagViewStateArrowRightWithDelete:
            referencePoint.x = point.x + self.zy_width - kPointWidth / 2.0;
            break;
        default:
            break;
    }
    
    if (referencePoint.x < kXSpace + kPointWidth / 2.0) {
        referencePoint.x = kXSpace + kPointWidth / 2.0;
    }else if (referencePoint.x > self.superview.zy_width - kXSpace - kPointWidth /2.0){
        referencePoint.x = self.superview.zy_width - kXSpace - kPointWidth /2.0;
    }
    
    if (referencePoint.y < kYSpace + self.zy_height / 2.0 ) {
        referencePoint.y = kYSpace + self.zy_height / 2.0;
    }else if (referencePoint.y > self.superview.zy_height - kYSpace - self.zy_height / 2.0){
        referencePoint.y = self.superview.zy_height - kYSpace - self.zy_height / 2.0;
    }
    // 更新位置
    self.arrowPoint = referencePoint;
    
    if (gestureState == UIGestureRecognizerStateEnded) {
        // 翻转
        switch (self.state) {
            case ZYTagViewStateArrowLeft:
            case ZYTagViewStateArrowLeftWithDelete:
            {
                if (self.zy_right > self.superview.zy_width - kXSpace - kDeleteBtnWidth
                    && self.arrowPoint.x > self.superview.zy_width / 2.0) {
                    [self layoutSubviewsWithState:ZYTagViewStateArrowRight arrowPoint:self.arrowPoint];
                }
            }
                break;
            case ZYTagViewStateArrowRight:
            case ZYTagViewStateArrowRightWithDelete:
                if (self.zy_x < kXSpace + kDeleteBtnWidth
                    && self.arrowPoint.x < self.superview.zy_width / 2.0) {
                    [self layoutSubviewsWithState:ZYTagViewStateArrowLeft arrowPoint:self.arrowPoint];
                }
                break;
            default:
                break;
        }
        // 更新tag信息
        [self updateLocationInfoWithSuperview:self.superview];
    }
}

- (void)updateLocationInfoWithSuperview:(UIView *)superview
{
    if (superview == nil) {
        // 被移除的时候也会调用 willMoveToSuperview
        return;
    }
    // 更新point 以及 direction
    if (self.state == ZYTagViewStateArrowLeft || self.state == ZYTagViewStateArrowLeftWithDelete) {
        self.tagInfo.point = CGPointMake(self.zy_x + kPointWidth / 2, self.zy_y + self.zy_height / 2.0);
        self.tagInfo.direction = ZYTagDirectionLeft;
    }else{
        self.tagInfo.point = CGPointMake(self.zy_right - kPointWidth / 2, self.zy_y + self.zy_height / 2.0);
        self.tagInfo.direction = ZYTagDirectionRight;
    }
    // 更新proportion
    if (superview.zy_width > 0 && superview.zy_height > 0) {
        self.tagInfo.proportion = ZYPositionProportionMake(self.tagInfo.point.x / superview.zy_width, self.tagInfo.point.y / superview.zy_height);
    }
}

#pragma mark - event response
- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.superview bringSubviewToFront:self];
        if ([self.delegate respondsToSelector:@selector(tagViewActiveTapGesture:)]) {
            [self.delegate tagViewActiveTapGesture:self];
        }else{
            // 默认 切换删除按钮状态
            [self switchDeleteState];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)lop
{
    if (lop.state == UIGestureRecognizerStateBegan) {
        [self.superview bringSubviewToFront:self];
        if ([self.delegate respondsToSelector:@selector(tagViewActiveLongPressGesture:)]) {
            [self.delegate tagViewActiveLongPressGesture:self];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    CGPoint panPoint = [pan locationInView:self.superview];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self hiddenDeleteBtn];
            [self.superview bringSubviewToFront:self];
            self.panTmpPoint = [pan locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self changeLocationWithGestureState:UIGestureRecognizerStateChanged
                                      locationPoint:CGPointMake(panPoint.x - self.panTmpPoint.x, panPoint.y - self.panTmpPoint.y)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self changeLocationWithGestureState:UIGestureRecognizerStateEnded
                                      locationPoint:CGPointMake(panPoint.x - self.panTmpPoint.x, panPoint.y - self.panTmpPoint.y)];
            self.panTmpPoint = CGPointZero;
        }
            break;
        default:
            break;
    }
}

- (void)clickDeleteBtn
{
    [self removeFromSuperview];
}

#pragma mark - public methods
- (void)updateTitle:(NSString *)title
{
    self.tagInfo.title = title;
    [self layoutWithTitle:title superview:self.superview];
}

- (void)showAnimationWithRepeatCount:(float)repeatCount
{
    CAKeyframeAnimation *cka = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    cka.values =   @[@0.7, @1.32, @1,   @1];
    cka.keyTimes = @[@0.0, @0.3,  @0.3, @1];
    cka.repeatCount = repeatCount;
    cka.duration = 1.8;
    [self.pointLayer addAnimation:cka forKey:@"cka"];
    
    CAKeyframeAnimation *cka2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    cka2.values =   @[@0.7, @0.9, @0.9, @3.5,  @0.9,  @3.5];
    cka2.keyTimes = @[@0.0, @0.3, @0.3, @0.65, @0.65, @1];
    cka2.repeatCount = repeatCount;
    cka2.duration = 1.8;
    self.pointShadowLayer.hidden = NO;
    [self.pointShadowLayer addAnimation:cka2 forKey:@"cka2"];
}

- (void)removeAnimation
{
    [self.pointLayer removeAnimationForKey:@"cka"];
    [self.pointShadowLayer removeAnimationForKey:@"cka2"];
    self.pointShadowLayer.hidden = YES;
}

- (void)showDeleteBtn
{
    if (self.isEditEnabled == NO) {
        return;
    }
    if (self.state == ZYTagViewStateArrowLeft) {
        [self layoutSubviewsWithState:ZYTagViewStateArrowLeftWithDelete arrowPoint:self.arrowPoint];
    }else if (self.state == ZYTagViewStateArrowRight) {
        [self layoutSubviewsWithState:ZYTagViewStateArrowRightWithDelete arrowPoint:self.arrowPoint];
    }
}

- (void)hiddenDeleteBtn
{
    if (self.state == ZYTagViewStateArrowLeftWithDelete) {
        [self layoutSubviewsWithState:ZYTagViewStateArrowLeft arrowPoint:self.arrowPoint];
    }else if(self.state == ZYTagViewStateArrowRightWithDelete) {
        [self layoutSubviewsWithState:ZYTagViewStateArrowRight arrowPoint:self.arrowPoint];
    }
}

- (void)switchDeleteState
{
    if (self.state == ZYTagViewStateArrowLeft || self.state == ZYTagViewStateArrowRight) {
        [self showDeleteBtn];
    }else {
        [self hiddenDeleteBtn];
    }
}

@end
