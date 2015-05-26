//
//  CalHelper.h
//  UserLoginLog
//
//  Created by Christer Ulfsparre on 25/05/15.
//  Copyright (c) 2015 Christer Ulfsparre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface CalHelper : NSObject

- (void)requestCalendarAccessWithSuccess:(void (^)(void))success
                              withFailed:(void (^)(NSError *))failed;

- (NSUInteger)getCurrentMonth;
- (NSDate*)getFirstDayMonth:(NSInteger)month;
- (NSDate*)getFirstDayInWeekForDate:(NSDate*)day;
- (BOOL)isSameMonthForDate:(NSDate*)date
                  andMonth:(NSInteger)month;
- (BOOL)isToday:(NSDate*)date;
- (NSInteger)dayForDate:(NSDate*)date;
- (NSInteger)yearForDate:(NSDate*)date;

- (NSArray*)eventsForStart:(NSDate*)start
                    forEnd:(NSDate*)end;

- (BOOL)addEventWithTitle:(NSString*)title
                withStart:(NSDate*)start
                  withEnd:(NSDate*)end;

@end
