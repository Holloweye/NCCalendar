//
//  NCMainController.m
//  UserLoginLog
//
//  Created by Christer Ulfsparre on 20/05/15.
//  Copyright (c) 2015 Christer Ulfsparre. All rights reserved.
//

#import "NCMainController.h"
#import "Arguments.h"
#import "NCCursesPlatform.h"
#import "NCDummyPlatform.h"
#import "NCRendition.h"
#import "NCLayoutInflator.h"
#import "NCScrollDecorator.h"

#import "NCLinearLayout.h"
#import "NCText.h"
#import "NCKey.h"

#import "CalHelper.h"
#import "Logger.h"

@interface NCMainController ()
@property (nonatomic, strong) CalHelper *cal;
@end

@implementation NCMainController

- (void)main
{
    self.cal = [[CalHelper alloc] init];
    [self.cal requestCalendarAccessWithSuccess:^{
    } withFailed:^(NSError *error) {
    }];
    
    NSString *exePath = [Arguments executablePath];
    NSData *mainXML = [NSData dataWithContentsOfFile:[exePath stringByAppendingPathComponent:@"/main.xml"]];
    NSData *monthXML = [NSData dataWithContentsOfFile:[exePath stringByAppendingPathComponent:@"/month.xml"]];
    
    NCGraphic *root = [NCLayoutInflator inflateGraphicFromXML:mainXML];
    NCScrollDecorator *scroll = (NCScrollDecorator*)[root findGraphicWithId:@"scroll"];
    
    NSArray *events = [self.cal eventsForStart:[NSDate date]
                                        forEnd:[[NSDate date] dateByAddingTimeInterval:86400*30*12]];
    
    [self updateEventsDisplay:(NCLinearLayout*)[root findGraphicWithId:@"events"]
                   withEvents:events];
    
    NSArray *months = @[[NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML],
                        [NCLayoutInflator inflateGraphicFromXML:monthXML]];
    
    NSArray *rows = @[[root findGraphicWithId:@"1"],
                      [root findGraphicWithId:@"2"],
                      [root findGraphicWithId:@"3"],
                      [root findGraphicWithId:@"4"],
                      [root findGraphicWithId:@"5"],
                      [root findGraphicWithId:@"6"],
                      [root findGraphicWithId:@"7"],
                      [root findGraphicWithId:@"8"],
                      [root findGraphicWithId:@"9"],
                      [root findGraphicWithId:@"10"],
                      [root findGraphicWithId:@"11"],
                      [root findGraphicWithId:@"12"],];
    
    for(int i = 0; i < months.count; i++) {
        [self updateMonthDisplay:[months objectAtIndex:i]
                       withMonth:[self.cal getCurrentMonth] + i
                      withEvents:events];
    }
    
    const NSUInteger monthWidth = [[months objectAtIndex:0] sizeWithinBounds:CGSizeMake(NSIntegerMax, NSIntegerMax)].width;

    while(true) {
        const CGSize screenSize = [[NCCursesPlatform factory] screenSize];
        const NSUInteger monthsAreaWidth = [scroll sizeWithinBounds:screenSize].width;
        
        // Clear children
        for(NCCanvas *graphic in rows) {
            [graphic removeAllChildren];
        }
        
        NSUInteger m = 0;
        NSUInteger row = 0;
        NSUInteger w = 0;
        while(m < months.count) {
            [[rows objectAtIndex:row] addChild:[months objectAtIndex:m++]];
            w += monthWidth;
            if(w + monthWidth >= monthsAreaWidth) {
                w = 0;
                row++;
            }
        }
        
        NCRendition *rendition = [root drawInBounds:screenSize
                                       withPlatform:[NCCursesPlatform factory]];
        [rendition drawToScreen];
        
        NCKey *key = [[NCCursesPlatform factory] getKey];
        if([key isEqualTo:[NCKey NCKEY_q]]) {
            break;
        } else if([key isEqualTo:[NCKey NCKEY_ARROW_UP]]) {
            [scroll setOffset:CGSizeMake(scroll.offset.width, scroll.offset.height+8)];
        } else if([key isEqualTo:[NCKey NCKEY_ARROW_DOWN]]) {
            [scroll setOffset:CGSizeMake(scroll.offset.width, scroll.offset.height-8)];
        }
    }
}

- (void)updateEventsDisplay:(NCGraphic*)eventsLinearLayout
                 withEvents:(NSArray*)events
{
    NSString *exePath = [Arguments executablePath];
    NSData *eventXML = [NSData dataWithContentsOfFile:[exePath stringByAppendingPathComponent:@"/event.xml"]];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    
    for(EKEvent *event in events) {
        NCGraphic *eventGraphic = [NCLayoutInflator inflateGraphicFromXML:eventXML];
        NCText *titleText = (NCText*)[eventGraphic findGraphicWithId:@"title"];
        NCText *timeText = (NCText*)[eventGraphic findGraphicWithId:@"time"];
        
        NSString *titleStr = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:event.startDate],event.title];
        [titleText setText:[[NCString alloc] initWithText:titleStr
                                           withBackground:[NCColor blackColor]
                                           withForeground:[NCColor greenColor]]];
        
        NSString *timeStr = [NSString stringWithFormat:@"%@ - %@",[timeFormatter stringFromDate:event.startDate],[timeFormatter stringFromDate:event.endDate]];
        [timeText setText:[[NCString alloc] initWithText:timeStr
                                          withBackground:[NCColor blackColor]
                                          withForeground:[NCColor greenColor]]];
        
        [eventsLinearLayout addChild:eventGraphic];
    }
}

- (void)updateMonthDisplay:(NCGraphic*)month
                 withMonth:(NSInteger)m
                withEvents:(NSArray*)events
{
    NSDate *firstDayInMonth = [self.cal getFirstDayMonth:m];
    NSDate *firstDay = [self.cal getFirstDayInWeekForDate:firstDayInMonth];
    
    NSArray *columns = @[[month findGraphicWithId:@"moColumn"],
                         [month findGraphicWithId:@"tuColumn"],
                         [month findGraphicWithId:@"weColumn"],
                         [month findGraphicWithId:@"thColumn"],
                         [month findGraphicWithId:@"frColumn"],
                         [month findGraphicWithId:@"saColumn"],
                         [month findGraphicWithId:@"suColumn"]];
    
    for(int w = 0; w < 6; w++) {
        for(int d = 0; d < 7; d++) {
            NSDate *day = [firstDay dateByAddingTimeInterval:w*86400*7 + d*86400];
            
            NCGraphic *column = [columns objectAtIndex:d];
            NCText *dayText = [[column getCanvas].children objectAtIndex:w+1];
            
            BOOL isCurrentMonth = [self.cal isSameMonthForDate:day
                                                      andMonth:m];
            BOOL isToday = [self.cal isToday:day];
            BOOL isEvent = NO;
            for(EKEvent *event in events) {
                if([self isDate:event.startDate
                    betweenDate:day
                        andDate:[day dateByAddingTimeInterval:86400]]) {
                    isEvent = YES;
                    break;
                }
            }
            
            NCColor *background = nil;
            NCColor *foreground = nil;
            if(isToday) {
                background = [NCColor blueColor];
                foreground = [NCColor whiteColor];
            } else if(isEvent) {
                background = [NCColor blackColor];
                foreground = [NCColor greenColor];
            } else if(isCurrentMonth) {
                background = [NCColor blackColor];
                foreground = [NCColor whiteColor];
            } else {
                background = [NCColor blackColor];
                foreground = [NCColor redColor];
            }
            [dayText setText:[[NCString alloc] initWithText:[NSString stringWithFormat:@"%li",(long)[self.cal dayForDate:day]]
                                             withBackground:background
                                             withForeground:foreground]];
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    
    NCText *monthText = (NCText*)[month findGraphicWithId:@"monthText"];
    [monthText setText:[[NCString alloc] initWithText:[NSString stringWithFormat:@"%@ (%li)", [formatter stringFromDate:firstDayInMonth],(long)[self.cal yearForDate:firstDayInMonth]]
                                       withBackground:[NCColor blackColor]
                                       withForeground:[NCColor whiteColor]]];
}

- (BOOL)isDate:(NSDate*)date
   betweenDate:(NSDate *)earlierDate
       andDate:(NSDate *)laterDate
{
    NSComparisonResult result = [date compare:earlierDate];
    if (result == NSOrderedDescending || result == NSOrderedSame) {
        result = [date compare:laterDate];
        if (result == NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
}

@end
