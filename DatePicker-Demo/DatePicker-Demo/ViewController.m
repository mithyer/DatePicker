//
//  ViewController.m
//  DatePicker-Demo
//
//  Created by ray on 2017/11/15.
//  Copyright © 2017年 ray. All rights reserved.
//

#import "ViewController.h"
#import "RYDatePicker.h"

@interface ViewController ()

@property (nonatomic, strong) RYDatePicker *datePicker;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *switchStyleBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIButton *)switchStyleBtn {
    if (nil == _switchStyleBtn) {
        _switchStyleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_switchStyleBtn setTitle:@"点这里换样式" forState:UIControlStateNormal];
        [_switchStyleBtn setBackgroundColor:[UIColor lightGrayColor]];
        _switchStyleBtn.frame = CGRectMake(0, 50, 0, 0);
        [_switchStyleBtn sizeToFit];
        [self.view insertSubview:_switchStyleBtn aboveSubview:self.dateLabel];
        [_switchStyleBtn addTarget:self action:@selector(swithBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchStyleBtn;
}

- (void)swithBtnTapped {
    static NSArray *styleList = nil;
    if (nil == styleList) {
        styleList = @[@(kRYDatePickerComponentsStyleHourMinute),
                      @(kRYDatePickerComponentsStyleMonthDayHourMinute),
                      @(kRYDatePickerComponentsStyleDayHourMinute),
                      @(kRYDatePickerComponentsStyleYearMonthDay),
                      @(kRYDatePickerComponentsStyleMonthDay),
                      @(kRYDatePickerComponentsStyleHourMinute)];
    }
    RYDatePickerComponentsStyle nextStyle = [styleList[([styleList indexOfObject:@(self.datePicker.style)] + 1)%styleList.count] integerValue];
    self.datePicker.style = nextStyle;
    [self.datePicker show];
}

- (UILabel *)dateLabel {
    if (nil == _dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:20];
        _dateLabel.frame = self.view.bounds;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (RYDatePicker *)datePicker {
    if (nil == _datePicker) {
        __weak typeof(self) wSelf = self;
        _datePicker = [RYDatePicker pickerWithStyle:kRYDatePickerComponentsStyleMonthDay didConfirmDate:^(NSDate *date) {
            wSelf.dateLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle];
        }];
    }
    return _datePicker;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.datePicker show];
    [self dateLabel];
    [self switchStyleBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
