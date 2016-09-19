//
//  IHFCalendarAppearence.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/24.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import "IHFCalendarAppearence.h"

@implementation IHFCalendarAppearence

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.calendarBackgroundColor = IHFCanlendarRGBAlpha(245,98,82,1);

        // Header
        self.headerBackgroundColor = IHFCanlendarRGBAlpha(38, 192, 174, 1);
        _headerLeftButtonTintColor = [UIColor whiteColor];
        _headerRightButtonTintColor = [UIColor whiteColor];
        _headerTitleFont = [UIFont systemFontOfSize:18];
        _headerTitleColor = [UIColor whiteColor];

        // content
        _contentBackgroundColor = IHFCanlendarRGBAlpha(227, 238, 239, 1);
        _contentWeeklyDayTitleFont = [UIFont systemFontOfSize:18];
        _contentWeeklyDayTitleColor = IHFCanlendarRGBAlpha(38, 192, 174, 1);
        _contentDisabledDaysTitleColor = [UIColor lightGrayColor];
        _contentTodayTitleColor = [UIColor whiteColor];
        _contentTodayBackgourndColor = IHFCanlendarRGBAlpha(36, 222, 202, 1);
        _contentDaysTitleFont = [UIFont systemFontOfSize:18];
        _contentSelectedDayBackgourndColor = [UIColor redColor];
        _contentSelectedDayTitleColor = [UIColor whiteColor];
        _contentNormalDayTitleColor = IHFCanlendarRGBAlpha(38, 192, 174, 1);
        _contentNormalDayBackgourndColor = [UIColor clearColor];
    }
    
    return self;
}
@end
