//
//  IHFCalendarContentView.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/23.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import "IHFCalendarContentView.h"
#import "NSDate+IHF.h"
#import "UIImage+IHF.h"

static CGFloat _kWeekLabelH = 20.f;

#define DAYBUTTONWIDTH CGRectGetWidth(self.frame) / _kWeekCount
#define DAYBUTTONHEIGHT (CGRectGetHeight(self.frame) - _kHeaderViewHeight) / _kRowCount

#define  MINSizeValue  MIN(DAYBUTTONWIDTH, DAYBUTTONHEIGHT)

@interface IHFCalendarContentView ()

@property (strong, nonatomic) NSArray <UILabel *>*weeklyDaysLabels;

@property (weak, nonatomic) UIView *daysView;

// come from min
@property (nonatomic,copy)   NSString  *minStrCurrentDate;
@property (nonatomic,assign) NSInteger  minDays;

// come from max
@property (nonatomic,copy)   NSString  *maxStrCurrentDate;
@property (nonatomic,assign) NSInteger  maxDays;

// current date
@property (nonatomic,copy)   NSString  *currentYear_MonthString;
@property (nonatomic,assign) NSInteger currentDay;


@end

@implementation IHFCalendarContentView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        [self configureView];
    }
    return self;
}

- (void)configureView {
    
    // Add label
    NSArray *weekArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];

    NSMutableArray *weeklyArr = [NSMutableArray array];
    for (int i = 0; i < weekArray.count; i++) {
        UILabel *weekLab = [[UILabel alloc]init];
        weekLab.textAlignment = NSTextAlignmentCenter;
        weekLab.text = [weekArray objectAtIndex:i];
        [self addSubview:weekLab];
        [weeklyArr addObject:weekLab];
    }
    
    _weeklyDaysLabels = weeklyArr;
    
    UIView *daysView = [[UIView alloc] init];
    [self addSubview:daysView];
    _daysView = daysView;
}

- (void)setCalendar:(IHFCalendar *)calendar {
    
    _calendar = calendar;
    
    _currentDay = [calendar.currentDate day];
    _currentYear_MonthString = [NSString stringWithFormat:@"%ld-%2ld",(long)[calendar.currentDate year],(long)[calendar.currentDate month]];
}

- (void)setAppearence:(IHFCalendarAppearence *)appearence {
    
    _appearence = appearence;
    
    self.backgroundColor = appearence.contentBackgroundColor;
    [_weeklyDaysLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.textColor = appearence.contentWeeklyDayTitleColor;
        obj.font = appearence.contentWeeklyDayTitleFont;
    }];
    
    [self addObserverForAppearence:appearence];
}

#pragma mark - add observer
- (void)addObserverForAppearence:(IHFCalendarAppearence *)appearence {
    
    [appearence addObserver:self forKeyPath:@"contentBackgroundColor" options:0 context:nil];
    [appearence addObserver:self forKeyPath:@"contentWeeklyDayTitleColor" options:0 context:nil];
    [appearence addObserver:self forKeyPath:@"contentWeeklyDayTitleFont" options:0 context:nil];
}

- (void)dealloc {
    [_appearence removeObserver:self forKeyPath:@"contentBackgroundColor"];
    [_appearence removeObserver:self forKeyPath:@"contentWeeklyDayTitleColor"];
    [_appearence removeObserver:self forKeyPath:@"contentWeeklyDayTitleFont"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    __weak typeof(self) weakSelf = self;
    if (object == _appearence) {
        if ([keyPath isEqualToString:@"contentBackgroundColor"]) {
            self.backgroundColor = _appearence.contentBackgroundColor;
        } else if ([keyPath isEqualToString:@"contentWeeklyDayTitleColor"]) {
            [_weeklyDaysLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.textColor = weakSelf.appearence.contentWeeklyDayTitleColor;
            }];
        } else if ([keyPath isEqualToString:@"contentWeeklyDayTitleFont"]) {
            [_weeklyDaysLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.font = weakSelf.appearence.contentWeeklyDayTitleFont;
            }];
        }
    }
}

#pragma mark - reload data
- (void)reloadDataWithDate:(NSDate *)date {
    
    NSInteger isFirstDay = [date numberOfFirstDayInMonth];
    int monthDays = (int)[date numberOfDaysInMonth];
    
    for (UIView *view in [self.daysView subviews]) {
        [view removeFromSuperview];
    }
    
    UIColor *disableColor = _calendar.appearence.contentDisabledDaysTitleColor;
    
    // Get day btn height
    CGFloat iYoffset = 0.0;
    
    // Get previous number of days
    
    int previousMonthDays = (int)[[date dateBySubtractingMonths:1] numberOfDaysInMonth];
    
    CGFloat dayBtnWSize = MINSizeValue;
    CGFloat marginX = (CGRectGetWidth(self.frame) - 7 * dayBtnWSize) / 8;
    
    // Add previous month day
    for (int i = 0; i < isFirstDay; i++) {
        UIButton *dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dayBtn.layer.cornerRadius = MINSizeValue * 0.5;
        dayBtn.layer.masksToBounds = YES;
        dayBtn.frame = CGRectMake(marginX + i * (dayBtnWSize + marginX), iYoffset, dayBtnWSize, dayBtnWSize);
        [dayBtn setTitle:[NSString stringWithFormat:@"%ld",(long)(previousMonthDays - (isFirstDay - i) + 1)] forState:UIControlStateNormal];
        [dayBtn setTitleColor:disableColor forState:UIControlStateNormal];

        dayBtn.titleLabel.font = _calendar.appearence.contentDaysTitleFont;

        [self.daysView addSubview:dayBtn];
    }
    
    CGFloat iXoffset = marginX + isFirstDay * (dayBtnWSize + marginX);

    // Add current month day
    for (int i = 1;i <= monthDays; i++) {
        
        UIButton *dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dayBtn.layer.cornerRadius = MINSizeValue * 0.5;
        dayBtn.layer.masksToBounds = YES;
        dayBtn.frame = CGRectMake(iXoffset, iYoffset, MINSizeValue, MINSizeValue);
        dayBtn.titleLabel.font = _calendar.appearence.contentDaysTitleFont;
        
        [dayBtn setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        
        [dayBtn setBackgroundImage:[UIImage imageWithColor:_calendar.appearence.contentSelectedDayBackgourndColor] forState:UIControlStateSelected];
        [dayBtn setBackgroundImage:[UIImage imageWithColor:_calendar.appearence.contentNormalDayBackgourndColor] forState:UIControlStateNormal];
        
        [dayBtn setTitleColor:_calendar.appearence.contentNormalDayTitleColor forState:UIControlStateNormal];
        [dayBtn setTitleColor:_calendar.appearence.contentSelectedDayTitleColor forState:UIControlStateSelected];

        NSString *strCurrentDate = _dateTextInLabel; // Show text label text
        
        // is year and month equal,for min
        if ([_minStrCurrentDate isEqualToString:strCurrentDate]) {
            if (_minDays > i) {
                [dayBtn setTitleColor:disableColor forState:UIControlStateNormal];
                dayBtn.enabled = NO;
            }
        } else if ([_minStrCurrentDate compare:strCurrentDate] == NSOrderedDescending) {
            [dayBtn setTitleColor:disableColor forState:UIControlStateNormal];
            dayBtn.enabled = NO;
        }
        
        // is year and month equal , for max
        if ([_maxStrCurrentDate isEqualToString:strCurrentDate]) {
            if (_maxDays < i) {
                [dayBtn setTitleColor:disableColor forState:UIControlStateNormal];
                dayBtn.enabled = NO;
            }
        } else if ([_maxStrCurrentDate compare:strCurrentDate] == NSOrderedAscending){
            [dayBtn setTitleColor:disableColor forState:UIControlStateNormal];
            dayBtn.enabled = NO;
        }
        
        NSDate *today = [NSDate date];
        if ([strCurrentDate isEqualToString:[today stringOfYear_month]]) {
            
            if ([today day] == i) {
                [dayBtn setBackgroundImage:[UIImage imageWithColor:_calendar.appearence.contentTodayBackgourndColor] forState:UIControlStateNormal];
                [dayBtn setTitleColor:_calendar.appearence.contentTodayTitleColor forState:UIControlStateNormal];
            }
        }
        
        if ([strCurrentDate isEqualToString:_currentYear_MonthString]) {
            if (_currentDay == i) {
                dayBtn.selected = YES;
            }
        }
        
        dayBtn.tag = i;
        [dayBtn addTarget:self action:@selector(didClickDayBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.daysView addSubview:dayBtn];
        
        if (iXoffset >= CGRectGetWidth(self.frame) - (dayBtnWSize + marginX)) {
            
            iXoffset = marginX;
            iYoffset += DAYBUTTONHEIGHT;
        } else{
            iXoffset += dayBtnWSize + marginX;
        }
    }
    
    // Add Next month day
    NSInteger nextMonthCount = (_kRowCount * _kWeekCount) - isFirstDay - monthDays;
    
    for (int i = 1; i <= nextMonthCount; i++) {
        UIButton *dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dayBtn.layer.cornerRadius = MINSizeValue * 0.5;
        dayBtn.layer.masksToBounds = YES;
        dayBtn.frame = CGRectMake(iXoffset, iYoffset, MINSizeValue, MINSizeValue);
        [dayBtn setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [dayBtn setTitleColor:disableColor forState:UIControlStateNormal];
        dayBtn.titleLabel.font = _calendar.appearence.contentDaysTitleFont;

        [self.daysView addSubview:dayBtn];
        
        if (iXoffset >= CGRectGetWidth(self.frame) - (dayBtnWSize + marginX)) {
            
            iXoffset = marginX;
            iYoffset += DAYBUTTONHEIGHT;
        } else {
            iXoffset += dayBtnWSize + marginX;
        }
    }
}

- (void)reloadData {
    [self reloadDataWithDate:_calendar.currentDate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat marginY = 10;
    CGFloat weeklabH = _kWeekLabelH;
    
    CGFloat WeeklyWidth = MINSizeValue;
    CGFloat marginX = (CGRectGetWidth(self.frame) - 7 * WeeklyWidth) / 8;
    
    [_weeklyDaysLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.frame = CGRectMake(idx * (WeeklyWidth + marginX) + marginX, marginY, MINSizeValue, weeklabH);
    }];
    
    // Days view frame
    CGFloat dayViewY = _kWeekLabelH + 2 * marginY;     // margin = 10;
    
    self.daysView.frame = CGRectMake(0, _kWeekLabelH + 2 * 10, self.frame.size.width, self.frame.size.height - dayViewY);
}

#pragma mark - min and max date

- (void)setMinDate:(NSDate *)minDate {
    
    _minDate = minDate;
    
    _minStrCurrentDate = [minDate stringOfYear_month];
    _minDays = [minDate day];
}

- (void)setMaxDate:(NSDate *)maxDate {
    
    _maxDate = maxDate;
    
    _maxStrCurrentDate = [maxDate stringOfYear_month];
    _maxDays = [maxDate day];
}

#pragma mark - button action

- (void)didClickDayBtn:(UIButton *)sender {
    
    sender.selected = YES;
    
    if([self.delegate respondsToSelector:@selector(calendarContentView:didClickDayButton:)]) {
        [self.delegate calendarContentView:self didClickDayButton:sender];
    }
}
@end
