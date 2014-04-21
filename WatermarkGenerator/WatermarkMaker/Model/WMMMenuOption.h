//
//  WMMMenuOption.h
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

typedef enum {
    WMMMenuOptionActionType_Push = 0,
    WMMMenuOptionActionType_OpenURL,
    
} WMMMenuOptionActionType;

@interface WMMMenuOption : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSInteger tag;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) WMMMenuOptionActionType optionType;
@property (nonatomic, readonly) NSString *optionValue;

- (id)initWithDictionary:(NSDictionary *)data;

@end
