//
//  UIImage+IHF.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/23.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, IHFImageDirection)
{
    IHFImageDirectionTop    = 0,
    IHFImageDirectionBottom = 1,
    IHFImageDirectionLeft   = 2,
    IHFImageDirectionRight  = 3,
    
    
    IHFImageDirectionTopLeft     = 4,
    IHFImageDirectionLeftTop     = IHFImageDirectionTopLeft,
    IHFImageDirectionTopRight    = 5,
    IHFImageDirectionRightTop    = IHFImageDirectionTopRight,
    IHFImageDirectionBottomLeft  = 6,
    IHFImageDirectionLeftBottom  = IHFImageDirectionBottomLeft,
    IHFImageDirectionBottomRight = 7,
    IHFImageDirectionRightBottom = IHFImageDirectionBottomRight
};

@interface UIImage (IHF)

/**
 Returns Image apply to blur
 */
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

/** 
 Returns a Screen Blur image with the given view
 */
+ (UIImage *)imageOfScreenBlurWithView:(UIView *)view;


/**
 Returns a image with the given color
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 Returns a arrow image
 */
+ (UIImage *)imageWithArrowImageSize:(CGSize)imageSize
                           size:(CGSize)size
                         offset:(CGPoint)offset
                         rotate:(CGFloat)degrees
                      thickness:(CGFloat)thickness
                      direction:(IHFImageDirection)direction
                backgroundColor:(UIColor *)backgroundColor
                          color:(UIColor *)color
                           dash:(NSArray *)dash
                    shadowColor:(UIColor *)shadowColor
                   shadowOffset:(CGPoint)shadowOffset
                     shadowBlur:(CGFloat)shadowBlur;


/**
 Returns a circle image
 */

+ (UIImage *)imageForCircleWithImageSize:(CGSize)imageSize
                                    size:(CGSize)size
                                  offset:(CGPoint)offset
                                  rotate:(CGFloat)degrees
                         backgroundColor:(UIColor *)backgroundColor
                               fillColor:(UIColor *)fillColor
                             shadowColor:(UIColor *)shadowColor
                            shadowOffset:(CGPoint)shadowOffset
                              shadowBlur:(CGFloat)shadowBlur;

/**
 returns resized image from middle (0.5 , 0.5)
 */
- (UIImage *)resizedImageFromMiddle;

/**
 returns resized image from specified width and height
 */

- (UIImage *)resizedImageWidth:(CGFloat)width height:(CGFloat)height;

/**
 returns resized image from middle (0.5 , 0.5)
 */

+ (UIImage *)imageWithResizedFromMiddle:(UIImage *)image;


@end

// -----------  UIView
@interface UIView (dr)

/**
 *  给label, button, textfield等添加圆角，默认borderWidth = 1.0f, backgroundColor = whiteColor, borderColor = blackColor
 *
 *  @param radius 弧度
 */
- (void)addCornerRadius:(CGFloat)radius;


/**
 *  给label, button, textfield等添加圆角, 可以自定义其它的属性
 *
 *  @param radius          弧度
 *  @param borderWidth     borderWidth
 *  @param backgroundColor backgroundColor
 *  @param borderColor     borderColor
 */
- (void)addCornerRadius:(CGFloat)radius
               borderWidth:(CGFloat)borderWidth
           backgroundColor:(UIColor *)backgroundColor
              borderCorlor:(UIColor *)borderColor;

@end


#pragma mark - UIImageView (CornerRounder)

@interface UIImageView (CornerRounder)

/**
 *  给imageView做圆角, 无边框
 *
 *  @param radius 圆角弧度
 */

- (void)addCornerRadius:(CGFloat)radius;

@end