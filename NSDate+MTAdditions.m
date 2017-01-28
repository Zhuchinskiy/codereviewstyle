//
//  NSDate+MTAdditions.m
//  Mitt
//
//  Created by Alexandr Zhuchinskiy on 27.01.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NSDate+MTAdditions.h"
#import "NSDateFormatter+MTAdditions.h"

@implementation NSDate (MTAdditions)

+ (NSDate *)MTDateFromStringLongFormat:(NSString *)dateString
{
    if (!dateString.length) {
        return nil;
    }
    NSDateFormatter *dateFormater = [NSDateFormatter MTDateFormatter];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormater dateFromString:dateString];
}

- (NSString *)MTStringInLongFormat
{
    NSDateFormatter *dateFormatter = [NSDateFormatter MTDateFormatter];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormatter stringFromDate:self];
}

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime
{
    if (!fromDateTime || !toDateTime) {
        return 0;
    }
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (NSDate *)MTNextMonthDate
{
    NSDate *today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = [NSLocale currentLocale];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                   fromDate:today];
    dateComponents.month += 1;
    dateComponents.day = 0;
    
    NSDate *nextMonth = [calendar dateFromComponents:dateComponents];
    
    return nextMonth;
}

- (NSDate *)MTNormalizedDateBegin
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = [NSLocale currentLocale];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                                                         NSCalendarUnitDay | NSCalendarUnitHour |
                                                         NSCalendarUnitMinute | NSCalendarUnitSecond)
                                               fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [calendar dateFromComponents:components];
}

- (NSDate *)MTNormalizedDateEnd
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                                                         NSCalendarUnitDay | NSCalendarUnitHour |
                                                         NSCalendarUnitMinute | NSCalendarUnitSecond)
                                               fromDate:self];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    return [calendar dateFromComponents:components];
}

- (NSString *)MTDefaultDateString
{
    return [[NSDateFormatter MTDefaultDateFormatter] stringFromDate:self];
}

- (NSString *)MTDefaultLongDateString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter MTDefaultDateFormatter];
    dateFormatter.dateFormat = [dateFormatter.dateFormat stringByAppendingString:@" HH:mm"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)MTShortDayString
{
    return [self MTDateCapitalizedRepresentationWithDateFormat:@"EEE"];
}

- (NSString *)MTShortMonthString
{
    return [self MTDateCapitalizedRepresentationWithDateFormat:@"MMM"];
}

- (NSString *)MTDateCapitalizedRepresentationWithDateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [NSDateFormatter MTDateFormatter];
    dateFormatter.dateFormat = dateFormat;
    NSString *dayString = [dateFormatter stringFromDate:self];
    
    return dayString.capitalizedString;
}

+ (NSDate *)dateByAddingMiliSecondsTimeIntervslSince1970:(double)miliSeconds
{
    return [NSDate dateWithTimeIntervalSince1970:miliSeconds/1000.0];
}

- (double)timeIntervalInMiliSecondSince1970
{
    return [self timeIntervalSince1970] * 1000.0;
}

- (NSDate *)dateByAddingMonths:(NSInteger)addMonths
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:addMonths];

    return [calendar dateByAddingComponents:components toDate:self options:0];
}

#pragma mark - Comparison

- (BOOL)isDateBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate
{
    if ([self compare:beginDate] == NSOrderedAscending) {
        return NO;
    }
    
    if ([self compare:endDate] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

@end
