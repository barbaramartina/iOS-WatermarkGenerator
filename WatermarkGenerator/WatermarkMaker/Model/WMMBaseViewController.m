//
//  WMMBaseViewController.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 4/4/14.
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
#import "WMMBaseViewController.h"

/**********************************************************************/

static NSString *kiPhoneSuffix = @"-iphone";
static NSString *kiPadSuffix = @"-ipad";
static NSString *kLandscapeSuffix = @"-landscape";
static NSString *kPortraitSuffix = @"-portrait";

/**********************************************************************/

@interface WMMBaseViewController ()

@property (nonatomic,strong) NSString *currentNibName;

@end

/**********************************************************************/

@implementation WMMBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentNibName = nibNameOrNil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.currentNibName == nil) {
        self.currentNibName = self.nibName;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([self changeViewToInterfaceOrientation:toInterfaceOrientation]) {
        [self viewDidLoad];
    }
}

#pragma mark Private

- (BOOL)changeViewToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSString *orientationSuffix = UIInterfaceOrientationIsPortrait(orientation) ? kPortraitSuffix : kLandscapeSuffix;

    if ([self.currentNibName rangeOfString:orientationSuffix].location == NSNotFound || !self.currentNibName){
        NSString *platformSuffix = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? kiPhoneSuffix : kiPadSuffix;
        NSString *fullNibName = [NSString stringWithFormat:@"%@%@%@",NSStringFromClass([self class]),platformSuffix,orientationSuffix];
        
        NSArray *nibData = [[NSBundle mainBundle] loadNibNamed:fullNibName owner:self options:nil];
        
        self.view = nibData[0];
        
        self.currentNibName = fullNibName;
        
        return YES;
    }
    return NO;
}

@end
