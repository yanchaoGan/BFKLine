//
//  BFKLineConfig.h
//  BitFinance
//
//  Created by ganyanchao on 23/03/2018.
//  Copyright © 2018 GrayLocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface BFKLineConfig : NSObject
/*
|
|
|-------
//从左下角
 */
@property (nonatomic, assign) BOOL shouldOptimizeYValue;

//包含x在内的水平轴个数
@property (nonatomic, assign) NSInteger horizontalLines; //4

@property (nonatomic, assign) BOOL  lineCurve; //k线拐点 是否使用曲线连接 default NO
//1
@property (nonatomic, assign) CGFloat ylineWidth;
@property (nonatomic, assign) CGFloat xlineWidth;
@property (nonatomic, assign) CGFloat contentlineWidth;

//2 - 50 - 20 - 10
@property (nonatomic, assign) UIEdgeInsets edge;

@end


#pragma mark - Tool
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define FONT(f) [UIFont systemFontOfSize:(f)]

@interface NSArray (BFTool)

- (id)safeObjectAtIndex:(NSInteger)index;
- (NSInteger)safeIndexOfObject:(id)obj;
+ (BOOL)isEmpty:(NSArray *)array;

@end

