//
//  Common.h
//  LogCrash
//
//  Created by comyn on 2018/4/4.
//  Copyright © 2018年 comyn. All rights reserved.
//

#ifndef Common_h
#define Common_h

//通过DEBUG模式设置全局日志等级，DEBUG时为Verbose，所有日志信息都可以打印，否则Error，只打印

#ifdef DEBUG
static DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

#ifdef DEBUG
#define DLog(format, ...) DDLogVerbose((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...);
#endif

#endif /* Common_h */

