//
//  NeuronsView.m
//  神经元
//
//  Created by WT－WD on 17/7/24.
//  Copyright © 2017年 none. All rights reserved.
//

#import "NeuronsView.h"
#pragma mark - 圆点模型
@interface Cirlemodel : NSObject
@property(nonatomic,assign)CGFloat originX;
@property(nonatomic,assign)CGFloat originY;
@property(nonatomic,assign)CGFloat offsetX;
@property(nonatomic,assign)CGFloat offsetY;
@property(nonatomic,assign)CGFloat width;
-(instancetype)initModelWith:(CGFloat)originX andY:(CGFloat)originY andWidth: (CGFloat)width andOffsetX:(CGFloat)offsetX andoffsetY:(CGFloat)offsetY;
@end
#pragma mark - 线模型
@interface LineModel : NSObject
@property(assign,nonatomic)CGFloat beginX;
@property(assign,nonatomic)CGFloat beginY;
@property(assign,nonatomic)CGFloat opacity;
@property(assign,nonatomic)CGFloat closeX;
@property(assign,nonatomic)CGFloat closeY;
-(instancetype)initModelWith:(CGFloat)beginX andY:(CGFloat)beginY andOpacity:(CGFloat)opacity andCloseX:(CGFloat)closeX andCloseY:(CGFloat)closeY;
@end


#pragma mark - NeuronsView
@interface NeuronsView ()
@property(nonatomic,assign) CGFloat secreenWidth;
@property(nonatomic,assign) CGFloat screenHeight;
@property(nonatomic,assign) NSUInteger point;
@property(nonatomic,strong) UIView *bgview;
@property(nonatomic,strong)NSMutableArray *circleArray ;
@property(nonatomic,assign)BOOL isFinished;
@property(nonatomic,strong)NSTimer *timer;

@end

@implementation NeuronsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self= [super initWithFrame:frame]) {
        _isFinished = NO;
        [self setupUI];
        [self initPrama];
        [self draw];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           _timer =  [NSTimer timerWithTimeInterval:0.02f target:self selector:@selector(runAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
            while (!_isFinished) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
            }
            NSLog(@"%@销毁了!!!",[NSThread currentThread]);
        });
        
//        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(runAction) userInfo:nil repeats:YES];
    }
    return self;
}
-(void)setupUI{
    [self addSubview:self.bgview];
}
-(void)initPrama{
    _secreenWidth = self.bounds.size.width;
    _screenHeight = self.bounds.size.height;
    _point = 13;
    for (NSUInteger i = 0; i<_point; i++) {
        Cirlemodel *circle = [[Cirlemodel alloc]initModelWith:[self randomBetween:0 and:self.secreenWidth]
                                                         andY:[self randomBetween:0 and:self.screenHeight]
                                                     andWidth:[self randomBetween:1 and:9]
                                                   andOffsetX:[self randomBetween:10 and:-10]/40
                                                   andoffsetY:[self randomBetween:10 and:-10]/40];
        [self.circleArray addObject:circle];
    }
}
-(void)runAction{
//        [self.bgview removeFromSuperview];
//        self.bgview  = nil;
//        [self addSubview:self.bgview];
    NSLog(@"%@",[NSThread currentThread]);
    self.bgview.layer.sublayers = @[];
    
    for (int i = 0; i < _point; i++) {
        Cirlemodel *model = self.circleArray[i];
        model.originX += model.offsetX;
        model.originY += model.offsetY;
        if (model.originX > _secreenWidth) {
            model.originX = 0;
        }else if (model.originX < 0 ){
            model.originX = _secreenWidth;
        }
        
        if (model.originY > _screenHeight) {
            model.originY = 0;
        }else if (model.originY < 0){
            model.originY = _screenHeight;
        }
    }
    
    [self draw];
}

-(void)draw{
    for (Cirlemodel *model in self.circleArray) {
        [self drawCircleWidthPrama:model.originX andy:model.originY andRadio:model.width andoffsetX:model.offsetX andOffsetY:model.offsetY];
    }
    for (int i = 0; i < _point; i++) {
        for (int j = 0; j <  _point; j++) {
            if ( i+j < _point ) {
                Cirlemodel *model1 = self.circleArray[i+j];
                Cirlemodel *model2 = self.circleArray[i];
                float a = ABS(model1.originX - model2.originX);
                float b = ABS(model1.originY - model2.originY);
                float length = sqrtf( a*a + b*b );
                float lineOpcaity;
                if ( length <= _secreenWidth * 0.5 ) {
                     lineOpcaity = 0.2;
                }else if (_secreenWidth*0.5 > length > _secreenWidth){
                     lineOpcaity = 0.15;
                }else if (_secreenWidth > length >  _screenHeight * 0.5  ){
                     lineOpcaity = 0.1;
                }else {
                     lineOpcaity = 0.0;
                }
                if (lineOpcaity > 0) {
                    [self drawLineWidthPrama:model2.originX
                                        andy:model2.originY
                                  andOpacity:lineOpcaity
                                   andCloseX:model1.originX
                                   andCloseY:model1.originY];
                }
            }
        }
    }
}

//随机返回某个区间范围内的值
-(float)randomBetween:(float)smallerNumber and:(float)largerNumber{
//设置精确地位数
    int precision = 100;
    //获取他们之间的差值
    float subtraction = largerNumber - smallerNumber;
    //取绝对值
    subtraction = ABS(subtraction);
    //乘以精度的位数
    subtraction *= precision ;
    //再差之间随机
    float randomNumber = arc4random() % ((int)subtraction + 1);
    //随机的结果除以精度的位数
    randomNumber /= precision;
    //将随机的值加到较小的值上
    float result = MIN(smallerNumber, largerNumber) + randomNumber;
    //返回结果
    return result;
}


/**
 画线
 */
-(void)drawLineWidthPrama:(CGFloat)beginx andy:(CGFloat)beginy
               andOpacity:(CGFloat)opacity andCloseX:(CGFloat)closex andCloseY:(CGFloat)closey{
    CAShapeLayer *solidShaperLayer = [CAShapeLayer layer];
    
    CGMutablePathRef solidPath = CGPathCreateMutable();
    [solidShaperLayer setFillColor:[UIColor blueColor].CGColor];
    [solidShaperLayer setStrokeColor:[UIColor orangeColor].CGColor];
    solidShaperLayer.lineWidth = 0.5f;
    CGPathMoveToPoint(solidPath, NULL, beginx, beginy);
    CGPathAddLineToPoint(solidPath, NULL, closex, closey);
    
    [solidShaperLayer setPath:solidPath];
    CGPathRelease(solidPath);
    [self.bgview.layer addSublayer:solidShaperLayer];
}

/**
 画圆
 */
-(void)drawCircleWidthPrama:(CGFloat)beginx andy:(CGFloat)beginy andRadio:(CGFloat)width andoffsetX:(CGFloat)offsetx andOffsetY:(CGFloat)offsety{
    CAShapeLayer *solidLine = [CAShapeLayer layer];
    CGMutablePathRef solidPath  = CGPathCreateMutable();
    solidLine.lineWidth = 7.0f;
    solidLine.strokeColor = [UIColor greenColor].CGColor;
    solidLine.fillColor = [UIColor clearColor].CGColor;
    CGPathAddEllipseInRect(solidPath, nil, CGRectMake(beginx, beginy, width*0.5, width*0.5));
    solidLine.path = solidPath;
    CGPathRelease(solidPath);
    
    [self.bgview.layer addSublayer:solidLine];
}

#pragma mark - setter && getter
-(UIView *)bgview{
    if (!_bgview) {
        _bgview = [[UIView alloc]init];
        _bgview.frame = self.bounds;
        _bgview.backgroundColor = [UIColor whiteColor];
    }
    return _bgview;
}
-(NSMutableArray *)circleArray{
    if (!_circleArray) {
        _circleArray = [NSMutableArray arrayWithCapacity:_point];
    }
    return _circleArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)dealloc{
    NSLog(@"%@销毁了!!!",self);
}
@end

#pragma mark - 圆点模型
@implementation Cirlemodel
-(instancetype)initModelWith:(CGFloat)originX andY:(CGFloat)originY andWidth: (CGFloat)width andOffsetX:(CGFloat)offsetX andoffsetY:(CGFloat)offsetY{
    if (self = [super init]) {
        self.originX = originX;
        self.originY = originY;
        self.width = width;
        self.offsetX = offsetX;
        self.offsetY = offsetY;
    }
    return self;
}
@end
#pragma mark - 线模型
@implementation LineModel
-(instancetype)initModelWith:(CGFloat)beginX andY:(CGFloat)beginY andOpacity:(CGFloat)opacity andCloseX:(CGFloat)closeX andCloseY:(CGFloat)closeY{
    if (self = [super init]) {
        self.beginX = beginX;
        self.beginY = beginY;
        self.opacity = opacity;
        self.closeX = closeX;
        self.closeY = closeY;
    }
    return self;
}
@end


