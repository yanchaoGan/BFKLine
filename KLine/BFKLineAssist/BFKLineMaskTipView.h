//
//  BFKLineMaskTipView.h
//  BitFinance
//
//  Created by ganyanchao on 26/03/2018.
//  Copyright © 2018 com.afander.finance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFKLineMaskTipView : UIView

+ (instancetype)instance;

@property (weak, nonatomic) IBOutlet UIView *VLineSep;
@property (weak, nonatomic) IBOutlet UIView *contentView;

- (void)showWithTime:(NSString *)time price:(CGFloat)price;
- (void)dismiss;

@end
