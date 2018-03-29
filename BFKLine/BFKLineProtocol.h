//
//  BFKLineProtocol.h
//  BitFinance
//
//  Created by ganyanchao on 23/03/2018.
//  Copyright © 2018 GrayLocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFKLineView;

/**< 每个节点的信息*/
@protocol BFKLineNodeInfoProtocol <NSObject>

@property (nonatomic, assign) CGFloat y;
@property (nonatomic, copy) NSString *x;

@end


@protocol BFKLineDataSourceProtocol <NSObject>

@required
- (NSArray<id<BFKLineNodeInfoProtocol>> *)dataArrayOfKLineView:(BFKLineView *)lv
                                                        inLine:(NSInteger)lid; //from 0 to rows -1

@optional
- (NSInteger)numberOfLinesInKLineView:(BFKLineView *)lv; // Default is 1 if not implemented

@end


@protocol BFKLineProtocol <NSObject>

- (void)reloadData;

@end
