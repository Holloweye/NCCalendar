//
//  Arguments.h
//  UserLoginLog
//
//  Created by Christer Ulfsparre on 26/05/15.
//  Copyright (c) 2015 Christer Ulfsparre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Arguments : NSObject

+ (void)addArgumentsC:(int)c args:(const char *[])args;
+ (NSString*)executablePath;

@end
