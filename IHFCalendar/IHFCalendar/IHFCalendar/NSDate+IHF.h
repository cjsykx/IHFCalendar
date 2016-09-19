//
//  NSDate+IHFCalendar.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/22.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (IHF)

@property (readonly, nonatomic) NSInteger year;
@property (readonly, nonatomic) NSInteger month;
@property (readonly, nonatomic) NSInteger day;
@property (readonly, nonatomic) NSInteger weekday;
@property (readonly, nonatomic) NSInteger weekOfYear;
@property (readonly, nonatomic) NSInteger hour;
@property (readonly, nonatomic) NSInteger minute;
@property (readonly, nonatomic) NSInteger second;

@property (readonly, nonatomic) NSDate *dateByIgnoringTimeComponents;
@property (readonly, nonatomic) NSDate *firstDayOfMonth;
@property (readonly, nonatomic) NSDate *lastDayOfMonth;
@property (readonly, nonatomic) NSDate *firstDayOfWeek;
@property (readonly, nonatomic) NSDate *middleOfWeek;
@property (readonly, nonatomic) NSDate *tomorrow;
@property (readonly, nonatomic) NSDate *yesterday;
@property (readonly, nonatomic) NSInteger numberOfDaysInMonth;
@property (readonly, nonatomic) NSInteger numberOfFirstDayInMonth;


/** Return date from this string
 */

+ (instancetype)dateFromString:(NSString *)string format:(NSString *)format;

/** Return date from this string
 @ defalt format 'yyyy-MM-dd HH:mm:ss'
 */

+ (instancetype)dateFromString:(NSString *)string;
+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

- (NSDate *)dateByAddingYears:(NSInteger)years;
- (NSDate *)dateBySubtractingYears:(NSInteger)years;
- (NSDate *)dateByAddingMonths:(NSInteger)months;
- (NSDate *)dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks;
- (NSDate *)dateBySubtractingWeeks:(NSInteger)weeks;
- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateBySubtractingDays:(NSInteger)days;


- (NSInteger)yearsFrom:(NSDate *)date;
- (NSInteger)monthsFrom:(NSDate *)date;
- (NSInteger)weeksFrom:(NSDate *)date;
- (NSInteger)daysFrom:(NSDate *)date;
// equal
- (BOOL)isEqualToDateForMonth:(NSDate *)date;
- (BOOL)isEqualToDateForWeek:(NSDate *)date;
- (BOOL)isEqualToDateForDay:(NSDate *)date;

/** Return string from this date
 */

- (NSString *)stringWithFormat:(NSString *)format;

/** Return string from this date 
 @ defalt format 'yyyy-MM-dd HH:mm:ss'
 */
- (NSString *)string;

- (NSString *)stringOfYear_month;
@end

@interface NSCalendar (IHF)

+ (instancetype)sharedCalendar;

@end

@interface NSDateFormatter (IHF)

+ (instancetype)sharedDateFormatter;

@end

@interface NSDateComponents (IHF)

+ (instancetype)sharedDateComponents;

@end