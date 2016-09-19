//
//  IHFCalendarContentView.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/23.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHFCalendar.h"

@class IHFCalendarContentView;
@protocol IHFCalendarContentViewDelegate <NSObject>

@optional
/**
 Tells the delegate day button did click!
 */
- (void) calendarContentView:(IHFCalendarContentView *)content didClickDayButton:(UIButton *)sender;
@end


@interface IHFCalendarContentView : UIView

@property (strong, nonatomic) IHFCalendar *calendar;

@property (strong, nonatomic) IHFCalendarAppearence *appearence; /** Content appearence */

@property (nonatomic,strong) NSDate *minDate; /** min date , Default nil , if you set the min date , can not select the date min than minDate */

@property (nonatomic,strong) NSDate *maxDate; /** max date , Default nil , if you set the max date , can not select the date max than maxDate */

@property (nonatomic,copy) NSString *dateTextInLabel; /** The text show in header label */

/**
 Reloads data with the specified date
 */
- (void)reloadDataWithDate:(NSDate *)date;

/** 
 Reloads data with current date
 */
- (void)reloadData;

@property (weak, nonatomic) id <IHFCalendarContentViewDelegate> delegate;
@end
