//
//  IHFTaskCalendar.h
//  nursing
//
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.


#import <UIKit/UIKit.h>
#import "IHFCalendarAppearence.h"

static NSInteger _kRowCount = 6;
static NSInteger _kWeekCount = 7;
static CGFloat _kHeaderViewHeight = 50;


@class IHFCalendar;
@protocol IHFCalendarDelegate <NSObject>
@optional
/**
 Tells the delegate calendar did select and selected date!
 */
- (void)calendar:(IHFCalendar *)calendar didSelectedDate:(NSDate *)date;
@end

@interface IHFCalendar : UIView

@property (strong, nonatomic ,readonly) IHFCalendarAppearence *appearence;

@property (nonatomic,strong) NSDate *currentDate; /** Default today , the current date is the calendar selected date */

@property (nonatomic,weak)id <IHFCalendarDelegate> delegate;

@property (nonatomic,strong) NSDate *minDate;  /** min date , Default nil , if you set the min date , can not select the date min than minDate */

@property (nonatomic,strong) NSDate *maxDate; /** max date , Default nil , if you set the max date , can not select the date max than maxDate */

// ********************* Use Class method to show ***********************************
// @warning : If you want to set the calendar appearence , please use instance method to set appearence and show calendar!

/**
 Show calendar with the specipied selected date
 @ frame : frame is defalut .
 @ View : view is defalut window last object.
 */
+ (instancetype)showCalendarWithCurrentDate:(NSDate *)date;

/**
 Show calendar with the specipied selected date and frame .
 @ View : view is defalut window last object.
 */
+ (instancetype)showCalendarWithFrame:(CGRect)frame currentDate:(NSDate *)date;

/**
 Show calendar with the specipied selected date and view .
 @ frame : frame is defalut .
 */
+ (instancetype)showCalendarInView:(UIView *)view currentDate:(NSDate *)date;

/**
 Show calendar with the specipied selected date , frame and view .
 */
+ (instancetype)showCalendarWithFrame:(CGRect)frame inView:(UIView *)view currentDate:(NSDate *)date;
/**
 Hide calendar .
 */

+ (void)hideCalendar;

/**
 Hide calendar with the specipied view.
 */

+ (void)hideCalendarInView:(UIView *)view;

// ************************* Use instance method to show ******

/**
 Create calendar with Defalut frame .
 */

+ (instancetype)calendar;

/**
 Create calendar with specified frame .
 */

+ (instancetype)calendarWithFrame:(CGRect)frame;

/**
 Show calendar in the default view
 */

- (void)show;

/**
 Show calendar in the specified view
 */

- (void)showInView:(UIView *)view;

/**
 hide calendar
 */

- (void)hide;

/** 
 Reload data with the specified date 
 */
- (void)reloadDataWithDate:(NSDate *)date;

/** 
 Reload data with current date
 */
- (void)reloadData;

@end
