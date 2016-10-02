//
//  ZYTagInfo.h
//  ImageTag
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 比例 */
struct ZYPositionProportion {
    CGFloat x;
    CGFloat y;
};
typedef struct ZYPositionProportion ZYPositionProportion;

ZYPositionProportion ZYPositionProportionMake(CGFloat x, CGFloat y);

@interface ZYTagInfo : NSObject

/** 记录位置点 */
@property (nonatomic, assign) CGPoint point;
/** 记录位置点在父视图中的比例 */
@property (nonatomic, assign) ZYPositionProportion proportion;
/** 标题 */
@property (nonatomic, copy) NSString *title;

/** 初始化 */
+ (ZYTagInfo *)tagInfo;

@end
