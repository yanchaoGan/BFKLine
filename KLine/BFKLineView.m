//
//  BFKLineView.m
//  BitFinance
//
//  Created by ganyanchao on 23/03/2018.
//  Copyright © 2018 GrayLocus. All rights reserved.
//

#import "BFKLineView.h"
#import "BFKLineMaskTipView.h"

@interface BFKLineView () {
    
    CGFloat _xLen;
    CGFloat _yLen;
    CGContextRef _ctx;
}

@property (nonatomic, assign) NSInteger lines;
//<nsnumber * : NSArray *>
@property (nonatomic, strong) NSMutableDictionary *lineDatas;

/**< Y轴*/
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

/**< X轴, 使用最大的来 等分*/
@property (nonatomic, assign) CGFloat maxXCount;

//touch toast
@property(nonatomic, strong) BFKLineMaskTipView *toastView;

@end

@implementation BFKLineView

//+ (Class)layerClass {
//    return [CAShapeLayer class];
//}

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self configInit];
    }
    return self;
}

- (void)configInit {
    self.lines = 1;
    [self defaultConfig];
    
    self.lineDatas = [NSMutableDictionary dictionary];
    self.backgroundColor = [UIColor whiteColor];
    
//    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//    [self addSubview:_scrollView];
//    _scrollView.contentSize = self.bounds.size;
    
    self.toastView.frame = self.bounds;
    [self addSubview:self.toastView];
}

- (void)drawRect:(CGRect)rect {
    if ([self shouldRedraw] == NO) {
        return;
    }
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    _xLen = width - _defaultConfig.edge.left - _defaultConfig.edge.right;
    _yLen = height - _defaultConfig.edge.bottom - _defaultConfig.edge.top;
    _ctx = UIGraphicsGetCurrentContext();
    
    //X
    [self drawX];
    //Y
    [self drawY];
    
    //Content
    for (int i = 0 ; i < self.lines ; i++) {
        [self drawLine:i];
    }
}

#pragma mark - Public
- (void)reloadData {
    [self resetData];
    if ([self.dataSource respondsToSelector:@selector(numberOfLinesInKLineView:)]) {
        self.lines = [self.dataSource numberOfLinesInKLineView:self];
    }
    for (int i = 0; i < self.lines; i++) {
        if ([self.dataSource respondsToSelector:@selector(dataArrayOfKLineView:inLine:)]) {
            NSArray *datas = [self.dataSource dataArrayOfKLineView:self inLine:i];
            if ([NSArray isEmpty:datas] == NO) {
                self.lineDatas[@(i)] = datas;
                
                self.maxXCount = MAX(self.maxXCount, datas.count);
                for (id<BFKLineNodeInfoProtocol> node in datas) {
                    self.minY = MIN(self.minY, node.y);
                    self.maxY = MAX(self.maxY, node.y);
                }
            }
        }
    }
    [self setNeedsDisplay];
}

#pragma mark - Draw
- (void)drawX {
    CGContextSetLineWidth(_ctx, _defaultConfig.xlineWidth);
    CGContextSetStrokeColorWithColor(_ctx, RGBCOLOR(241, 241, 241).CGColor);
    CGContextMoveToPoint(_ctx, _defaultConfig.edge.left, _yLen + _defaultConfig.edge.top);
    CGContextAddLineToPoint(_ctx,_xLen+_defaultConfig.edge.left ,_yLen + _defaultConfig.edge.top);
    CGContextStrokePath(_ctx);
    
    //底部时间轴
    NSArray *datas = self.lineDatas[@(0)];
    id<BFKLineNodeInfoProtocol> node;
    for (int i = 0; i < datas.count; i++) {
        node = datas[i];
        CGPoint nodePoint = [self pointOfNodeInfo:node atIndex:i];
        if (i % 3 == 0) {
            NSString *xTime = [self xTimeOfNodeInfo:node];
            NSDictionary *att = @{NSFontAttributeName:FONT(12),
                                  NSForegroundColorAttributeName:RGBCOLOR(153, 153, 153)
                                  };
            CGSize size = [xTime sizeWithAttributes:att];
            
            CGFloat y = CGRectGetHeight(self.bounds) - _defaultConfig.edge.bottom + 5;
            [xTime drawInRect:CGRectMake(nodePoint.x - size.width/2.0, y, size.width, size.height) withAttributes:att];
        }
    }
}

- (void)drawY {
    CGContextSetLineWidth(_ctx, _defaultConfig.ylineWidth);
    //3条横线 top - bottom
    CGFloat yNodeDis = _yLen / MAX((_defaultConfig.horizontalLines -1),1);
    CGFloat x = _defaultConfig.edge.left;
    CGFloat y = 0;
    
    CGSize maxSize;
    CGFloat expand = 5.f;
    CGFloat yvalueDif = (_maxY - _minY)/MAX((_defaultConfig.horizontalLines -1),1);
    for (int i = 0; i < _defaultConfig.horizontalLines; i++) {
        y = _defaultConfig.edge.top + i * yNodeDis;
        if (i != _defaultConfig.horizontalLines -1) {
            CGContextMoveToPoint(_ctx, x, y);
            CGContextAddLineToPoint(_ctx, x + _xLen, y);
        }
        
        //从大到小绘制
        CGFloat font = 12;
        
        CGFloat yvalue = _maxY - i * yvalueDif;
        NSString *price = @"￥";
        NSString *yTemp = [NSString stringWithFormat:@"%.2f",yvalue];
        NSString *yTip = [NSString stringWithFormat:@"%@%@",price,yTemp];
        NSDictionary *attr = @{
                               NSFontAttributeName:FONT(font),
                               NSForegroundColorAttributeName:RGBCOLOR(153, 153, 153),
                               };
        
        maxSize = [yTip sizeWithAttributes:attr];
        CGFloat adjustWidth = _defaultConfig.edge.left - expand;
        if (maxSize.width > adjustWidth) {
            font = [self fontFitWidth:adjustWidth withText:yTip byDefault:font-0.5];
            attr = @{
                     NSFontAttributeName:FONT(font),
                     NSForegroundColorAttributeName:RGBCOLOR(153, 153, 153),
                     };
            maxSize = [yTip sizeWithAttributes:attr];
        }
        
        CGFloat y_x = MAX(x - maxSize.width - expand, 0);
        CGFloat y_y = MAX(y - maxSize.height/2, 0);
        [yTip drawInRect:CGRectMake(y_x, y_y, maxSize.width + expand, maxSize.height) withAttributes:attr];
    }
    CGContextSetStrokeColorWithColor(_ctx, RGBCOLOR(241, 241, 241).CGColor);
    CGContextStrokePath(_ctx);
}

- (void)drawLine:(NSInteger)L {
    NSArray *datas = self.lineDatas[@(L)];
    CGContextSetLineWidth(_ctx, _defaultConfig.contentlineWidth);
    CGContextSetStrokeColorWithColor(_ctx, RGBCOLOR(52, 153, 218).CGColor);
    
    __block CGFloat x, y;
    __block CGPoint lastNode, firstNode;
    
    CGMutablePathRef path;
    
    void (^drawLine)(void) = ^{
        id<BFKLineNodeInfoProtocol> node;
        for (int i = 0; i < datas.count; i++) {
            node = datas[i];
            CGPoint nodePoint = [self pointOfNodeInfo:node atIndex:i];
            x = nodePoint.x;
            y = nodePoint.y;
            if (i == 0) {
                CGContextMoveToPoint(_ctx, x, y);
                firstNode = CGPointMake(x, y);
            } else {
                CGContextAddLineToPoint(_ctx, x, y);
                lastNode = CGPointMake(x, y);
            }
        }
    };
    
    if (_defaultConfig.lineCurve == NO) {
        drawLine();
        CGContextStrokePath(_ctx);
        
    } else {
        path = [self drawCubicBezier:datas];
        CGContextBeginPath(_ctx);
        CGContextAddPath(_ctx, path);
        CGContextStrokePath(_ctx);
    }
    
    //背景色
    if (self.maxXCount <= 1 || self.lines >= 2) {
        return;
    }
    CGContextSetFillColorWithColor(_ctx, RGBACOLOR(202, 238, 255, 0.5).CGColor);
    CGContextSetBlendMode(_ctx, kCGBlendModeMultiply);
    if (_defaultConfig.lineCurve == NO) {
        drawLine();
        CGContextAddLineToPoint(_ctx,lastNode.x ,_yLen + _defaultConfig.edge.top);
        CGContextAddLineToPoint(_ctx,firstNode.x,_yLen + _defaultConfig.edge.top);
    } else {
        path = [self drawCubicBezier:datas];
        NSInteger lastIndex = datas.count - 1;
        NSInteger firstIndex = 0;

        CGPoint lastNode = [self pointOfNodeInfo:[datas safeObjectAtIndex:lastIndex] atIndex:lastIndex];
        CGPoint firstNode = [self pointOfNodeInfo:[datas safeObjectAtIndex:firstIndex] atIndex:firstIndex];
        
        CGPathAddLineToPoint(path, nil, lastNode.x ,_yLen + _defaultConfig.edge.top);
        CGPathAddLineToPoint(path, nil, firstNode.x,_yLen + _defaultConfig.edge.top);
        
        CGContextBeginPath(_ctx);
        CGContextAddPath(_ctx, path);
    }
    CGContextClosePath(_ctx);
    CGContextFillPath(_ctx);
}

#pragma mark Gesture
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showTouchView:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showTouchView:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideTouchView];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideTouchView];
}

- (void)showTouchView:(NSSet<UITouch *> *)touches {
    if ([self shouldToast] == NO) {
        return;
    }
    CGPoint location = [touches.anyObject locationInView:self];
    if (location.x < _defaultConfig.edge.left || location.x > _xLen + _defaultConfig.edge.left) return;
    //get touch start node
    CGFloat startX = location.x - _defaultConfig.edge.left;
    CGFloat xNodeDis = _xLen / MAX((_maxXCount -1),1);
    CGFloat totalPiece = startX / xNodeDis;
    NSInteger index = 0;
    if (totalPiece - floor(totalPiece) <  0.5) {
        index = floor(totalPiece);
    } else {
        index = ceil(totalPiece);
    }
    id<BFKLineNodeInfoProtocol> node = [self nodeInfoAtIndex:index inLine:0];
    CGPoint nodePoint = [self pointOfNodeInfo:node atIndex:index];
    
    CGFloat x = index * xNodeDis;
    CGFloat toastContentWidth = 172.f;
    CGFloat toastContentHeight = 60.0f;
    CGFloat expand = 20.f;
    CGFloat contentExpand = toastContentWidth + expand;
    if (_xLen - x > contentExpand) {
        x += expand;
    }
    else {
        x -= contentExpand;
    }
    x += _defaultConfig.edge.left;
    x = MAX(x, expand);
    x = MIN(x, _defaultConfig.edge.left + _xLen);
    
    CGFloat y = nodePoint.y;
    CGFloat toY = y + toastContentHeight;
    CGFloat limitY = _yLen + _defaultConfig.edge.top;
    if (toY > limitY) {
        y -= (toY - limitY + expand);
    }
    y = MAX(y, _defaultConfig.edge.top);
    y = MIN(y, limitY - toastContentHeight - expand);
    
    self.toastView.VLineSep.frame = CGRectMake(nodePoint.x, _defaultConfig.edge.top, 1, _yLen);
    self.toastView.contentView.frame = CGRectMake(x, y, toastContentWidth, toastContentHeight);
    [self.toastView showWithTime:node.x price:node.y];
}

- (void)hideTouchView {
    [self.toastView dismiss];
}

#pragma mark - Helper
- (void)resetData {
    self.lines = 1;
    [self.lineDatas removeAllObjects];
    self.maxXCount = 0;
    self.minY = CGFLOAT_MAX;
    self.maxY = CGFLOAT_MIN;
}


- (CGMutablePathRef)drawCubicBezier:(NSArray *)datas {
    
    if ([NSArray isEmpty:datas] == YES) {
        return nil;
    }
    if ( _maxXCount < 1 ) {
        return nil;
    }
    
    CGFloat phaseY = 1.0f;
    CGFloat intensity = 0.02f; //越小越好
    
    CGMutablePathRef cubicPath = CGPathCreateMutable();
    
    CGFloat prevDx = 0.0;
    CGFloat prevDy = 0.0;
    CGFloat curDx = 0.0;
    CGFloat curDy = 0.0;
    
    // Take an extra point from the left, and an extra from the right.
    // That's because we need 4 points for a cubic bezier (cubic=4), otherwise we get lines moving and doing weird stuff on the edges of the chart.
    // So in the starting `prev` and `cur`, go -2, -1
    // And in the `lastIndex`, add +1
    
    NSInteger firstIndex = 0 + 1;
    NSInteger lastIndex = 0 + _maxXCount -1;
    
    id<BFKLineNodeInfoProtocol> prevPrev = nil;
    
    id<BFKLineNodeInfoProtocol> prev = [datas safeObjectAtIndex:MAX(firstIndex - 2, 0)];
    id<BFKLineNodeInfoProtocol> cur = [datas safeObjectAtIndex:MAX(firstIndex - 2, 0)];
    id<BFKLineNodeInfoProtocol> next = cur;
    
    NSInteger nextIndex = -1;
    
    if( cur == nil) {
        return nil;
    }
    
    CGPoint nodePoint = [self pointOfNodeInfo:cur atIndex:0];
    // let the spline start
    CGPathMoveToPoint(cubicPath, nil,nodePoint.x, nodePoint.y);
    
    for (int j = firstIndex; j < _maxXCount; j++) {
        prevPrev = prev;
        prev = cur;
        cur = nextIndex == j ? next : [datas safeObjectAtIndex:j];
        
        nextIndex = j + 1 < datas.count ? j + 1 : j;
        next = [datas safeObjectAtIndex:nextIndex];
        
        if (next == nil) {
            break;
        }
        
        CGPoint curNodePoint = [self pointOfNodeInfo:cur atIndex:j];
        CGPoint prevPrevNodePoint = [self pointOfNodeInfo:prevPrev atIndex:MAX(j-2, 0)];
        CGPoint prevNodePoint = [self pointOfNodeInfo:prev atIndex:MAX(j-1, 0)];
        CGPoint nextNodePoint = [self pointOfNodeInfo:next atIndex:MAX(j+1, datas.count)];
        
        prevDx = (curNodePoint.x - prevPrevNodePoint.x) * intensity;
        prevDy = (curNodePoint.y - prevPrevNodePoint.y) * intensity;
        curDx = (nextNodePoint.x - prevNodePoint.x) * intensity;
        curDy = (nextNodePoint.y - prevNodePoint.y) * intensity;
        
        CGPathAddCurveToPoint(cubicPath,nil,
                              prevNodePoint.x + prevDx, (prevNodePoint.y + prevDy) * phaseY,
                                curNodePoint.x - curDx, (curNodePoint.y - curDy) * phaseY,
                            curNodePoint.x, curNodePoint.y * phaseY);
        
    }
    return cubicPath;
}

#pragma mark - OverWrite
- (BOOL)shouldRedraw {
    if (self.lines >= 1 && self.lineDatas.count >= 1) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldToast {
    if (self.maxXCount <= 1 || self.lines >= 2) {
        return NO;
    }
    return YES;
}

- (id<BFKLineNodeInfoProtocol>)nodeInfoAtIndex:(NSInteger)index inLine:(NSInteger)L {
    NSArray *datas = self.lineDatas[@(L)];
    id<BFKLineNodeInfoProtocol> node = [datas safeObjectAtIndex:index];
    return node;
}

- (CGPoint)pointOfNodeInfo:(id<BFKLineNodeInfoProtocol>)nodeInfo atIndex:(NSInteger)i {
    __block CGFloat x = 0;
    __block CGFloat y = 0;
    CGFloat xNodeDis = _xLen / MAX((_maxXCount -1),1);
    CGFloat yDiff = _maxY - _minY;
    id<BFKLineNodeInfoProtocol> node = nodeInfo;
    x = i * xNodeDis + _defaultConfig.edge.left;
    CGFloat curYDif = node.y - _minY;
    CGFloat curPer = curYDif/yDiff;
    y = _yLen * (1 - curPer) + _defaultConfig.edge.top;
    return CGPointMake(x, y);
}

- (NSString *)xTimeOfNodeInfo:(id<BFKLineNodeInfoProtocol>)nodeInfo {
    NSString *xTime = nil;
    if (nodeInfo.x.length > 16) {
        xTime = [nodeInfo.x substringWithRange:NSMakeRange(11, 5)];
    } else {
        xTime = nodeInfo.x;
    }
    return xTime;
}

- (CGFloat)fontFitWidth:(CGFloat)w  withText:(NSString *)text byDefault:(CGFloat)font{
    CGFloat cf = font;
    CGSize size =  [text sizeWithAttributes:@{NSFontAttributeName:FONT(cf)}];
    while (size.width > w) {
        cf -= 0.5;
        size =  [text sizeWithAttributes:@{NSFontAttributeName:FONT(cf)}];
    }
    return cf;
}

#pragma mark - Getter Setter
- (BFKLineMaskTipView *)toastView {
    if (!_toastView) {
        _toastView = [BFKLineMaskTipView instance];
        _toastView.VLineSep.backgroundColor = RGBCOLOR(204, 204, 204);
        [_toastView dismiss];
    }
    return _toastView;
}

- (BFKLineConfig *)defaultConfig {
    if (!_defaultConfig) {
        _defaultConfig = [[BFKLineConfig alloc] init];
        _defaultConfig.lineCurve = YES;
    }
    return _defaultConfig;
}


@end
