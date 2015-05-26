//
//  main.m
//  UserLoginLog
//
//  Created by Christer Ulfsparre on 19/05/15.
//  Copyright (c) 2015 Christer Ulfsparre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCMainController.h"
#import "Arguments.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [Arguments addArgumentsC:argc args:argv];
        
        NCMainController *controller = [[NCMainController alloc] init];
        [controller main];
    }
    return 0;
}
