//
//  ZYTagInfo.h
//  ImageTag
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//位置在父视图中的比例
struct ZYPositionProportion {
    CGFloat x;
    CGFloat y;
};
typedef struct ZYPositionProportion ZYPositionProportion;

ZYPositionProportion ZYPositionProportionMake(CGFloat x, CGFloat y);

@interface ZYTagInfo : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) ZYPositionProportion proportion;
@property (nonatomic, copy) NSString *title;

+ (ZYTagInfo *)tagInfo;

@end
