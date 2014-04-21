//
//  WMMSideMenuViewController.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 2/18/14.
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
#import "WMMSideMenuViewController.h"
#import "CLSideMenuViewController.h"
#import "WMMMenuManager.h"
#import "WMMMenuOption.h"


@interface WMMSideMenuViewController () <CLMenuViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *prototypeButton;

@end

@implementation WMMSideMenuViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addButtons];
    [self setDelegate:self];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private 

-(void)preferredContentSizeChanged:(NSNotification* )notification
{
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton *)subview).titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
    }
}

#pragma mark CLMenuViewControllerDelegate

- (void)addButtons
{
    NSInteger position = 0;
    NSInteger offset = kMenuOptionsOffset;
    
    [self registerMenuButton:self.prototypeButton]; // hyper uber hack bc CLMenuViewController does not allow to touch the same button twice
    
    for (WMMMenuOption *option in [[WMMMenuManager sharedInstance] menuOptions]) {
        UIButton *optionBtn = [UIButton buttonWithType:self.prototypeButton.buttonType];
        optionBtn.frame = self.prototypeButton.frame;
        optionBtn.titleLabel.frame = self.prototypeButton.titleLabel.frame;
        optionBtn.titleLabel.font = self.prototypeButton.titleLabel.font;
        optionBtn.titleLabel.minimumScaleFactor = self.prototypeButton.titleLabel.minimumScaleFactor;
        optionBtn.titleLabel.shadowOffset = self.prototypeButton.titleLabel.shadowOffset;
        optionBtn.imageEdgeInsets = self.prototypeButton.imageEdgeInsets;
        optionBtn.tag = option.tag;

        [optionBtn setTitle:$localise(option.title) forState:UIControlStateNormal];
        [optionBtn setTitleColor:self.prototypeButton.titleLabel.textColor forState:UIControlStateNormal];
        [optionBtn setTitleShadowColor:self.prototypeButton.titleLabel.shadowColor forState:UIControlStateNormal];
        [optionBtn setImage:option.icon forState:UIControlStateNormal];
        
        optionBtn.center = CGPointMake(self.prototypeButton.center.x, self.prototypeButton.center.y + position++ * self.prototypeButton.frame.size.height + offset);
        
        [self.view addSubview:optionBtn];
        
        [self registerMenuButton:optionBtn];
        
        position++;
    }
}

-(void)menuButtonSelected:(UIButton *)sender
{
    @weakify(self)
    [self.sideMenuViewController closeMenuAnimated:YES completion:^(BOOL finished){
        @strongify(self)
        [[WMMMenuManager sharedInstance] userSelectedOptionTagged:sender.tag];
        [self.prototypeButton sendActionsForControlEvents:UIControlEventTouchUpInside]; // hyper uber hack bc CLMenuViewController does not allow to touch the same button twice
    }];
}

@end
