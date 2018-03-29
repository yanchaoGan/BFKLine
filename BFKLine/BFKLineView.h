//
//  BFKLineView.h
//  BitFinance
//
//  Created by ganyanchao on 23/03/2018.
//  Copyright © 2018 GrayLocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFKLineKit.h"

//折线图
@interface BFKLineView : UIScrollView <BFKLineProtocol>

@property(nonatomic, weak) id<BFKLineDataSourceProtocol> dataSource;
@property(nonatomic, strong) BFKLineConfig *defaultConfig;

@end
