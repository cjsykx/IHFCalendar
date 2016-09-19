//
//  NSDate+IHFCalendar.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/22.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import "NSDate+IHF.h"

@implementation NSDate (IHF)

- (NSInteger)year {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitYear fromDate:self];
    return component.year;
}

- (NSInteger)month {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitMonth
                                              fromDate:self];
    return component.month;
}

- (NSInteger)day {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitDay
                                              fromDate:self];
    return component.day;
}

- (NSInteger)weekday {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitWeekday fromDate:self];
    return component.weekday;
}

- (NSInteger)weekOfYear {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitWeekOfYear fromDate:self];
    return component.weekOfYear;
}

- (NSInteger)hour {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitHour
                                              fromDate:self];
    return component.hour;
}

- (NSInteger)minute {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitMinute
                                              fromDate:self];
    return component.minute;
}

- (NSInteger)second {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitSecond
                                              fromDate:self];
    return component.second;
}

- (NSDate *)dateByIgnoringTimeComponents {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSDate *)firstDayOfMonth {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay fromDate:self];
    components.day = 1;
    return [calendar dateFromComponents:components];
}

- (NSDate *)lastDayOfMonth {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.month++;
    components.day = 0;
    return [calendar dateFromComponents:components];
}

- (NSDate *)firstDayOfWeek {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToSubtract = [NSDateComponents sharedDateComponents];
    componentsToSubtract.day = - (weekdayComponents.weekday - calendar.firstWeekday);
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:beginningOfWeek];
    beginningOfWeek = [calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return beginningOfWeek;
}

- (NSDate *)middleOfWeek {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToSubtract = [NSDateComponents sharedDateComponents];
    componentsToSubtract.day = - (weekdayComponents.weekday - calendar.firstWeekday) + 3;
    NSDate *middleOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:middleOfWeek];
    middleOfWeek = [calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleOfWeek;
}

- (NSDate *)tomorrow {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day++;
    return [calendar dateFromComponents:components];
}

- (NSDate *)yesterday {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day--;
    return [calendar dateFromComponents:components];
}

- (NSInteger)numberOfDaysInMonth {
    NSCalendar *c = [NSCalendar sharedCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:self];
    return days.length;
}

- (NSInteger)numberOfFirstDayInMonth {
 
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%d",(long)component.year,(long)component.month,1];
    
    // Get month first date
    NSDate *date = [NSDate dateFromString:dateStr format:@"yyyy-MM-dd"];
    NSDateComponents *comps = [[NSCalendar sharedCalendar] components:(NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal) fromDate:date];
    
    NSInteger weekday = [comps weekday];
    NSInteger isFirstDay = weekday - comps.day % 7;
        
    if (isFirstDay < 0)  {
        isFirstDay += 7;
    }
    return isFirstDay;
}


+ (instancetype)dateFromString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

+ (instancetype)dateFromString:(NSString *)string {
    return [self dateFromString:string format:@"yyyy-MM-dd HH:mm:ss"];
}


+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [NSDateComponents sharedDateComponents];
    components.year = year;
    components.month = month;
    components.day = day;
    NSDate *date = [calendar dateFromComponents:components];
    components.year = NSIntegerMax;
    components.month = NSIntegerMax;
    components.day = NSIntegerMax;
    return date;
}

- (NSDate *)dateByAddingYears:(NSInteger)years {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [NSDateComponents sharedDateComponents];
    components.year = years;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.year = NSIntegerMax;
    return date;
}

- (NSDate *)dateBySubtractingYears:(NSInteger)years {
    return [self dateByAddingYears:-years];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [NSDateComponents sharedDateComponents];
    components.month = months;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.month = NSIntegerMax;
    return date;
}

- (NSDate *)dateBySubtractingMonths:(NSInteger)months {
    return [self dateByAddingMonths:-months];
}

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [NSDateComponents sharedDateComponents];
    components.weekOfYear = weeks;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.weekOfYear = NSIntegerMax;
    return date;
}

-(NSDate *)dateBySubtractingWeeks:(NSInteger)weeks {
    return [self dateByAddingWeeks:-weeks];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [NSDateComponents sharedDateComponents];
    components.day = days;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.day = NSIntegerMax;
    return date;
}

- (NSDate *)dateBySubtractingDays:(NSInteger)days {
    return [self dateByAddingDays:-days];
}

- (NSInteger)yearsFrom:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.year;
}

- (NSInteger)monthsFrom:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.month;
}

- (NSInteger)weeksFrom:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekOfYear
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.weekOfYear;
}

- (NSInteger)daysFrom:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.day;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)string {
    return [self stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSString *)stringOfYear_month {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
    
    return [NSString stringWithFormat:@"%ld-%2ld",(long)comps.year,(long)comps.month];
}


- (BOOL)isEqualToDateForMonth:(NSDate *)date {
    return self.year == date.year && self.month == date.month;
}

- (BOOL)isEqualToDateForWeek:(NSDate *)date {
    return self.year == date.year && self.weekOfYear == date.weekOfYear;
}

- (BOOL)isEqualToDateForDay:(NSDate *)date {
    return self.year == date.year && self.month == date.month && self.day == date.day;
}

@end

// *************** single instance ********************

@implementation NSCalendar (IHFExtension)

+ (instancetype)sharedCalendar {
    static id instance;
    static dispatch_once_t sharedCalendar_onceToken;
    dispatch_once(&sharedCalendar_onceToken, ^{
        instance = [NSCalendar currentCalendar];
    });
    return instance;
}

@end


@implementation NSDateFormatter (IHF)

+ (instancetype)sharedDateFormatter {
    static id instance;
    static dispatch_once_t sharedDateFormatter_onceToken;
    dispatch_once(&sharedDateFormatter_onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
    });
    return instance;
}

@end

@implementation NSDateComponents (IHF)

+ (instancetype)sharedDateComponents{
    static id instance;
    static dispatch_once_t sharedDateFormatter_onceToken;
    dispatch_once(&sharedDateFormatter_onceToken, ^{
        instance = [[NSDateComponents alloc] init];
    });
    return instance;
}

@end

