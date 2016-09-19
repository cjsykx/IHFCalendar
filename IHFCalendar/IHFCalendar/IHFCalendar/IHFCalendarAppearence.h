//
//  IHFCalendarAppearence.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/24.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IHFCanlendarRGBAlpha(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

/**
 Main use to control the appearce for IHFCalendar , you can change the calendar appearce to fit your APP!
 */
@interface IHFCalendarAppearence : NSObject

@property (strong, nonatomic) UIColor  *calendarBackgroundColor;

// Header
@property (strong, nonatomic) UIColor  *headerBackgroundColor;
@property (strong, nonatomic) UIFont   *headerTitleFont;
@property (strong, nonatomic) UIColor  *headerLeftButtonTintColor;
@property (strong, nonatomic) UIColor  *headerRightButtonTintColor;

@property (strong, nonatomic) UIColor  *headerTitleColor;

// Content
@property (strong, nonatomic) UIColor  *contentBackgroundColor;
@property (strong, nonatomic) UIFont   *contentWeeklyDayTitleFont;
@property (strong, nonatomic) UIColor  *contentWeeklyDayTitleColor;

@property (strong, nonatomic) UIFont   *contentDaysTitleFont;

@property (strong, nonatomic) UIColor  *contentDisabledDaysTitleColor; /**< Disable day , like beyong min and max date , or pervious and next month days */

// select (current day)
@property (strong, nonatomic) UIColor  *contentSelectedDayTitleColor;
@property (strong, nonatomic) UIColor  *contentSelectedDayBackgourndColor;

// normal (NOT current day)
@property (strong, nonatomic) UIColor  *contentNormalDayTitleColor;
@property (strong, nonatomic) UIColor  *contentNormalDayBackgourndColor;


@property (strong, nonatomic) UIColor  *contentTodayTitleColor;
@property (strong, nonatomic) UIColor  *contentTodayBackgourndColor;

@end
