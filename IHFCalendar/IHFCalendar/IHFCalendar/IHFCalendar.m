//
//  IHFCalendar.m
//  nursing
//
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//
#import "IHFCalendar.h"
#import "NSDate+IHF.h"
#import "IHFCalendarHeaderView.h"
#import "IHFCalendarContentView.h"
#import "UIImage+IHF.h"

@interface IHFCalendar  ()<IHFCalendarHeaderViewDelegate,IHFCalendarContentViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;

// come from current date , set by user

@property (nonatomic,assign) NSInteger currentYear;
@property (nonatomic,assign) NSInteger currentMonth;

@property (strong,nonatomic) UIImageView *maskView;
@property (strong, nonatomic) IHFCalendarHeaderView *headerView;
@property (strong, nonatomic) IHFCalendarContentView *contentView;
@end

@implementation IHFCalendar

#pragma mark - configure self
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _appearence = [[IHFCalendarAppearence alloc] init];
        
        [self configureHeaderView];
        [self configureContentView];
        [self configureCalendar];
    }
    
    return self;
}

- (void)configureHeaderView {
    
    CGRect headerViewFrame = self.bounds;
    headerViewFrame.size.height = _kHeaderViewHeight;
    _headerView = [[IHFCalendarHeaderView alloc] initWithFrame:headerViewFrame];
    _headerView.delegate = self;
    _headerView.appearence = _appearence;
    [self addSubview:_headerView];
}

- (void)configureContentView {
    
    CGFloat contentY = _kHeaderViewHeight;
    
    _contentView = [[IHFCalendarContentView alloc]initWithFrame:CGRectMake(0, contentY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - contentY)];
    [self addSubview:_contentView];

    _contentView.appearence = _appearence;
    _contentView.delegate = self;
}

- (void)configureCalendar {
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;

    // Setter to load data
    self.currentDate = [NSDate date];
    [self addPanGesture];
}

- (void)changeDateWithButton:(UIButton *)dateBtn {
    
    NSInteger index = dateBtn.tag ;
    BOOL isFromRight = NO;
    
    switch (index) {
        case 10:{
            if (_currentMonth - 1 <= 0) {
                _currentMonth = 12;
                _currentYear--;
            }else{
                _currentMonth--;
            }
            
            isFromRight = NO;
        }break;
        case 11:{
            if (_currentMonth + 1 > 12) {
                _currentMonth = 1;
                _currentYear++;
            }else{
                _currentMonth++;
            }
            
            isFromRight = YES;
        }break;
            
        default:
            break;
    }
    
    // Add transtion
    [self addCurePagetransitionForView:self isFromRight:isFromRight];

    _headerView.dateText = [NSString stringWithFormat:@"%ld-%2ld",(long)_currentYear,(long)_currentMonth];
    
    _contentView.dateTextInLabel = _headerView.dateText;
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%d",(long)_currentYear,(long)_currentMonth,1];
    
    [self reloadDataWithDate:[NSDate dateFromString:dateStr format:@"yyyy-MM-dd"]];
}

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    
    // Get year , month , and day
    _currentYear = [currentDate year];
    _currentMonth = [currentDate month];
    
    // Show time label
    _headerView.dateText = [NSString stringWithFormat:@"%ld-%2ld",(long)_currentYear,(long)_currentMonth];
    _contentView.dateTextInLabel = _headerView.dateText;
}

- (void)setMinDate:(NSDate *)minDate {
    _minDate = minDate;
    
    _contentView.minDate = minDate;
    [self reloadData];
}

- (void)setMaxDate:(NSDate *)maxDate {
    _maxDate = maxDate;
    _contentView.maxDate = maxDate;
    [self reloadData];
}

- (void)reloadData {
    [self reloadDataWithDate:_currentDate];
}

- (void)reloadDataWithDate:(NSDate *)date {
    if (!self.superview) return; // If the calendar have not super view , it may have not added to superviwe , so it not need to reload data also!
    
    self.contentView.calendar = self;
    [self.contentView reloadDataWithDate:date];
}

#pragma mark - instance method show and hide calendar
+ (instancetype)calendar {
    return [self calendarWithFrame:CGRectNull];
}

+ (instancetype)calendarWithFrame:(CGRect)frame {
    
    if (CGRectIsNull(frame)) { // defalut calendar frame
        
        CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
        
        CGFloat calendarX = 0;
        CGFloat calendarY = 110;
        CGFloat calendarW = mainScreenFrame.size.width  - calendarX * 2;
        CGFloat calendarH = mainScreenFrame.size.height - calendarY * 2;
        
        frame = CGRectMake(calendarX, calendarY, calendarW, calendarH);
    }
    return [[self alloc] initWithFrame:frame];
}

- (void)show {
    [self showInView:nil];
}

- (void)showInView:(UIView *)view {
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    
    [[self class] showView:self];

    [view addSubview:self];
    
    self.maskView = [self maskViewInView:view];
    [view insertSubview:self.maskView belowSubview:self];
    [self reloadData];
}

- (void)hide {
    
    [self removeFromSuperview];
    [self.maskView removeFromSuperview];
}

#pragma mark - Class method show and hide
+ (instancetype)showCalendarWithCurrentDate:(NSDate *)date {
    return [self showCalendarWithFrame:CGRectNull inView:nil currentDate:date];
}

+ (instancetype)showCalendarInView:(UIView *)view currentDate:(NSDate *)date {
    return [self showCalendarWithFrame:CGRectNull inView:view currentDate:date];
}

+ (instancetype)showCalendarWithFrame:(CGRect)frame currentDate:(NSDate *)date {
    return [self showCalendarWithFrame:frame inView:nil currentDate:date];
}

+ (instancetype)showCalendarWithFrame:(CGRect)frame inView:(UIView *)view currentDate:(NSDate *)date{
    
    if (CGRectIsNull(frame)) { // defalut calendar frame

        NSString *deviceType = [UIDevice currentDevice].model;
        
        if (![deviceType isEqualToString:@"iPhone"]) {
            CGFloat calendarX = 0;
            CGFloat calendarY = 0;
            CGFloat calendarW = 391;
            CGFloat calendarH = 321;
            frame = CGRectMake(calendarX, calendarY, calendarW, calendarH);
        } else {
            CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
            CGFloat calendarX = 0;
            CGFloat calendarY = 110;
            CGFloat calendarW = mainScreenFrame.size.width  - calendarX * 2;
            CGFloat calendarH = mainScreenFrame.size.height - calendarY * 2;
            
            frame = CGRectMake(calendarX, calendarY, calendarW, calendarH);
        }
    }
    
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    
    IHFCalendar *taskCalendar = [[IHFCalendar alloc] initWithFrame:frame];
    
    taskCalendar.maskView = [self maskViewInView:view];
    [view addSubview:taskCalendar.maskView];
    
    taskCalendar.center = view.center;
    [view addSubview:taskCalendar];

    [self showView:taskCalendar];

    taskCalendar.currentDate = date; // show the user given date
    [taskCalendar reloadData];
    return taskCalendar;
}

+ (IHFCalendar *)calendarForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (IHFCalendar *)subview;
        }
    }
    return nil;
}

+ (void)hideCalendarInView:(UIView *)view {
    
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    
    IHFCalendar *taskCalendar = [IHFCalendar calendarForView:view];

    [taskCalendar removeFromSuperview];
    [taskCalendar.maskView removeFromSuperview];
    taskCalendar.maskView = nil;
    taskCalendar = nil;
}

+ (void)hideCalendar {
    [self hideCalendarInView:nil];
}

#pragma mark - show BackgroundView

- (UIImageView *)maskViewInView:(UIView *)view {
    
    CGRect currentScreenFrame = [[UIScreen mainScreen] bounds];
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:currentScreenFrame];
    maskView.image = [UIImage imageOfScreenBlurWithView:view];
    maskView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMaskView:)];
    [maskView addGestureRecognizer:tap];
    return maskView;
}

+ (UIImageView *)maskViewInView:(UIView *)view {
    
    CGRect currentScreenFrame = [[UIScreen mainScreen] bounds];
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:currentScreenFrame];
    maskView.image = [UIImage imageOfScreenBlurWithView:view];
    maskView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMaskView:)];
    [maskView addGestureRecognizer:tap];
    return maskView;
}


+ (void)didTapMaskView:(UITapGestureRecognizer *)tap {
    [self hideCalendarInView:tap.view.superview];
}

- (void)didTapMaskView:(UITapGestureRecognizer *)tap {
    [self hide];
}

#pragma mark - handle gesture

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    
    BOOL isAnima = NO;
    CGPoint point;

    if (gesture.state == UIGestureRecognizerStateEnded) {
        point = [gesture translationInView:_scrollView];
    }
   
    UIButton *button = [[UIButton alloc] init];
    if(point.x < -30) {  // to the right
        isAnima = YES;
        button.tag = 11;
    } else if (point.x > 30) {
        isAnima = YES;
        button.tag = 10;
    }
    
    if (isAnima) {
        [self changeDateWithButton:button];
    }
}

#pragma mark - core animation
- (void)addCurePagetransitionForView:(UIView *)view isFromRight:(BOOL)isFromRight {
    
    CATransition *anima = [CATransition animation];
    anima.type          = (isFromRight ? @"pageCurl" : @"pageUnCurl");
    anima.duration      = 0.5;
    anima.subtype       = (isFromRight ? kCATransitionFromTop : kCATransitionFromBottom);
    
    [self.layer addAnimation:anima forKey:nil];
}

+ (void)showView:(UIView *)popupView {
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [popupView.layer addAnimation:popAnimation forKey:nil];
    
}

#pragma mark - Header view delegate
- (void)calendarHeaderView:(IHFCalendarHeaderView *)HeaderView didClickButton:(UIButton *)sender {
    [self changeDateWithButton:sender];
}

#pragma mark - content view delegate
- (void)calendarContentView:(IHFCalendarContentView *)content didClickDayButton:(UIButton *)sender {
    
    NSString *selectedStr = [NSString stringWithFormat:@"%ld-%ld-%d",(long)_currentYear,(long)_currentMonth,(int)sender.tag];
    
    // Get date
    NSDate *date = [NSDate dateFromString:selectedStr format:@"yyyy-MM-dd"];
    
    self.currentDate = date;
    if ([_delegate respondsToSelector:@selector(calendar:didSelectedDate:)]) {
        [_delegate calendar:self didSelectedDate:date];
    }
    
    [self hide];
}
@end
