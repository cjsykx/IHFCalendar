//
//  UIImage+IHF.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/23.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import "UIImage+IHF.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#import <Accelerate/Accelerate.h>
#endif

static CGFloat const degreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

static CGFloat const radiansToDegrees(CGFloat radians) {
    return radians * 180/M_PI;
}
@implementation UIImage (IHF)

#pragma mark - blur view

+ (UIImage *)getScreenImageWithView:(UIView *)view{
    // frame without status bar
    CGRect frame;
    
    if (UIDeviceOrientationIsPortrait((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation)) {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } else {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    // begin image context
    UIGraphicsBeginImageContext(frame.size);
    // get current context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // draw current view
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    // clip context to frame
    CGContextClipToRect(currentContext, frame);
    // get resulting cropped screenshot
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    // end image context
    UIGraphicsEndImageContext();
    return screenshot;
}

+ (UIImage *)getBlurredImage:(UIImage *)imageToBlur {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [imageToBlur applyBlurWithRadius:10.0f tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
    }
    return imageToBlur;
}

+ (UIImage *)imageOfScreenBlurWithView:(UIView *)view{
    
    return [self getBlurredImage:[self getScreenImageWithView:view]];
}

// This method is taken from Apple's UIImageEffects category provided in WWDC 2013 sample code
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark - Rotated

- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    return [self imageRotatedByDegrees:radiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - quartz2D

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Arrow

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
                         shadowBlur:(CGFloat)shadowBlur
{
    CGRect imageRect = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    BOOL backgroundNeeded = (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]]);
    BOOL shadowNeeded = (shadowColor && ![shadowColor isEqual:[UIColor clearColor]]);
    
    // BACKGROUND -----
    
    if (backgroundNeeded)
    {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, imageRect);
    }
    
    // FILL -----
    
    if (shadowNeeded)
        CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x, shadowOffset.y), shadowBlur, shadowColor.CGColor);
    
    // -----
    
    CGRect rect = CGRectMake(imageSize.width/2-size.width/2+offset.x, imageSize.height/2-size.height/2+offset.y, size.width, size.height);
    
    CGPoint topCenter = CGPointZero;
    CGPoint bottomLeft = CGPointZero;
    CGPoint bottomRight = CGPointZero;
    
    if (direction == IHFImageDirectionTop)
    {
        topCenter   = CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+rect.size.height-thickness/2);
        bottomRight = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+rect.size.height-thickness/2);
    }
    else if (direction == IHFImageDirectionBottom)
    {
        topCenter   = CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height-thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+thickness/2);
        bottomRight = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+thickness/2);
    }
    else if (direction == IHFImageDirectionRight)
    {
        topCenter   = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+rect.size.height/2);
        bottomLeft  = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+thickness/2);
        bottomRight = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+rect.size.height-thickness/2);
    }
    else if (direction == IHFImageDirectionLeft)
    {
        topCenter   = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+rect.size.height/2);
        bottomRight = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+rect.size.height-thickness/2);
    }
    else if (direction == IHFImageDirectionTopLeft)
    {
        topCenter   = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+rect.size.height/3);
        bottomRight = CGPointMake(rect.origin.x+rect.size.width/3, rect.origin.y+rect.size.height-thickness/2);
    }
    else if (direction == IHFImageDirectionTopRight)
    {
        topCenter   = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+rect.size.height/3);
        bottomRight = CGPointMake(rect.origin.x+rect.size.width-rect.size.width/3, rect.origin.y+rect.size.height-thickness/2);
    }
    else if (direction == IHFImageDirectionBottomLeft)
    {
        topCenter   = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+rect.size.height-thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+rect.size.height-rect.size.height/3);
        bottomRight = CGPointMake(rect.origin.x+rect.size.width/3, rect.origin.y+thickness/2);
    }
    else if (direction == IHFImageDirectionBottomRight)
    {
        topCenter   = CGPointMake(rect.origin.x+rect.size.width-thickness/2, rect.origin.y+rect.size.height-thickness/2);
        bottomLeft  = CGPointMake(rect.origin.x+rect.size.width-rect.size.width/3, rect.origin.y+thickness/2);
        bottomRight = CGPointMake(rect.origin.x+thickness/2, rect.origin.y+rect.size.height-rect.size.height/3);
    }
    
    UIBezierPath *path = [UIBezierPath new];
    
    [path moveToPoint:bottomLeft];
    [path addLineToPoint:topCenter];
    [path addLineToPoint:bottomRight];
    
    // -----
    
    if (degrees)
    {
        CGRect originalBounds = path.bounds;
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        [path applyTransform:rotate];
        
        CGAffineTransform translate = CGAffineTransformMakeTranslation(-(path.bounds.origin.x-originalBounds.origin.x)-(path.bounds.size.width-originalBounds.size.width)*0.5,
                                                                       -(path.bounds.origin.y-originalBounds.origin.y)-(path.bounds.size.height-originalBounds.size.height)*0.5);
        [path applyTransform:translate];
    }
    
    // -----
    
    if (dash.count)
    {
        CGFloat cArray[dash.count];
        
        for (NSUInteger i=0; i<dash.count; i++)
            cArray[i] = [dash[i] floatValue];
        
        CGContextSetLineDash(context, 0, cArray, dash.count);
    }
    
    path.lineWidth = thickness;
    
    // -----
    
    [color setStroke];
    [path stroke];
    
    // MAKE UIImage -----
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - circle

+ (UIImage *)imageForCircleWithImageSize:(CGSize)imageSize
                                     size:(CGSize)size
                                   offset:(CGPoint)offset
                                   rotate:(CGFloat)degrees
                          backgroundColor:(UIColor *)backgroundColor
                                fillColor:(UIColor *)fillColor
                              shadowColor:(UIColor *)shadowColor
                             shadowOffset:(CGPoint)shadowOffset
                               shadowBlur:(CGFloat)shadowBlur
{
    CGRect imageRect = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    BOOL backgroundNeeded = (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]]);
    BOOL fillNeeded = (fillColor && ![fillColor isEqual:[UIColor clearColor]]);
    BOOL shadowNeeded = (shadowColor && ![shadowColor isEqual:[UIColor clearColor]]);
    
    // BACKGROUND -----
    
    if (backgroundNeeded)
    {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, imageRect);
    }
    
    // FILL -----
    
    if (fillNeeded)
    {
        if (shadowNeeded)
            CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x, shadowOffset.y), shadowBlur, shadowColor.CGColor);
        
        // -----
        
        CGRect rect = CGRectMake(imageSize.width/2-size.width/2+offset.x, imageSize.height/2-size.height/2+offset.y, size.width, size.height);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        // -----
        
        if (degrees)
        {
            CGRect originalBounds = path.bounds;
            
            CGAffineTransform rotate = CGAffineTransformIdentity;
            [path applyTransform:rotate];
            
            CGAffineTransform translate = CGAffineTransformMakeTranslation(-(path.bounds.origin.x-originalBounds.origin.x)-(path.bounds.size.width-originalBounds.size.width)*0.5,
                                                                           -(path.bounds.origin.y-originalBounds.origin.y)-(path.bounds.size.height-originalBounds.size.height)*0.5);
            [path applyTransform:translate];
        }
        
        // -----
        
        [fillColor setFill];
        [path fill];
    }
    
    // MAKE UIImage -----
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - resized
- (UIImage *)resizedImageFromMiddle{
    return [self resizedImageWidth:0.5f height:0.5f];
}

- (UIImage *)resizedImageWidth:(CGFloat)width height:(CGFloat)height {
    
    return [self stretchableImageWithLeftCapWidth:self.size.width * width
                                      topCapHeight:self.size.height * height];
}

+ (UIImage *)imageWithResizedFromMiddle:(UIImage *)image{
    
    CGFloat width = image.size.width * 0.5;
    CGFloat height = image.size.height * 0.5;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(height, width, width, height)];
}


#pragma mark - corner
- (UIImage *)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

#pragma mark - 针对UIView绘画出Image

@implementation UIView (dr)


- (void)addCornerRadius:(CGFloat)radius {
    [self addCornerRadius:radius
                 borderWidth:1.0f
             backgroundColor:[UIColor whiteColor]
                borderCorlor:[UIColor blackColor]];
}

- (void)addCornerRadius:(CGFloat)radius
               borderWidth:(CGFloat)borderWidth
           backgroundColor:(UIColor *)backgroundColor
              borderCorlor:(UIColor *)borderColor {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self drawRectWithRoundedCornerRadius:radius
                                                                                             borderWidth:borderWidth
                                                                                         backgroundColor:backgroundColor
                                                                                            borderCorlor:borderColor]];
    
    [self insertSubview:imageView atIndex:0];
}

- (UIImage *)drawRectWithRoundedCornerRadius:(CGFloat)radius
                                    borderWidth:(CGFloat)borderWidth
                                backgroundColor:(UIColor *)backgroundColor
                                   borderCorlor:(UIColor *)borderColor {
    CGSize sizeToFit = CGSizeMake([[self class] pixel:self.bounds.size.width], self.bounds.size.height);
    CGFloat halfBorderWidth = borderWidth / 2.0;
    
    UIGraphicsBeginImageContextWithOptions(sizeToFit, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    
    CGFloat width = sizeToFit.width, height = sizeToFit.height;
    CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth); // 准备开始移动坐标
    CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius);
    CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius); // 左下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius); // 左上角
    CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius);
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - support tools
+ (CGFloat)ceilbyunit:(CGFloat)num unit:(double)unit {
    return num - modf(num, &unit) + unit;
}

+ (CGFloat)floorbyunit:(CGFloat)num unit:(double)unit {
    return num - modf(num, &unit);
}

+ (CGFloat)roundbyunit:(CGFloat)num unit:(double)unit {
    CGFloat remain = modf(num, &unit);
    if (remain > unit / 2.0) {
        return [self ceilbyunit:num unit:unit];
    } else {
        return [self floorbyunit:num unit:unit];
    }
}

+ (CGFloat)pixel:(CGFloat)num {
    CGFloat unit;
    CGFloat scale = [[UIScreen mainScreen] scale];
    switch ((NSInteger)scale) {
        case 1:
            unit = 1.0 / 1.0;
            break;
        case 2:
            unit = 1.0 / 2.0;
            break;
        case 3:
            unit = 1.0 / 3.0;
            break;
        default:
            unit = 0.0;
            break;
    }
    return [self roundbyunit:num unit:unit];
}


@end

#pragma mark - UIImageView (CornerRounder)

@implementation UIImageView (CornerRounder)

- (void)addCornerRadius:(CGFloat)radius {
    self.image = [self.image imageAddCornerWithRadius:radius andSize:self.bounds.size];
}
@end
