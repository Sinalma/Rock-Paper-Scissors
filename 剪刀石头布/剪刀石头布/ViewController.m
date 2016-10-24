//
//  ViewController.m
//  剪刀石头布
//
//  Created by apple on 16/9/29.
//  Copyright © 2016年 sinalma. All rights reserved.
//

#import "ViewController.h"
/* cache路径 */
#define WZCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
/* 历史数据的保存路径 */
#define WZHistoryCache [WZCachePath stringByAppendingPathComponent:@"historyFactory.plist"]
/* 今日数据保存路径 */
#define WZTodayCache [WZCachePath stringByAppendingPathComponent:@"todayFactory.plist"]

@interface ViewController ()

/** 电脑出拳显示的imageView */
@property (weak, nonatomic) IBOutlet UIImageView *computer;
/** 玩家出拳显示的imageView */
@property (weak, nonatomic) IBOutlet UIImageView *player;
/** 显示胜负的label */
@property (weak, nonatomic) IBOutlet UILabel *notive;
/* 继续游戏的按钮 */
@property (weak, nonatomic) IBOutlet UIButton *continueStart;
/* 请出拳的提示label及显示比赛结果 */
@property (weak, nonatomic) IBOutlet UILabel *please;
/* GCD定时器 */
@property (nonatomic, strong) dispatch_source_t timer;

/* 玩家出拳的按钮 */
@property (weak, nonatomic) IBOutlet UIButton *btn00;
@property (weak, nonatomic) IBOutlet UIButton *btn01;
@property (weak, nonatomic) IBOutlet UIButton *btn02;

/* 显示胜率的label */
@property (weak, nonatomic) IBOutlet UILabel *todayPreFacotry;
@property (weak, nonatomic) IBOutlet UILabel *historyPreFactory;

/* 今日数据 */
@property (nonatomic,assign) CGFloat factoryCount;
@property (nonatomic,assign) CGFloat totalCount;

/* 历史数据 */
@property (nonatomic,assign) CGFloat historyFactoryCount;
@property (nonatomic,assign) CGFloat historyTotalCount;

/* 记录时间 */
@property (nonatomic,assign) NSInteger date;
@end

/**
 *     ***存在的问题***
 * 1. 屏幕适配问题(旋转，屏幕尺寸)
 * 2. 代码冗长，结构不清晰(需要重构)
 *  2.1 关于时间的代码比较多
 *  2.2 判断比较繁琐
 * 3. 存在的BUG:如果程序一直运行至第二日，那么胜率没有清零，或者偶尔会不准确
 * 4. 定时器的处理
 * 5. 取名问题
 */

@implementation ViewController
#pragma mark - 懒加载
- (NSInteger)date
{
    if (!_date) {
        _date = 0;
    }
    return _date;
}

/** 电脑图片计次 */
static int count = 0;

/**
 * 定时器
 */
- (dispatch_source_t)timer
{
    if (_timer == nil) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        
        dispatch_source_set_timer(self.timer, 0, 0.3 * NSEC_PER_SEC, 0);
        
        dispatch_source_set_event_handler(self.timer, ^{
            self.computer.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%zd",count]];
            
            count++;
            if (count == 3) {
                count = 0;
            }
        });
    }
    return _timer;
}

#pragma mark - 程序启动入口
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化设置
    [self setup];
    
    // 加载历史胜率
    [self setupHistoryPreFactory];
    
    // 加载今日胜率
    [self setupTodayPreFactory];
}

#pragma mark - 初始化设置
/**
 * 初始化设置
 */
- (void)setup
{
    // 记录时间
    [self spareTime];
    
    // 开始定时器
    dispatch_resume(self.timer);
    
    // 隐藏继续游戏的按钮
    self.continueStart.hidden = YES;
    
    // 初始化今日数据
    self.factoryCount = 0.0;
    self.totalCount = 0.0;
    
    // 先让请出拳label下移
    [UIView animateWithDuration:0.1 animations:^{
        
        self.please.transform = CGAffineTransformMakeTranslation(0, 45);
    }];
}

/**
 * 加载历史胜率
 */
- (void)setupHistoryPreFactory
{
    // 取出历史胜率
    NSMutableDictionary *dictDown = [NSMutableDictionary dictionaryWithContentsOfFile:WZHistoryCache];
    NSString *fac = [(id)dictDown[@"factoryCount"] lastObject];
    NSString *tot = [(id)dictDown[@"totalCount"] lastObject];
    self.historyFactoryCount = [fac floatValue];
    self.historyTotalCount = [tot floatValue];
    // 显示历史数据
    self.historyPreFactory.text = [NSString stringWithFormat:@"%.1f %%",(self.historyFactoryCount / self.historyTotalCount) * 100];
}

/**
 * 加载今日胜率
 */
- (void)setupTodayPreFactory
{
    // 取出今日胜率
    NSMutableDictionary *todayDictDown = [NSMutableDictionary dictionaryWithContentsOfFile:WZTodayCache];
    NSString *todayFac = [(id)todayDictDown[@"factoryCount"] lastObject];
    NSString *todayTot = [(id)todayDictDown[@"totalCount"] lastObject];
    self.factoryCount = [todayFac floatValue];
    self.totalCount = [todayTot floatValue];
    // 显示今日胜率
    if (self.totalCount) {
        self.todayPreFacotry.text = [NSString stringWithFormat:@"%.1f %%",(self.factoryCount / self.totalCount) * 100];
    }else
    {
        self.todayPreFacotry.text = @"0%";
    }
}

/**
 * 返回电脑随机数
 */
- (int)computerRandomNumber
{
    int number = arc4random_uniform(4);
    
    while (number == 0) {
        number = arc4random_uniform(4);
    }
    return number;
}

#pragma mark - 玩家出拳
- (IBAction)hand00:(UIButton *)button {

    
    [self playerHandwithBtn:button withComputerNumber:[self computerRandomNumber] withPlayerNumber:1];
}

- (IBAction)hand02:(UIButton *)button {
   [self playerHandwithBtn:button withComputerNumber:[self computerRandomNumber] withPlayerNumber:3];
}

- (IBAction)hand03:(UIButton *)button {
    
    [self playerHandwithBtn:button withComputerNumber:[self computerRandomNumber] withPlayerNumber:2];
    
}

#pragma mark - 点击继续游戏
- (IBAction)continueStart:(id)sender {
    
    self.btn00.enabled = YES;
    self.btn01.enabled = YES;
    self.btn02.enabled = YES;
    
    self.continueStart.hidden = YES;
    
    
    [UIView animateWithDuration:0.1 animations:^{
        self.please.text = @"请出拳";
        self.please.textColor = [UIColor blackColor];
        self.please.transform = CGAffineTransformMakeTranslation(0, 45);
    }];
    
    // 玩家未出拳时的占位图片
    self.player.image = [UIImage imageNamed:@"thinkabout"];
    
    // 暂停定时器
    dispatch_resume(self.timer);
}

/*
 * 当玩家出拳后调用
 */
- (void)playerHandwithBtn:(UIButton *)button withComputerNumber:(int)number1 withPlayerNumber:(int)number2
{
    [UIView animateWithDuration:0.1 animations:^{
        self.please.textColor = [UIColor redColor];
        self.please.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    
    
    // 今日总数及历史总数次数加1
    self.totalCount += 1.0;
    self.historyTotalCount += 1.0;
    
    // 取消定时器
    dispatch_cancel(self.timer);
    self.timer = nil;
    
    self.btn00.enabled = NO;
    self.btn01.enabled = NO;
    self.btn02.enabled = NO;
    
    self.player.image = button.imageView.image;
    
    self.continueStart.hidden = NO;
    /**
     * 1 拳头
     * 2 剪刀
     * 3 布
     */
    self.computer.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%zd",number1 - 1]];
    
    // 判断胜负
    switch (number1) {
        case 1:
            switch (number2) {
                case 1:
                    self.please.text = @"平局";
                    break;
                 case 2:
                    self.please.text = @"电脑胜";
                    break;
                 case 3:
                    self.please.text = @"玩家胜";
                    self.factoryCount += 1.0;
                    self.historyFactoryCount += 1.0;
                    break;
            }
            break;
        case 2:
            switch (number2) {
                case 1:
                    self.please.text = @"玩家胜";
                    self.factoryCount += 1.0;
                    self.historyFactoryCount += 1.0;
                    break;
                case 2:
                    self.please.text = @"平局";
                    break;
                case 3:
                    self.please.text = @"电脑胜";
                    break;
            }
            break;
        case 3:
            switch (number2) {
                case 1:
                    self.please.text = @"电脑胜";
                    break;
                case 2:
                    self.please.text = @"玩家胜";
                    self.factoryCount += 1.0;
                    self.historyFactoryCount += 1.0;
                    break;
                case 3:
                    self.please.text = @"平局";
                    break;
            }
            break;
    }
    
    // 刷新胜率
    CGFloat pre = self.factoryCount / self.totalCount;
    self.todayPreFacotry.text = [NSString stringWithFormat:@"%.1f %%",pre * 100];
    self.historyPreFactory.text = [NSString stringWithFormat:@"%.1f %%",(self.historyFactoryCount / self.historyTotalCount) * 100];
    
    // 保存今日数据
    NSMutableDictionary *todayDict = [NSMutableDictionary dictionary];
    todayDict[@"factoryCount"] = @[@(self.factoryCount)];
    todayDict[@"totalCount"] = @[@(self.totalCount)];
    [todayDict writeToFile:WZTodayCache atomically:YES];
    
    // 保存历史数据
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"factoryCount"] = @[@(self.historyFactoryCount)];
    dict[@"totalCount"] = @[@(self.historyTotalCount)];
    [dict writeToFile:WZHistoryCache atomically:YES];
}

#pragma mark - 保存及记录时间的方法
- (void)spareTime
{
    // 时间格式化
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger second = [zone secondsFromGMTForDate:now];
    NSDate *newDate = [now dateByAddingTimeInterval:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yMMdd";
    // 当前所处地区的准确时间
    NSString *date = [formatter stringFromDate:newDate];
    // 记录本次到时间
    NSInteger dateInt = [date integerValue];
    self.date = dateInt;
    
    // 保存到沙盒的时间路径
    NSString *file = [WZCachePath stringByAppendingPathComponent:@"date"];
    
    // 从沙盒中取出保存上次的时间
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithContentsOfFile:file];
    NSString *cacheDate = cacheDict[@"date"];
    NSInteger cacheDateNumber = [cacheDate integerValue];
    
    // 如果本次时间大于沙盒保存的时间
    if (dateInt > cacheDateNumber) {
        // 把今天的记录显示为零
        self.todayPreFacotry.text = @"0";
        
        // 清空今日数据
        NSMutableDictionary *todayDict = [NSMutableDictionary dictionary];
        todayDict[@"factoryCount"] = @[@(0)];
        todayDict[@"totalCount"] = @[@(0)];
        [todayDict writeToFile:WZTodayCache atomically:YES];
    }
    
    // 保存当前时间到沙盒
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"date"] = date;
    [dict writeToFile:file atomically:YES];
}

@end
