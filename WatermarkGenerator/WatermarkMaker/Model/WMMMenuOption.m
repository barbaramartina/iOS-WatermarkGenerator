//
//  WMMMenuOption.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 2/19/14.
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
#import "WMMMenuOption.h"


/**********************************************************************/
#pragma mark static variable
static NSString *kTitleKey = @"title";
static NSString *kTagKey = @"tag";
static NSString *kIconKey = @"icon";
static NSString *kOptionTypeKey = @"option-type";
static NSString *kOptionValue = @"option-value";

/**********************************************************************/

#pragma mark Private Category
@interface WMMMenuOption()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) WMMMenuOptionActionType optionType;
@property (nonatomic, strong) NSString *optionValue;

@end

/**********************************************************************/

@implementation WMMMenuOption

- (id)initWithDictionary:(NSDictionary *)data {
    if ((self = [super init])) {
        self.title = [data objectForKey:kTitleKey];
        self.tag = [[data objectForKey:kTagKey] integerValue];
        self.icon = [UIImage imageNamed:[data objectForKey:kIconKey]];
        self.optionType = (WMMMenuOptionActionType)[[data objectForKey:kOptionTypeKey] integerValue];
        self.optionValue = [data objectForKey:kOptionValue];
    }
    return self;
}

@end
