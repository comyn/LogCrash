//
//  CatchCrash.h
//  Test
//
//  Created by comyn on 2018/4/4.
//  Copyright © 2018年 comyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatchCrash : NSObject
void uncaughtExceptionHandler(NSException *exception);

@end
