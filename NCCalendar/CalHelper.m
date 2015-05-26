//
//  CalHelper.m
//  UserLoginLog
//
//  Created by Christer Ulfsparre on 25/05/15.
//  Copyright (c) 2015 Christer Ulfsparre. All rights reserved.
//

#import "CalHelper.h"
#import "Logger.h"

@interface CalHelper ()
{
    NSDate *_now;
    NSCalendar *_cal;
    EKEventStore *_store;
}
@end

@implementation CalHelper

- (instancetype)init
{
    self = [super init];
    if(self) {
        _now = [NSDate date];
        _cal = [NSCalendar currentCalendar];
        [_cal setFirstWeekday:2];
        
        _store = [[EKEventStore alloc] init];
    }
    return self;
}

- (void)requestCalendarAccessWithSuccess:(void (^)(void))success
                              withFailed:(void (^)(NSError *))failed
{
    [_store requestAccessToEntityType:EKEntityTypeEvent
                           completion:^(BOOL granted, NSError *error) {
                               if(granted) {
                                   if(success) {
                                       success();
                                   }
                               } else if(failed){
                                   failed(error);
                               }
                           }];
}

- (NSUInteger)getCurrentMonth
{
    return [_cal ordinalityOfUnit:NSCalendarUnitMonth
                           inUnit:NSCalendarUnitYear
                          forDate:_now];
}

- (NSDate*)getFirstDayMonth:(NSInteger)month
{
    NSDateComponents *components = [_cal components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
                                           fromDate:_now];
    components.month = month;
    components.day = 1;
    return [_cal dateFromComponents:components];
}

- (NSDate*)getFirstDayInWeekForDate:(NSDate*)day
{
    NSDate *startOfTheWeek;
    NSTimeInterval interval;
    [_cal rangeOfUnit:NSCalendarUnitWeekOfYear
            startDate:&startOfTheWeek
             interval:&interval
              forDate:day];
    return startOfTheWeek;
}

- (BOOL)isSameMonthForDate:(NSDate *)date
                  andMonth:(NSInteger)month
{
    NSDateComponents *components = [_cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                           fromDate:date];
    return components.month % 12 == month % 12;
}

- (BOOL)isToday:(NSDate *)date
{
    return [_cal isDateInToday:date];
}

- (NSInteger)dayForDate:(NSDate *)date
{
    NSDateComponents *components = [_cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                           fromDate:date];
    return components.day;
}

- (NSInteger)yearForDate:(NSDate *)date
{
    NSDateComponents *components = [_cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                           fromDate:date];
    return components.year;
}

- (NSArray*)eventsForStart:(NSDate*)start
                    forEnd:(NSDate*)end
{
    return [_store eventsMatchingPredicate:[_store predicateForEventsWithStartDate:start
                                                                           endDate:end
                                                                         calendars:nil]];
}

- (BOOL)addEventWithTitle:(NSString*)title
                withStart:(NSDate*)start
                  withEnd:(NSDate*)end
{
    EKEvent *event = [EKEvent eventWithEventStore:_store];
    [event setTitle:@"Test"];
    [event setStartDate:[[NSDate date] dateByAddingTimeInterval:86400]];
    [event setEndDate:[[NSDate date] dateByAddingTimeInterval:86400 + 60]];
    [event setCalendar:[_store defaultCalendarForNewEvents]];
    
    NSError *error = nil;
    [_store saveEvent:event
                 span:EKSpanThisEvent
               commit:YES
                error:&error];
    [Logger log:[NSString stringWithFormat:@"addEvent:%@",error]];
    return !error;
}

@end
