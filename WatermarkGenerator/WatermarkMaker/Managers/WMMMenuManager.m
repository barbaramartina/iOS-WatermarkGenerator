//
//  WMMMenuManager.m
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
#import "WMMMenuManager.h"
#import "WMMMenuOption.h"

/**********************************************************************/
#pragma mark Static Variables

static WMMMenuManager *_instance = nil;
static NSString *kOptionsPlistFileName = @"menu-options";

/**********************************************************************/
#pragma mark Private category

@interface WMMMenuManager ()

@property (nonatomic, strong) NSMutableArray *options;

@end

/**********************************************************************/

@implementation WMMMenuManager

+(WMMMenuManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

// TODO load dinamically
- (NSArray *)menuOptions {
    if (self.options)
        return self.options;
    
    self.options = [NSMutableArray array];
    
    NSArray *optionsData = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:kOptionsPlistFileName withExtension:@"plist"]];
    
    for (NSDictionary *data in optionsData) {
        WMMMenuOption *option = [[WMMMenuOption alloc] initWithDictionary:data];
        [self.options addObject:option];
    }
    
    [self.options sortUsingComparator:^(id obj1, id obj2){
        if ( ((WMMMenuOption *)obj1).tag > ((WMMMenuOption *)obj2).tag )
            return NSOrderedDescending;
        else if ( ((WMMMenuOption *)obj1).tag < ((WMMMenuOption *)obj2).tag )
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    return self.options;
}

- (void)userSelectedOptionTagged:(NSInteger)tag {
    if ([self.delegate respondsToSelector:@selector(menuOptionPressed:)]) {
        [self.delegate menuOptionPressed:self.options[tag]];
    }
}

@end
