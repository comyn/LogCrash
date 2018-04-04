//
//  DDLogManager.m
//  LogCrash
//
//  Created by comyn on 2018/4/4.
//  Copyright © 2018年 comyn. All rights reserved.
//

#import "DDLogManager.h"
#import <CocoaLumberjack.h>
#import "CatchCrash.h"

/**
 1.DDASLLogger -发送日志语句到苹果的日志系统，它们显示在Console.app上
 2.DDTTYLoyger -发送日志到控制台
 3.DDFIleLoger -发送日志到文件。
 4.DDAbstractDatabaseLogger -发送到DB
 */
/**
 DDLogLevelOff ，关闭所有日志
 DDLogLevelError，只打印error 级别的日志
 DDLogLevelWarning ，打印error，warning级别的日志
 DDLogFlagInfo，打印error，warning，Info级别的日志
 DDLogLevelDebug，打印error，warning，Info，debug级别的日志
 DDLogFlagVerbose,打印error，warning，Info，debug，verbose级别的日志
 DDLogLevelAll，打印所有日志，不知包含上述几种，还有其他级别的日志。
 */
/**
    1、PrefixHeader.pch 必须添加下面代码，如果出错，请引用DDLog头文件
        通过DEBUG模式设置全局日志等级，DEBUG时为Verbose，所有日志信息都可以打印，否则Error，只打印
         //#ifdef DEBUG
         //static DDLogLevel __unused ddLogLevel = DDLogLevelVerbose;
         //#else
         //static DDLogLevel __unused ddLogLevel = DDLogLevelOff;
         //#endif
    2、DDLogError的日志存储 用来存储自定义CatchCrash日志，为防止混淆，Xcode打印日志不建议使用DDLogError
    3、Xcode 打印日志宏定义简写
         #ifdef DEBUG
         #define DLog(format, ...) DDLogVerbose((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
         #else
         #define DLog(...);
         #endif

*/
@interface DDLogManager () <DDLogFormatter>

@property (nonatomic, strong) DDFileLogger *fileLogger;
@end
@implementation DDLogManager
/**
 *  初始化
 *
 *  @return 日志系统管理器对象
 */
+ (instancetype)shareInstance {
    static DDLogManager *logmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logmanager = [[self alloc] init];
    });
    return logmanager;
}

-(instancetype)init {
    self = [super init];
    if (self)
    {
        //注册消息处理函数的处理方法
        //如此一来，程序崩溃时会自动进入CatchCrash.m的uncaughtExceptionHandler()方法
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        
        self.fileLogger = [[DDFileLogger alloc] init];
        self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        self.fileLogger.maximumFileSize = 1024 * 1024 * 2;
    }
    return self;
}

#pragma mark - 配置日志信息

- (void)setConfig {
    //1.发送日志语句到苹果的日志系统，它们显示在Console.app上,针对Mac开发
    //    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
    //    [DDLog addLogger:[DDASLLogger sharedInstance]];//
    
    //2.把输出日志写到文件中
    DDFileLogger *fileLogger = [DDLogManager shareInstance].fileLogger;
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];//错误的写到文件中
    [fileLogger setLogFormatter:[DDLogManager shareInstance]];

    //3.初始化DDLog日志输出，在这里，我们仅仅希望在xCode控制台输出
    /** xcode 8 已失效
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:DDMakeColor(255, 255, 255) backgroundColor:DDMakeColor(255, 0, 0) forFlag:DDLogFlagError];//错误信息为红白
    [[DDTTYLogger sharedInstance] setForegroundColor:DDMakeColor(255, 255, 0) backgroundColor:DDMakeColor(0, 0, 0) forFlag:DDLogFlagWarning];//警告为黑黄
    [[DDTTYLogger sharedInstance] setForegroundColor:DDMakeColor(255, 255, 255) backgroundColor:DDMakeColor(0, 0, 255) forFlag:DDLogFlagInfo];//信息为蓝白
    [[DDTTYLogger sharedInstance] setForegroundColor:DDMakeColor(255, 97, 0) backgroundColor:DDMakeColor(0, 0, 0) forFlag:DDLogFlagDebug];//调试为黑橙
    [[DDTTYLogger sharedInstance] setForegroundColor:DDMakeColor(0, 255, 0) backgroundColor:DDMakeColor(0, 0, 0) forFlag:DDLogFlagVerbose];//详细信息为黑绿
    */
    [DDLog addLogger:[DDTTYLogger sharedInstance]];//
//    [[DDTTYLogger sharedInstance] setLogFormatter:[DDLogManager shareInstance]];

    //4.添加数据库输出
    //    DDAbstractLogger *dateBaseLogger = [[DDAbstractLogger alloc] init];
    //    [dateBaseLogger setLogFormatter:logFormatter];
    //    [DDLog addLogger:dateBaseLogger];
    
}

#pragma mark - DDLogFormatter协议方法 自定义日志格式

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel = nil;
    switch (logMessage.flag)
    {
        case DDLogFlagError:
        {
            logLevel = @"ERROR";//@"[ERROR]->";
        }
            break;
        case DDLogFlagWarning:
        {
            logLevel = @"WARN";
        }
            break;
        case DDLogFlagInfo:
        {
            logLevel = @"INFO";
        }
            break;
        case DDLogFlagDebug:
        {
            logLevel = @"DEBUG";
        }
            break;
        case DDLogFlagVerbose:
        {
            logLevel = @"VBOSE";
        }
            break;
            
        default:
            logLevel = @"VBOSE";
            break;
    }
    NSString *formatStr = [NSString stringWithFormat:@"[日志类型:%@] [日期:%@] [文件名:%@] [函数名:%@] [行号:%ld] [内容:%@]", logLevel, logMessage.timestamp, logMessage.file, logMessage.function, logMessage.line, logMessage.message];

    return formatStr;
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    DDFileLogger *fileLogger = (DDFileLogger *)logger.description;
//    NSLog(@"1=%@",fileLogger.loggerName);
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {

}

# pragma mark -- 自定义Crash文件上传，DDLog不会保存Crash文件，需自行处理

- (void)uploadCrashFile {
    //若crash文件存在，则写入log并上传，然后删掉crash文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];
    
    if ([fileManager fileExistsAtPath:errorLogPath]) {
        //用CocoaLumberJack库的fileLogger.logFileManager自带的方法创建一个新的Log文件，这样才能获取到对应文件夹下排序的Log文件
        [self.fileLogger.logFileManager createNewLogFile];
        //此处必须用firstObject而不能用lastObject，因为是按照日期逆序排列的，即最新的Log文件排在前面
        NSString *newLogFilePath = [self.fileLogger.logFileManager sortedLogFilePaths].firstObject;
        NSError *error = nil;
        NSString *errorLogContent = [NSString stringWithContentsOfFile:errorLogPath encoding:NSUTF8StringEncoding error:nil];
        BOOL isSuccess = [errorLogContent writeToFile:newLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (!isSuccess) {
            DDLogError(@"crash文件写入log失败: %@", error.userInfo);
        } else {
            DDLogError(@"crash文件写入log成功");
            NSError *error = nil;
            BOOL isSuccess = [fileManager removeItemAtPath:errorLogPath error:&error];
            if (!isSuccess) {
                DDLogError(@"删除本地的crash文件失败: %@", error.userInfo);
            }
        }
        
        //上传最近的3个log文件，
        //至少要3个，因为最后一个是crash的记录信息，另外2个是防止其中后一个文件只写了几行代码而不够分析
        NSArray *logFilePaths = [self.fileLogger.logFileManager sortedLogFilePaths];
        NSUInteger logCounts = logFilePaths.count;
        if (logCounts >= 3) {
            for (NSUInteger i = 0; i < 3; i++) {
                NSString *logFilePath = logFilePaths[i];
                //上传服务器
                NSString *str = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
                NSLog(@"str=%@",str);
            }
        } else {
            for (NSUInteger i = 0; i < logCounts; i++) {
                NSString *logFilePath = logFilePaths[i];
                //上传服务器
                NSString *str = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
                NSLog(@"str=%@",str);
            }
        }
    }
}
@end
