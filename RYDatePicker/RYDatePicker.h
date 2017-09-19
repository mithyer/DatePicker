//
//  RYDatePicker.h
//  SudiyiDuty
//
//  Created by ray on 2017/9/18.
//  Copyright © 2017年 sdy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSInteger RYDatePickerComponentsStyle;
extern RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleYearMonthDayHourMinute;
extern RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleMonthDayHourMinute;
extern RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleDayHourMinute;
extern RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleYearMonthDay;
extern RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleMonthDay;
extern RYDatePickerComponentsStyle const kRYDatePickerComponentsStyleHourMinute;

@interface RYDatePicker : UIPickerView

+ (instancetype)pickerWithStyle:(RYDatePickerComponentsStyle)style didConfirmDate:(void (^)(NSDate *date))confirmBlock;
- (void)show;

@property (nonatomic, assign) RYDatePickerComponentsStyle style;
@property (nonatomic, strong) NSDate *minLimitDate;
@property (nonatomic, strong) NSDate *maxLimitDate;
@property (nonatomic, strong) NSDate *selectDate;

@end
