//
//  BFKLineMaskTipView.m
//  BitFinance
//
//  Created by ganyanchao on 26/03/2018.
//  Copyright © 2018 com.afander.finance. All rights reserved.
//

#import "BFKLineMaskTipView.h"

@interface BFKLineMaskTipView ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end

@implementation BFKLineMaskTipView

+ (instancetype)instance {
    return  [[[NSBundle mainBundle] loadNibNamed:@"BFKLineMaskTipView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.priceLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)showWithTime:(NSString *)time price:(CGFloat)price {
    self.hidden = NO;
    self.timeLabel.text = time;
    NSString *unit = @"¥";
    self.priceLabel.text = [NSString stringWithFormat:@"%@%.2f",unit,price];
}

- (void)dismiss {
    self.hidden = YES;
}

@end
