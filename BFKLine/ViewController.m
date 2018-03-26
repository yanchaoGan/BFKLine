//
//  ViewController.m
//  BFKLine
//
//  Created by ganyanchao on 26/03/2018.
//  Copyright © 2018 G.Y. All rights reserved.
//

#import "ViewController.h"
#import "BFKLineKit.h"

@interface BFKLineNodeItem : NSObject
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, copy) NSString * x;
@end

@implementation BFKLineNodeItem
@end


@interface ViewController ()
@property (nonatomic, strong) BFKLineView *chartView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.chartView];
    [self.chartView reloadData];
}

- (BFKLineView *)chartView {
    if (!_chartView) {
        _chartView = [[BFKLineView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.4+7)];
        _chartView.dataSource = self;
    }
    return _chartView;
}

#pragma mark -  BFKLineDataSourceProtocol
- (NSArray<id<BFKLineNodeInfoProtocol>> *)dataArrayOfKLineView:(BFKLineView *)lv
                                                        inLine:(NSInteger)lid {
    return [self klineArray];
}

#pragma mark - Helper
- (NSArray *)klineArray {
    
    NSArray *dates = @[@"2018-03-26 01:00:00",
                       @"2018-03-26 02:00:00",
                       @"2018-03-26 03:00:00",
                       @"2018-03-26 04:00:00",
                       @"2018-03-26 05:00:00",
                       @"2018-03-26 06:00:00",
                       @"2018-03-26 07:00:00",
                       @"2018-03-26 08:00:00",
                       @"2018-03-26 09:00:00",
                       @"2018-03-26 10:00:00",
                       @"2018-03-26 11:00:00",
                       @"2018-03-26 12:00:00",
                       @"2018-03-26 13:00:00",
                       @"2018-03-26 14:00:00",
                       @"2018-03-26 15:00:00",
                       @"2018-03-26 16:00:00",
                       @"2018-03-26 17:00:00",
                       @"2018-03-26 18:00:00",
                       @"2018-03-26 19:00:00",
                       @"2018-03-26 20:00:00",
                       @"2018-03-26 21:00:00",
                       @"2018-03-26 22:00:00",
                       @"2018-03-26 23:00:00",
                       @"2018-03-27 00:00:00"];
    
    NSArray *price = @[
                      @"54159.99",
                      @"54584.15",
                      @"54761.42",
                      @"54556.68",
                      @"54527.11",
                      @"54691.78",
                      @"53701.32",
                      @"53801.03",
                      @"53383.2",
                      @"53495.32",
                      @"53685.18",
                      @"53630.16",
                      @"53735.83",
                      @"53589.08",
                      @"53520.58",
                      @"53398.77",
                      @"53127.88",
                      @"52705.3",
                      @"52094.88",
                      @"51785.94",
                      @"51652.99",
                      @"51427.05",
                      @"51415.4",
                      @"51184.58"];
    
    NSMutableArray *models = [@[] mutableCopy];
    for (int i = 0 ; i < dates.count; i++) {
        BFKLineNodeItem *item = [[BFKLineNodeItem alloc] init];
        item.y = [[price safeObjectAtIndex:i] floatValue];
        item.x = [dates safeObjectAtIndex:i];
        [models addObject:item];
    }
    return models;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



