//
//  IHFCalendarHeaderView.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/23.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHFCalendarAppearence.h"
@class IHFCalendarHeaderView;
@protocol IHFCalendarHeaderViewDelegate <NSObject>

@optional
/**
 Tell delegate left or right btn did click!
 
 @sender : left or right button
 @tips : If may tell delegate user want to change month!
 */
- (void) calendarHeaderView:(IHFCalendarHeaderView *)HeaderView didClickButton:(UIButton *)sender;
@end

@interface IHFCalendarHeaderView : UIView

@property (copy, nonatomic) NSString *dateText;

@property (weak, nonatomic) id <IHFCalendarHeaderViewDelegate> delegate;

@property (weak, nonatomic) IHFCalendarAppearence *appearence;

@end
