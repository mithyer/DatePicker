//
//  RYDatePicker.m
//  SudiyiDuty
//
//  Created by ray on 2017/9/18.
//  Copyright © 2017年 sdy. All rights reserved.
//

#import "RYDatePicker.h"
#import "NSDate+RYExtension.h"

typedef NS_OPTIONS(NSInteger, RYDatePickerComponentsOption) {
    kRYDatePickerComponentsOptionYear = 1,
    kRYDatePickerComponentsOptionMonth = 1 << 1,
    kRYDatePickerComponentsOptionDay = 1 << 2,
    kRYDatePickerComponentsOptionHour = 1 << 3,
    kRYDatePickerComponentsOptionMinute = 1 << 4,
    
    RYDatePickerComponentsOptionCount = 5
};

static NSInteger const kAllDateOptions[] = {
    kRYDatePickerComponentsOptionYear,
    kRYDatePickerComponentsOptionMonth,
    kRYDatePickerComponentsOptionDay,
    kRYDatePickerComponentsOptionHour,
    kRYDatePickerComponentsOptionMinute,
};

RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleYearMonthDayHourMinute = kRYDatePickerComponentsOptionYear | kRYDatePickerComponentsOptionMonth | kRYDatePickerComponentsOptionDay | kRYDatePickerComponentsOptionHour | kRYDatePickerComponentsOptionMinute;
RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleMonthDayHourMinute = kRYDatePickerComponentsOptionMonth | kRYDatePickerComponentsOptionDay | kRYDatePickerComponentsOptionHour | kRYDatePickerComponentsOptionMinute;;
RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleDayHourMinute = kRYDatePickerComponentsOptionDay | kRYDatePickerComponentsOptionHour | kRYDatePickerComponentsOptionMinute;
RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleYearMonthDay = kRYDatePickerComponentsOptionYear | kRYDatePickerComponentsOptionMonth | kRYDatePickerComponentsOptionDay;
RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleMonthDay = kRYDatePickerComponentsOptionMonth | kRYDatePickerComponentsOptionDay;
RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleHourMinute = kRYDatePickerComponentsOptionHour | kRYDatePickerComponentsOptionMinute;


static CGFloat const kConfirmBtnHeight = 50;

@interface RYDatePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) BOOL needReload;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<NSNumber *> *> *optionToUnitDic;
@property (nonatomic, copy) void (^confirmBlock)(NSDate *date);

@end


@implementation RYDatePicker {
    @private
    NSDate *_selectDate;
    NSDate *_minLimitDate;
    NSDate *_maxLimitDate;
    NSMutableArray<NSNumber *> *_optionArray;
}

+ (instancetype)pickerWithStyle:(RYDatePickerComponentsStyle)style didConfirmDate:(void (^)(NSDate *date))confirmBlock {
    CGRect windowBounds = UIApplication.sharedApplication.keyWindow.bounds;
    CGFloat pickerHeight = CGRectGetHeight(windowBounds) * 0.4;
    return [[self alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(windowBounds) - pickerHeight - kConfirmBtnHeight, CGRectGetWidth(windowBounds), pickerHeight) style:style confirmBlock:confirmBlock];
}

- (void)show {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    if (self.superview.superview == keyWindow) {
        return;
    }
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [container addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];

    container.frame = keyWindow.bounds;
    [container addSubview:self];
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    confirmBtn.layer.borderWidth = .5f;
    confirmBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [confirmBtn setBackgroundColor:[UIColor whiteColor]];
    [confirmBtn addTarget:self action:@selector(didConfirm:) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.frame = CGRectMake(0, CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), kConfirmBtnHeight);
    [container addSubview:confirmBtn];
    
    [keyWindow addSubview:container];
}

- (void)dismiss {
    [self.superview removeFromSuperview];
}

- (void)didConfirm:(id)sender {
    if (nil != _confirmBlock) {
        _confirmBlock(_selectDate);
    }
    [self dismiss];
}

- (instancetype)initWithFrame:(CGRect)frame style:(RYDatePickerComponentsStyle)style confirmBlock:(void (^)(NSDate *date))confirmBlock {
    if (self = [super initWithFrame:frame]) {
        self.style = style;
        self.backgroundColor = UIColor.whiteColor;
        self.delegate = self;
        self.dataSource = self;
        _confirmBlock = confirmBlock;
        [self setNeedReload];
    }
    return self;
}

- (NSDate *)minLimitDate {
    if (nil == _minLimitDate) {
        _minLimitDate = [NSDate dateWithStr:@"1900-01-01 00:00" format:@"yyyy-MM-dd HH:mm"];
    }
    return _minLimitDate;
}

- (void)setMinLimitDate:(NSDate *)minLimitDate {
    if (nil == _minLimitDate || ![_minLimitDate isEqualToDate:_minLimitDate]) {
        _minLimitDate = minLimitDate;
        [self setNeedReload];
    }
    NSParameterAssert(nil == _minLimitDate || nil == _maxLimitDate || [_minLimitDate isEarlierThanDate:_maxLimitDate]);
}

- (NSDate *)maxLimitDate {
    if (nil == _maxLimitDate) {
        _maxLimitDate = [NSDate dateWithStr:@"2099-12-31 23:59" format:@"yyyy-MM-dd HH:mm"];
    }
    return _maxLimitDate;
}

- (void)setMaxLimitDate:(NSDate *)maxLimitDate {
    if (nil == _maxLimitDate || ![_maxLimitDate isEqualToDate:maxLimitDate]) {
        _maxLimitDate = maxLimitDate;
        [self setNeedReload];
    }
    NSParameterAssert(nil == _minLimitDate || nil == _maxLimitDate || [_minLimitDate isEarlierThanDate:_maxLimitDate]);
}

- (void)setSelectDate:(NSDate *)selectDate {
    if (nil == _selectDate || ![_selectDate isEqualToDate:selectDate]) {
        _selectDate = selectDate;
        [self setNeedReload];
    }
}

- (NSDate *)selectDate {
    if (nil == _selectDate) {
        _selectDate = NSDate.date;
    }
    if ([_selectDate isEarlierThanDate:self.minLimitDate]) {
        _selectDate = _minLimitDate;
    } else if ([_selectDate isLaterThanDate:self.maxLimitDate]) {
        _selectDate = _maxLimitDate;
    }
    return _selectDate;
}

- (void)setStyle:(RYDatePickerComponentsStyle)style {
    if (_style != style) {
        _style = style;
        
        [_optionArray removeAllObjects];
        if (nil == _optionArray) {
            _optionArray = [NSMutableArray array];
        }
        for (NSInteger i = 0; i < RYDatePickerComponentsOptionCount; ++i) {
            NSInteger option = kAllDateOptions[i];
            if ((option & _style) == option) {
                [_optionArray addObject:@(option)];
            }
        }
        [self setNeedReload];
    }
}

- (NSArray<NSNumber *> *)optionArray {
    return _optionArray;
}

- (NSMutableArray<NSNumber *> *)unitArrayForOption:(RYDatePickerComponentsOption)option {
    NSMutableArray<NSNumber *> *array = _optionToUnitDic[@(option)];
    if (nil == array) {
        array = [NSMutableArray array];
        if (nil == _optionToUnitDic) {
            _optionToUnitDic = [NSMutableDictionary dictionary];
        }
        _optionToUnitDic[@(option)] = array;
    }
    return array;
}

- (void)setNeedReload {
    _needReload = YES;
    [self reload];
}

- (void)reload {
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil == wSelf || !wSelf.needReload) {
            return;
        }
        wSelf.needReload = NO;

        NSDate *date = wSelf.selectDate;

        NSMutableArray *yearArray = [wSelf unitArrayForOption:kRYDatePickerComponentsOptionYear];
        NSMutableArray *monthArray = [wSelf unitArrayForOption:kRYDatePickerComponentsOptionMonth];
        NSMutableArray *dayArray = [wSelf unitArrayForOption:kRYDatePickerComponentsOptionDay];
        NSMutableArray *hourArray = [wSelf unitArrayForOption:kRYDatePickerComponentsOptionHour];
        NSMutableArray *minuteArray = [wSelf unitArrayForOption:kRYDatePickerComponentsOptionMinute];
        [yearArray removeAllObjects];
        [monthArray removeAllObjects];
        [dayArray removeAllObjects];
        [hourArray removeAllObjects];
        [minuteArray removeAllObjects];
        
        NSInteger minYear = wSelf.minLimitDate.year;
        NSInteger maxYear = wSelf.maxLimitDate.year;
        for (NSInteger i = minYear; i <= maxYear; ++i) {
            [yearArray addObject:@(i)];
        }
        
        NSInteger minMonth = 1;
        NSInteger minDay = 1;
        NSInteger minHour = 0;
        NSInteger minMinute = 0;
        if (date.year == minYear) {
            minMonth = wSelf.minLimitDate.month;
            if (date.month == minMonth) {
                minDay = wSelf.minLimitDate.day;
                if (date.day == minDay) {
                    minHour = wSelf.minLimitDate.hour;
                    if (date.hour == minHour) {
                        minMinute = wSelf.minLimitDate.minute;
                    }
                }
            }
        }
        NSInteger maxMonth = 12;
        NSCalendar *c = [NSCalendar currentCalendar];
        NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                               inUnit:NSCalendarUnitMonth
                              forDate:date];
        NSInteger maxDay = days.length;
        NSInteger maxHour = 23;
        NSInteger maxMinute = 59;
        if (date.year == maxYear) {
            maxMonth = wSelf.maxLimitDate.month;
            if (date.month == maxMonth) {
                maxDay = wSelf.maxLimitDate.day;
                if (date.day == maxDay) {
                    maxHour = wSelf.maxLimitDate.hour;
                    if (date.hour == maxHour) {
                        maxMinute = wSelf.maxLimitDate.minute;
                    }
                }
            }
        }
        
        for (NSInteger i = minMonth; i <= maxMonth; ++i) {
            [monthArray addObject:@(i)];
        }
        for (NSInteger i = minDay; i <= maxDay; ++i) {
            [dayArray addObject:@(i)];
        }
        for (NSInteger i = minHour; i <= maxHour; ++i) {
            [hourArray addObject:@(i)];
        }
        for (NSInteger i = minMinute; i <= maxMinute; ++i) {
            [minuteArray addObject:@(i)];
        }
        
        [wSelf reloadAllComponents];
        
        for (NSInteger i = 0; i < wSelf.optionArray.count; ++i) {
            RYDatePickerComponentsOption option = self.optionArray[i].integerValue;
            NSArray *arry = [self unitArrayForOption:option];
            switch (option) {
                case kRYDatePickerComponentsOptionYear: {
                    [wSelf selectRow:[arry indexOfObject:@(date.year)] inComponent:i animated:NO];
                }
                    break;
                case kRYDatePickerComponentsOptionMonth: {
                    [wSelf selectRow:[arry indexOfObject:@(date.month)] inComponent:i animated:NO];
                }
                    break;
                case kRYDatePickerComponentsOptionDay: {
                    [wSelf selectRow:[arry indexOfObject:@(date.day)] inComponent:i animated:NO];
                }
                    break;
                case kRYDatePickerComponentsOptionHour: {
                    [wSelf selectRow:[arry indexOfObject:@(date.hour)] inComponent:i animated:NO];
                }
                    break;
                case kRYDatePickerComponentsOptionMinute: {
                    [wSelf selectRow:[arry indexOfObject:@(date.minute)] inComponent:i animated:NO];
                }
                    break;
                default:
                    break;
            }
        }
    });

    
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.optionArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self unitArrayForOption:self.optionArray[component].integerValue].count;
}


#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    
    UILabel *label = (UILabel *)view ?: ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    RYDatePickerComponentsOption option = self.optionArray[component].integerValue;
    
    NSString *suffix = nil;
    switch (option) {
        case kRYDatePickerComponentsOptionYear:
            suffix = @"年";
            break;
        case kRYDatePickerComponentsOptionMonth:
            suffix = @"月";
            break;
        case kRYDatePickerComponentsOptionDay:
            suffix = @"日";
            break;
        case kRYDatePickerComponentsOptionHour:
            suffix = @"时";
            break;
        case kRYDatePickerComponentsOptionMinute:
            suffix = @"分";
            break;
        default:
            break;
    }
    NSArray *arry = [self unitArrayForOption:option];
    label.text = [NSString stringWithFormat:@"%@%@", arry[row], suffix];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger year = _selectDate.year;
    NSInteger month = _selectDate.month;
    NSInteger day = _selectDate.day;
    NSInteger hour = _selectDate.hour;
    NSInteger minute = _selectDate.minute;
    RYDatePickerComponentsOption option = self.optionArray[component].integerValue;
    NSInteger num = [self unitArrayForOption:option][row].integerValue;
    switch (option) {
        case kRYDatePickerComponentsOptionYear:
            year = num;
            break;
        case kRYDatePickerComponentsOptionMonth:
            month = num;
            break;
        case kRYDatePickerComponentsOptionDay:
            day = num;
            break;
        case kRYDatePickerComponentsOptionHour:
            hour = num;
            break;
        case kRYDatePickerComponentsOptionMinute:
            minute = num;
            break;
        default:
            break;
    }
    NSDate *date = [NSDate dateWithStr:[NSString stringWithFormat:@"%zd-%zd-01 00:00", year, month] format:@"yyyy-MM-dd HH:mm"];
    NSRange days = [NSCalendar.currentCalendar rangeOfUnit:NSCalendarUnitDay
                                                    inUnit:NSCalendarUnitMonth
                                                   forDate:date];
    self.selectDate = [NSDate dateWithStr:[NSString stringWithFormat:@"%zd-%zd-%zd %zd:%zd", year, month, MIN(day, days.length), hour, minute] format:@"yyyy-MM-dd HH:mm"];
}

@end
