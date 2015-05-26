//
//  Arguments.m
//  UserLoginLog
//
//  Created by Christer Ulfsparre on 26/05/15.
//  Copyright (c) 2015 Christer Ulfsparre. All rights reserved.
//

#import "Arguments.h"

@implementation Arguments

+ (void)addArgumentsC:(int)c args:(const char *[])args
{
    for(int i = 0; i < c; i++) {
        NSString *arg = [NSString stringWithCString:args[i] encoding:NSUTF8StringEncoding];
        if(i == 0) {
            exePath = arg;
            exePath = [exePath stringByDeletingLastPathComponent];
            exePath = [exePath stringByAppendingString:@"/"];
        }
    }
}

static NSString *exePath = nil;
+ (NSString *)executablePath
{
    return exePath;
}

@end
