//
//  BFKLineConfig.m
//  BitFinance
//
//  Created by ganyanchao on 23/03/2018.
//  Copyright © 2018 GrayLocus. All rights reserved.
//

#import "BFKLineConfig.h"

@implementation BFKLineConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineCurve = NO;
        _shouldOptimizeYValue = NO;
        _xlineWidth = _ylineWidth = 1;
        _contentlineWidth = 2;
        _horizontalLines = 4;
        _edge = UIEdgeInsetsMake(10, 70, 20, 10);
    }
    return self;
}

@end



@implementation NSArray (BFTool)

- (id)safeObjectAtIndex:(NSInteger)index {
    if (index >= self.count || index < 0) {
        return nil;
    }
    return self[index];
}

- (NSInteger)safeIndexOfObject:(id)obj {
    if (obj == nil) {
        return 0;
    }
    return [self indexOfObject:obj];
}

+ (BOOL)isEmpty:(NSArray *)array {
    return !(array && [array isKindOfClass:[NSArray class]] && array.count && ![array isEqual:[NSNull null]]);
}

@end
