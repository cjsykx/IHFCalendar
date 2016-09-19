//
//  IHFCalendarHeaderView.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/23.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//
#define IHFCanlendarRGBAlpha(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#import "IHFCalendarHeaderView.h"
#import "UIImage+IHF.h"

static CGFloat kHeaderViewButtonWidth = 50.f;

@interface IHFCalendarHeaderView ()
@property (nonatomic,weak) UILabel *showDateLabal;
@property (nonatomic,weak) UIButton *leftArrowBtn;
@property (nonatomic,weak) UIButton *rightArrowBtn;

@end

@implementation IHFCalendarHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        [self configureView];
    }
    return self;
}

- (void)configureView {
    
    // Add label
    
    UILabel *label = [[UILabel alloc] init];
    
    label.textAlignment = NSTextAlignmentCenter;
 
    [self addSubview:label];
    _showDateLabal = label;

    
    // Add left btn
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize imagesize = CGSizeMake(kHeaderViewButtonWidth, kHeaderViewButtonWidth);
    CGSize size = CGSizeMake(kHeaderViewButtonWidth * 0.3, kHeaderViewButtonWidth * 0.4);

    CGPoint offset = CGPointMake(-1, -1);
    CGFloat rotate = 0.f;
    CGFloat kThinckness = 2.f;
    
    UIImage *leftArrowImage = [UIImage imageWithArrowImageSize:imagesize size:size offset:offset rotate:rotate thickness:kThinckness direction:IHFImageDirectionLeft backgroundColor:[UIColor clearColor] color:[UIColor whiteColor] dash:nil shadowColor:[UIColor clearColor] shadowOffset:CGPointZero shadowBlur:1.0f];
    
    [leftBtn setImage:leftArrowImage forState:UIControlStateNormal];

    leftBtn.tag = 10;
    [self addSubview:leftBtn];
    _leftArrowBtn = leftBtn;
    
    // Add right btn
    
    UIImage *rightArrowImage = [UIImage imageWithArrowImageSize:imagesize size:size offset:offset rotate:rotate thickness:kThinckness direction:IHFImageDirectionRight backgroundColor:[UIColor clearColor] color:[UIColor whiteColor] dash:nil shadowColor:[UIColor clearColor] shadowOffset:CGPointZero shadowBlur:1.0f];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 11;
    [rightBtn setImage:rightArrowImage forState:UIControlStateNormal];
    [self addSubview:rightBtn];
    _rightArrowBtn = rightBtn;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat dateLabelW = 73;
    CGFloat dateLabelH = 20;
    CGFloat dateLabelY = 15;

    CGFloat margin = 30 ;  // Margin from btn to label

    // left btn frame
    
    CGFloat HeaderBtnLeftSpace = (CGRectGetWidth(self.frame) * 0.5 - kHeaderViewButtonWidth - margin - dateLabelW * 0.5);

    _leftArrowBtn.frame = CGRectMake(HeaderBtnLeftSpace , 0 , kHeaderViewButtonWidth,kHeaderViewButtonWidth);

    _showDateLabal.frame = CGRectMake(CGRectGetMaxX(_leftArrowBtn.frame) + margin, dateLabelY, dateLabelW, dateLabelH);
    
    _rightArrowBtn.frame = CGRectMake(HeaderBtnLeftSpace + 2 * margin + dateLabelW + kHeaderViewButtonWidth, 0 , kHeaderViewButtonWidth,kHeaderViewButtonWidth);
}

- (void)setDateText:(NSString *)dateText {
    
    _dateText = dateText;
    self.showDateLabal.text = dateText;
}

#pragma mark - button action
- (void)didClickBtn:(UIButton *)sender {
    
    if([self.delegate respondsToSelector:@selector(calendarHeaderView:didClickButton:)]) {
        [self.delegate calendarHeaderView:self didClickButton:sender];
    }
}

#pragma mark - appearence

- (void)setAppearence:(IHFCalendarAppearence *)appearence {
    
    _appearence = appearence;
    self.backgroundColor = appearence.headerBackgroundColor;
    _showDateLabal.textColor = appearence.headerTitleColor;
    _showDateLabal.font = appearence.headerTitleFont;
    _leftArrowBtn.imageView.tintColor = appearence.headerLeftButtonTintColor;
    _rightArrowBtn.imageView.tintColor = appearence.headerRightButtonTintColor;
    
    [self addObserverForAppearence:appearence];
}

#pragma mark - add observer
- (void)addObserverForAppearence:(IHFCalendarAppearence *)appearence {
    
    [appearence addObserver:self forKeyPath:@"headerBackgroundColor" options:0 context:nil];
    [appearence addObserver:self forKeyPath:@"headerTitleColor" options:0 context:nil];
    [appearence addObserver:self forKeyPath:@"headerTitleFont" options:0 context:nil];
    [appearence addObserver:self forKeyPath:@"headerLeftButtonTintColor" options:0 context:nil];
    [appearence addObserver:self forKeyPath:@"headerRightButtonTintColor" options:0 context:nil];
}

- (void)dealloc {
    [_appearence removeObserver:self forKeyPath:@"headerBackgroundColor"];
    [_appearence removeObserver:self forKeyPath:@"headerTitleColor"];
    [_appearence removeObserver:self forKeyPath:@"headerTitleFont"];
    [_appearence removeObserver:self forKeyPath:@"headerLeftButtonTintColor"];
    [_appearence removeObserver:self forKeyPath:@"headerRightButtonTintColor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context  {
    
    if (object == _appearence) {
        if ([keyPath isEqualToString:@"headerBackgroundColor"]) {
            self.backgroundColor = _appearence.headerBackgroundColor;
        }else if ([keyPath isEqualToString:@"headerTitleColor"]) {
            _showDateLabal.textColor = _appearence.headerTitleColor;
        }else if ([keyPath isEqualToString:@"headerTitleFont"]) {
            _showDateLabal.font = _appearence.headerTitleFont;
        }else if ([keyPath isEqualToString:@"headerLeftButtonTintColor"]) {
            _leftArrowBtn.imageView.tintColor = _appearence.headerLeftButtonTintColor;
        }else if ([keyPath isEqualToString:@"headerRightButtonTintColor"]) {
            _rightArrowBtn.imageView.tintColor = _appearence.headerRightButtonTintColor;
        }
    }
}

@end
