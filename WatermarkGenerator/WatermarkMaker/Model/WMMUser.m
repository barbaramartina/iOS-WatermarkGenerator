//
//  WMMUser.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 2/21/14.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
#import "WMMUser.h"

/**********************************************************************/

static NSString *kWatermarkKey = @"selected-watermark";
static NSString *kColorREDKey = @"selected-color-red";
static NSString *kColorGREENKey = @"selected-color-green";
static NSString *kColorBLUEKey = @"selected-color-blue";
static NSString *kFontFamilyKey = @"selected-font-family";
static NSString *kFontSizeKey = @"selected-font-size";

static NSString *kDefaultWatermakText = @"Watermark text here!";
static CGFloat kDefaultRED = 0.0f;
static CGFloat kDefaultGREEN = 0.0f;
static CGFloat kDefaultBLUE = 0.0f;
static CGFloat kDefaultFontSize = 16.0f;
static NSString *kDefaultFontFamily = @"Baskerville";

/**********************************************************************/
#pragma mark Static Variables

static WMMUser *_instance = nil;

/**********************************************************************/

@implementation WMMUser

+ (WMMUser *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

- (id)init
{
    if ((self = [super init])) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // text
        self.watermarkText = [userDefaults objectForKey:kWatermarkKey] ? [userDefaults objectForKey:kWatermarkKey] : $localise(kDefaultWatermakText);
        
        // color
        CGFloat red = [[userDefaults objectForKey:kColorREDKey] floatValue];
        CGFloat green = [[userDefaults objectForKey:kColorGREENKey] floatValue];
        CGFloat blue = [[userDefaults objectForKey:kColorBLUEKey] floatValue];
        self.preferedColor = [userDefaults objectForKey:kColorREDKey] ? [UIColor colorWithRed:red green:green blue:blue alpha:1.0f] : [UIColor colorWithRed:kDefaultRED green:kDefaultGREEN blue:kDefaultBLUE alpha:1.0f];
        
        // font
        self.preferedFontFamily = [userDefaults objectForKey:kFontFamilyKey] ? [userDefaults objectForKey:kFontFamilyKey] : kDefaultFontFamily;
        self.preferedFontSize = [userDefaults objectForKey:kFontSizeKey] ? [[userDefaults objectForKey:kFontSizeKey] floatValue] : kDefaultFontSize;
    }
    return self;
}

- (void)setWatermarkText:(NSString *)watermarkText {
    if (_watermarkText != watermarkText) {
        _watermarkText = watermarkText;
        
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.watermarkText forKey:kWatermarkKey];
            [userDefaults synchronize];
        });
    }
}

- (void)setPreferedColor:(UIColor *)preferedColor
{
    if (_preferedColor != preferedColor) {
        _preferedColor = preferedColor;
        
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            const CGFloat* components = CGColorGetComponents(self.preferedColor.CGColor);
            [userDefaults setFloat:components[0] forKey:kColorREDKey];
            [userDefaults setFloat:components[1] forKey:kColorGREENKey];
            [userDefaults setFloat:components[2] forKey:kColorBLUEKey];
            [userDefaults synchronize];
        });
    }
}

- (void)setPreferedFontFamily:(NSString *)preferedFontFamily
{
    if (_preferedFontFamily != preferedFontFamily) {
        _preferedFontFamily = preferedFontFamily;
        
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.preferedFontFamily forKey:kFontFamilyKey];
            [userDefaults synchronize];
        });
    }
}

- (void)setPreferedFontSize:(CGFloat)preferedFontSize
{
    if (_preferedFontSize != preferedFontSize) {
        _preferedFontSize = preferedFontSize;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setFloat:self.preferedFontSize forKey:kFontSizeKey];
        [userDefaults synchronize];
    });
}


@end
