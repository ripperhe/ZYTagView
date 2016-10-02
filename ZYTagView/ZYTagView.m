//
//  ZYTagView.m
//  ImageTag
//
//  Created by ripper on 2016/9/27.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ZYTagView.h"
#import "UIView+zy_Frame.h"

#define kXSpace 8.0
#define kYSpace 0.0
#define kTagHorizontalSpace 20.0
#define kTagVerticalSpace 10.0
#define kPointWidth 8.0
#define kPointSpace 2.0
#define kAngleLength (self.zy_height / 2.0 - 2)
#define kCloseBtnWidth self.zy_height

typedef NS_ENUM(NSUInteger, ZYTagViewState) {
    ZYTagViewStateArrowLeft,
    ZYTagViewStateArrowRight,
    ZYTagViewStateArrowLeftWithClose,
    ZYTagViewStateArrowRightWithClose,
};

@interface ZYTagView ()

@property (nonatomic, assign) ZYTagViewState state;
@property (nonatomic, weak) CAShapeLayer *backLayer;
@property (nonatomic, weak) CAShapeLayer *pointLayer;
@property (nonatomic, weak) CAShapeLayer *pointShadowLayer;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, weak) UIView *cuttingLine;

@property (nonatomic, strong) ZYTagInfo *tagInfo;
@property (nonatomic, assign) CGPoint panTmpPoint;

@end


@implementation ZYTagView

- (instancetype)initWithTagInfo:(ZYTagInfo *)tagInfo
{
    self = [super init];
    if (self) {
        
        self.tagInfo = tagInfo;
        //子控件
        [self createSubviews];
        //手势处理
        [self setupGesture];
    }
    return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    //调整UI
    [self layoutWithTitle:self.tagInfo.title superview:newSuperview];
}


#pragma mark - private methods
- (void)createSubviews
{
    CAShapeLayer *backLayer = [[CAShapeLayer alloc] init];
    backLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:.7].CGColor;
    [self.layer addSublayer:backLayer];
    self.backLayer = backLayer;
    
    CAShapeLayer *pointShadowLayer = [[CAShapeLayer alloc] init];
    pointShadowLayer.hidden = YES;
    pointShadowLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;;
    [self.layer addSublayer:pointShadowLayer];
    self.pointShadowLayer = pointShadowLayer;

    CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
    pointLayer.backgroundColor =[UIColor whiteColor].CGColor;
    [self.layer addSublayer:pointLayer];
    self.pointLayer = pointLayer;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"discover_tag_close"] forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    UIView *cuttingLine = [[UIView alloc] init];
    cuttingLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    [self addSubview:cuttingLine];
    self.cuttingLine = cuttingLine;
}

- (void)setupGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:pan];
    UILongPressGestureRecognizer *lop = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:lop];
}

- (void)layoutWithTitle:(NSString *)title superview:(UIView *)superview
{
    //调整label的大小
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    
    //调整子控件UI
    ZYTagViewState state = self.state;
    if (!CGPointEqualToPoint(self.tagInfo.point, CGPointZero)) {
        //如果有point则利用point
        if (self.tagInfo.point.x < superview.zy_width / 2.0) {
            state = ZYTagViewStateArrowLeft;
        }else{
            state = ZYTagViewStateArrowRight;
        }
        [self layoutSubviewsWithState:state arrowPoint:self.tagInfo.point];
    }else{
        //没有point利用位置比例
        CGFloat x = superview.zy_width * self.tagInfo.proportion.x;
        CGFloat y = superview.zy_height * self.tagInfo.proportion.y;
        if (self.tagInfo.proportion.x < 0.5) {
            state = ZYTagViewStateArrowLeft;
        }else{
            state = ZYTagViewStateArrowRight;
        }
        [self layoutSubviewsWithState:state arrowPoint:CGPointMake(x, y)];
    }
    
    //处理特殊初始点情况
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
    
    //更新tag信息
    [self updateLocationInfoWithSuperview:superview];
}

- (void)layoutSubviewsWithState:(ZYTagViewState)state arrowPoint:(CGPoint)arrowPoint
{
    self.state = state;

    //利用事务关闭隐式动画
    [CATransaction setDisableActions:YES];

    CGFloat titleContentWidth = self.titleLabel.zy_width + kTagHorizontalSpace;
    UIBezierPath *backPath = [UIBezierPath bezierPath];
    self.pointLayer.bounds = CGRectMake(0, 0, kPointWidth, kPointWidth);
    self.pointLayer.cornerRadius = kPointWidth / 2.0;

    
    if (state == ZYTagViewStateArrowLeft || state == ZYTagViewStateArrowRight) {
        self.zy_height = self.titleLabel.zy_height + kTagVerticalSpace;
        self.zy_width = titleContentWidth + kAngleLength + kPointWidth + kPointSpace;
        self.zy_centerY = arrowPoint.y;
        //隐藏关闭及分割线
        self.closeBtn.hidden = YES;
        self.cuttingLine.hidden = YES;
    }else{
        //有关闭按钮
        self.zy_height = self.titleLabel.zy_height + kTagVerticalSpace;
        self.zy_width = titleContentWidth + kAngleLength + kPointWidth + kPointSpace +kCloseBtnWidth;
        self.zy_centerY = arrowPoint.y;
        //关闭按钮
        self.closeBtn.hidden = NO;
        self.cuttingLine.hidden = NO;
    }

    if (state == ZYTagViewStateArrowLeft || state == ZYTagViewStateArrowLeftWithClose) {
        //根据字调整控件大小
        self.zy_x = arrowPoint.x - kPointWidth / 2.0;
        //背景
        [backPath moveToPoint:CGPointMake(kPointWidth + kPointSpace, self.zy_height / 2.0)];
        [backPath addLineToPoint:CGPointMake(kPointWidth + kPointSpace + kAngleLength, 0)];
        [backPath addLineToPoint:CGPointMake(self.zy_width, 0)];
        [backPath addLineToPoint:CGPointMake(self.zy_width, self.zy_height)];
        [backPath addLineToPoint:CGPointMake(kPointWidth + kPointSpace + kAngleLength, self.zy_height)];
        [backPath closePath];
        //点
        self.pointLayer.position = CGPointMake(kPointWidth / 2.0, self.zy_height / 2.0);
        //标签
        self.titleLabel.center = CGPointMake(kAngleLength + kPointWidth + kPointSpace + titleContentWidth / 2.0, self.zy_height / 2.0);

        if (state == ZYTagViewStateArrowLeftWithClose) {
            //关闭
            self.closeBtn.frame = CGRectMake(self.zy_width - kCloseBtnWidth, 0, kCloseBtnWidth, kCloseBtnWidth);
            self.cuttingLine.frame = CGRectMake(self.closeBtn.zy_x - 0.5, 0, 0.5, self.zy_height);
        }
        
    }else if(state == ZYTagViewStateArrowRight || state == ZYTagViewStateArrowRightWithClose) {
        //根据字调整控件大小
        self.zy_right = arrowPoint.x + kPointWidth / 2.0;
        //背景
        [backPath moveToPoint:CGPointMake(self.zy_width - kPointWidth - kPointSpace, self.zy_height / 2.0)];
        [backPath addLineToPoint:CGPointMake(self.zy_width - kAngleLength - kPointWidth - kPointSpace, self.zy_height)];
        [backPath addLineToPoint:CGPointMake(0, self.zy_height)];
        [backPath addLineToPoint:CGPointMake(0, 0)];
        [backPath addLineToPoint:CGPointMake(self.zy_width - kAngleLength - kPointWidth - kPointSpace, 0)];
        [backPath closePath];
        //点
        self.pointLayer.position = CGPointMake(self.zy_width - kPointWidth / 2.0, self.zy_height / 2.0);

        if (state == ZYTagViewStateArrowRight) {
            //标签
            self.titleLabel.center = CGPointMake(titleContentWidth / 2.0, self.zy_height / 2.0);
        }else{
            //标签
            self.titleLabel.center = CGPointMake(kCloseBtnWidth + titleContentWidth / 2.0, self.zy_height / 2.0);
            //关闭
            self.closeBtn.frame = CGRectMake(0, 0, kCloseBtnWidth, kCloseBtnWidth);
            self.cuttingLine.frame = CGRectMake(self.closeBtn.zy_right + 0.5, 0, 0.5, self.zy_height);
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
    
    if (self.state == ZYTagViewStateArrowLeft) {
        CGFloat referenceX = point.x;
        if (referenceX < kXSpace) {
            self.zy_x = kXSpace;
        }else if (referenceX > self.superview.zy_width - kXSpace - self.zy_width - kCloseBtnWidth){
            
            if (referenceX < self.superview.zy_width - kXSpace - kPointWidth) {
                self.zy_x = referenceX;
            }else{
                self.zy_x = self.superview.zy_width - kXSpace - kPointWidth;
            }
            //翻转
            if (gestureState == UIGestureRecognizerStateEnded) {
                [self layoutSubviewsWithState:ZYTagViewStateArrowRight arrowPoint:CGPointMake(self.zy_x + kPointWidth/2.0, self.zy_centerY)];
            }
        }else{
            self.zy_x = referenceX;
        }
        
    }else{
        CGFloat referenceX = point.x;

        if (referenceX < kXSpace + kCloseBtnWidth) {
            if (referenceX < kXSpace + kPointWidth - self.zy_width) {
                self.zy_x = kXSpace + kPointWidth - self.zy_width;
            }else{
                self.zy_x = referenceX;
            }
            //翻转
            if (gestureState == UIGestureRecognizerStateEnded) {
                [self layoutSubviewsWithState:ZYTagViewStateArrowLeft arrowPoint:CGPointMake(self.zy_right - kPointWidth/2.0, self.zy_centerY)];
            }
            
        }else if (referenceX > self.superview.zy_width - kXSpace - self.zy_width) {
            self.zy_x = self.superview.zy_width - kXSpace - self.zy_width;
        }else{
            self.zy_x = referenceX;
        }
    }
    
    CGFloat referenceY = point.y;
    if (referenceY < kYSpace) {
        self.zy_y = kYSpace;
    }else if (referenceY > (self.superview.zy_height - kYSpace - self.zy_height)){
        self.zy_y = self.superview.zy_height - kYSpace - self.zy_height;
    }else{
        self.zy_y = referenceY;
    }

    //更新tag信息
    if (gestureState == UIGestureRecognizerStateEnded) {
        [self updateLocationInfoWithSuperview:self.superview];
    }
}

- (void)updateLocationInfoWithSuperview:(UIView *)superview
{
    if (superview == nil) {
        //被移除的时候也会调用 willMoveToSuperview
        return;
    }
    //更新point
    if (self.state == ZYTagViewStateArrowLeft || self.state == ZYTagViewStateArrowLeftWithClose) {
        self.tagInfo.point = CGPointMake(self.zy_x + kPointWidth / 2, self.zy_y + self.zy_height / 2.0);
    }else{
        self.tagInfo.point = CGPointMake(self.zy_right - kPointWidth / 2, self.zy_y + self.zy_height / 2.0);
    }
    //更新proportion
    if (superview.zy_width > 0 && superview.zy_height > 0) {
        self.tagInfo.proportion = ZYPositionProportionMake(self.tagInfo.point.x / superview.zy_width, self.tagInfo.point.y / superview.zy_height);
    }
}


#pragma mark - event response
- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.state == ZYTagViewStateArrowLeft) {
            CGPoint arrowPoint = CGPointMake(self.zy_x + kPointWidth / 2.0, self.zy_centerY);
            [self layoutSubviewsWithState:ZYTagViewStateArrowLeftWithClose arrowPoint:arrowPoint];
        }else if (self.state == ZYTagViewStateArrowRight) {
            CGPoint arrowPoint = CGPointMake(self.zy_right - kPointWidth / 2.0, self.zy_centerY);
            [self layoutSubviewsWithState:ZYTagViewStateArrowRightWithClose arrowPoint:arrowPoint];
        }else if (self.state == ZYTagViewStateArrowLeftWithClose) {
            CGPoint arrowPoint = CGPointMake(self.zy_x + kPointWidth / 2.0, self.zy_centerY);
            [self layoutSubviewsWithState:ZYTagViewStateArrowLeft arrowPoint:arrowPoint];
        }else if(self.state == ZYTagViewStateArrowRightWithClose) {
            CGPoint arrowPoint = CGPointMake(self.zy_right - kPointWidth / 2.0, self.zy_centerY);
            [self layoutSubviewsWithState:ZYTagViewStateArrowRight arrowPoint:arrowPoint];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    CGPoint panPoint = [pan locationInView:self.superview];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            //除去关闭按钮
            if (self.state == ZYTagViewStateArrowLeftWithClose) {
                CGPoint arrowPoint = CGPointMake(self.zy_x + kPointWidth / 2.0, self.zy_centerY);
                [self layoutSubviewsWithState:ZYTagViewStateArrowLeft arrowPoint:arrowPoint];
            }else if(self.state == ZYTagViewStateArrowRightWithClose) {
                CGPoint arrowPoint = CGPointMake(self.zy_right - kPointWidth / 2.0, self.zy_centerY);
                [self layoutSubviewsWithState:ZYTagViewStateArrowRight arrowPoint:arrowPoint];
            }
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

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)lop
{
    if (lop.state == UIGestureRecognizerStateBegan) {
        if (self.state == ZYTagViewStateArrowLeft) {
            CGPoint arrowPoint = CGPointMake(self.zy_x + kPointWidth / 2.0, self.zy_centerY);
            [self layoutSubviewsWithState:ZYTagViewStateArrowLeftWithClose arrowPoint:arrowPoint];
        }else if (self.state == ZYTagViewStateArrowRight) {
            CGPoint arrowPoint = CGPointMake(self.zy_right - kPointWidth / 2.0, self.zy_centerY);
            [self layoutSubviewsWithState:ZYTagViewStateArrowRightWithClose arrowPoint:arrowPoint];
        }
    }
}

- (void)clickCloseBtn
{
    [self removeFromSuperview];
}

#pragma mark - public methods
- (void)updateTitle:(NSString *)title
{
    [self layoutWithTitle:title superview:self.superview];
}

- (void)showAnimation
{
    CAKeyframeAnimation *cka = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    cka.values = @[@0.7, @1.32, @1, @1];
    cka.keyTimes = @[@0.0, @0.3, @0.3, @1];
    cka.repeatCount = 2;
    cka.duration = 1.8;
    [self.pointLayer addAnimation:cka forKey:@"cka"];
    
    CAKeyframeAnimation *cka2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    cka2.values = @[@0.7, @0.9, @0.9, @3.5, @0.9, @3.5];
    cka2.keyTimes = @[@0.0, @0.3, @0.3, @0.65, @0.65, @1];
    cka2.repeatCount = 2;
    cka2.duration = 1.8;
    self.pointShadowLayer.hidden = NO;
    [self.pointShadowLayer addAnimation:cka2 forKey:@"cka2"];
}

- (void)closeAnimation
{
    [self.pointLayer removeAnimationForKey:@"cka"];
    [self.pointShadowLayer removeAnimationForKey:@"cka2"];
    self.pointShadowLayer.hidden = YES;
}

@end
