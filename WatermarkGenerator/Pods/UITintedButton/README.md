UITintedButton
==============

Evert wanted to tint a UIButton like you do with a UIBarButtonItem or a UINavigationItem? Here you go!

This category adds two instance methods and two class methods to UIButton:

	-(void)setImageTintColor:(UIColor *)color;
	-(void)setBackgroundTintColor:(UIColor *)color forState:(UIControlState)state;
	
	+(void)tintButtonImages:(NSArray *)buttons withColor:(UIColor *)color;
	+(void)tintButtonBackgrounds:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;

## Installation

Drag ```UIButton+tintImage.h``` and ```UIButton+tintImage.m```.

## Usage

	#import UIButton+tintImage.h
	
	// Tint single buttons
	[button setImageTintColor:[UIColor redColor]];
    [button setBackgroundTintColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // Tint multiple buttons
    [UIButton tintButtonImages:@[button1, button2, button3] withColor:[UIColor redColor]];
    [UIButton tintButtonBackgrounds:@[button1, button2, button3] withColor:[UIColor redColor] forState:UIControlStateNormal];

