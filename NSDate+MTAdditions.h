//
//  NSDate+MTAdditions.h
//  Mitt
//
//  Created by Alexandr Zhuchinskiy on 27.01.14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MTAdditions)

/**
 Uses "yyyyMMddHHmmss" format
 */
+ (NSDate *)MTDateFromStringLongFormat:(NSString *)dateString;

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime;

+ (NSDate *)MTNextMonthDate;


/**
 sets hour, minute, second to 0.
 */
- (NSDate *)MTNormalizedDateBegin;

/**
 sets time to 23:59:59.
 */
- (NSDate *)MTNormalizedDateEnd;

/**
 Uses "yyyyMMddHHmmss" format
 */
- (NSString *)MTStringInLongFormat;

/**
 Uses "YYYY-M-d" format
 */
- (NSString *)MTDefaultDateString;

/**
 Uses "YYYY-M-d HH:mm" format
 */
- (NSString *)MTDefaultLongDateString;

- (BOOL)isDateBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate;

/**
 Returns string, representing the day for this date in format "EEE" (Mon, Fri, ...).
 First letter - always capitalized.
 */
- (NSString *)MTShortDayString;

/**
 Returns string, representing the month for this date in format "MMM" (Oct, May, ...).
 First letter - always capitalized.
 */
- (NSString *)MTShortMonthString;

- (NSDate *)dateByAddingMonths:(NSInteger)addMonths;

/**
 Returns string, representing the the date in format 'dateFormat'.
 First letter - always capitalized.
 */
- (NSString *)MTDateCapitalizedRepresentationWithDateFormat:(NSString *)dateFormat;

/**
 Returns date with time interval by adding time in ms(in method we convert it to second).
 */

+ (NSDate *)dateByAddingMiliSecondsTimeIntervslSince1970:(double)miliSeconds;

/**
 Returns time interval in mili seconds since 1970.
 */

- (double)timeIntervalInMiliSecondSince1970;


@end
