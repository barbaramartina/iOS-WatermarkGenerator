//
//  DLAVAlertViewTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat top;
    CGFloat bottom;
    CGFloat left;
    CGFloat right;
} DLAVTextControlMargins;

extern const DLAVTextControlMargins DLAVTextControlMarginsNone;

DLAVTextControlMargins DLAVTextControlMarginsMake(CGFloat top, CGFloat bottom, CGFloat left, CGFloat right);

@class DLAVAlertViewTextFieldTheme, DLAVAlertViewButtonTheme;

@interface DLAVAlertViewTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (readwrite, strong, nonatomic) UIColor *backgroundColor;

@property (readwrite, assign, nonatomic) CGFloat cornerRadius;

@property (readwrite, assign, nonatomic) CGFloat lineWidth;
@property (readwrite, strong, nonatomic) UIColor *lineColor;

@property (readwrite, strong, nonatomic) UIColor *borderColor;
@property (readwrite, assign, nonatomic) CGFloat borderWidth;

@property (readwrite, assign, nonatomic) DLAVTextControlMargins contentViewMargins;

@property (readwrite, assign, nonatomic) DLAVTextControlMargins titleMargins;
@property (readwrite, strong, nonatomic) UIColor *titleColor;
@property (readwrite, strong, nonatomic) UIFont *titleFont;

@property (readwrite, assign, nonatomic) DLAVTextControlMargins messageMargins;
@property (readwrite, strong, nonatomic) UIColor *messageColor;
@property (readwrite, strong, nonatomic) UIFont *messageFont;

@property (readwrite, strong, nonatomic) UIColor *shadowColor;
@property (readwrite, assign, nonatomic) CGFloat shadowOpacity;
@property (readwrite, assign, nonatomic) CGFloat shadowRadius;
@property (readwrite, assign, nonatomic) CGSize shadowOffset;

@property (readwrite, copy, nonatomic) DLAVAlertViewTextFieldTheme *textFieldTheme;
@property (readwrite, copy, nonatomic) DLAVAlertViewButtonTheme *buttonTheme;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

+ (DLAVAlertViewTheme *)defaultTheme;
+ (void)setDefaultTheme:(DLAVAlertViewTheme *)theme;

@end

