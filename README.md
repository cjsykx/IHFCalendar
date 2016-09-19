# IHFCalendar
一个简单，实用的日历控件

IHFCalendar 可以弹出一个简单，实用的日历！
****
类方法直接弹出：
****

```
[IHFCalendar showCalendarWithCurrentDate:[NSDate date]];
```
弹出的选择时间为今天。默认加的View的屏幕最前面的View和默认尺寸。

在iPhone 和 iPad 上弹出的尺寸 不一样 。如果要修改弹出的 尺寸和位置，调用方法如下
```
+ (instancetype)showCalendarWithFrame:(CGRect)frame currentDate:(NSDate *)date;
```

如果要加在你想要的View上 ， 调用 
```
+ (instancetype)showCalendarWithFrame:(CGRect)frame inView:(UIView *)view currentDate:(NSDate *)date;
```
如果你没有加上你的View上的话 ，可以直接使用下面代码消失
```
+ (void)hideCalendar;
```

但是如果你设置了，就调用
```
+ (void)hideCalendarInView:(UIView *)view;
```

> 使用类方法总结： 一共有三个参数currentDate，view 和 frame . 基本上一个参数currentDate是必须的，后面2个参数View可以不用设置简单的弹出你的日历。

****
实例方法弹出
****
实例方法是为了得到Calendar， 然后对Calendar进行外观上的设置。 用了IHFAppearence 直接对Calendar的外观进行设置。

```
IHFCalendar *calendar = [IHFCalendar calendar];
calendar.appearence.headerTitleColor = [UIColor redColor];
[calendar show];
```

####代理：####
```
- (void)calendar:(IHFCalendar *)calendar didSelectedDate:(NSDate *)date;
```
响应用户点击某个日期


简书地址  : http://www.jianshu.com/p/ba8a6b275221