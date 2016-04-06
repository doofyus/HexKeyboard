//
//  MRHexKeyboard.m
//
//  Created by Mikk Rätsep on 02/10/13.
//  Copyright (c) 2013 Mikk Rätsep. All rights reserved.
//

#import "MRHexKeyboard.h"

CGFloat minKeyboardHeight;

static UIColor *sGrayColour = nil;

@interface MRHexKeyboard ()

@property(nonatomic, weak) UITextField *textField;

@property(nonatomic, strong) UIButton * zeroxButton;
@property(nonatomic, strong) UIButton * zeroButton;
@property(nonatomic, strong) UIButton * deleteButton;

@property(nonatomic, strong) NSArray<UIButton *> * numberButtons;

@property(nonatomic, strong) NSArray<NSLayoutConstraint *> * positionConstraints;

@end

@implementation MRHexKeyboard

- (MRHexKeyboard *)initWithTextField:(UITextField *)textField
{
    self = [super init];

    if (self) {
        minKeyboardHeight = MIN([UIScreen mainScreen].bounds.size.width - 100, 305);
        _height = minKeyboardHeight;
        
        self.textField = textField;

        sGrayColour = [UIColor lightTextColor];

        self.backgroundColor = [UIColor lightGrayColor];
        
        _display0xButton = YES;
        _add0x = YES;
        
        UIButton *button = [[UIButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        button.backgroundColor = sGrayColour;
        [button setImage:[UIImage imageNamed:@"deleteButton"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDragEnter];
        [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(changeTextFieldText:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        self.deleteButton = button;

        NSMutableArray<UIButton *> * buttons = [NSMutableArray arrayWithCapacity:15];
        /* Makes the numerical buttons */
        for (NSInteger num = 1; num <= 15; num++) {
            [buttons addObject:[self makeButtonWithTitle:[self buttonTitleForNumber:num] grayBackground:NO]];
        }
        self.numberButtons = buttons;
        
        self.zeroxButton = [self makeButtonWithTitle:@"0x" grayBackground:YES];
        self.display0xButton = _display0xButton;
        
        self.zeroButton = [self makeButtonWithTitle:@"0" grayBackground:NO];
        
        self.positionConstraints = @[];
    }
    
    return self;
}

- (void)setDisplay0xButton:(BOOL)display0xButton {
    _display0xButton = display0xButton;
    self.zeroxButton.hidden = !_display0xButton;
}

- (void)setHeight:(CGFloat)height {
    height = MAX(height, minKeyboardHeight);
    CGRect frame = self.frame;
    frame.size.height = height;
    frame.origin.y += _height - height;
    _height = height;
    self.frame = frame;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self removeConstraints:self.positionConstraints];
    NSMutableArray <NSLayoutConstraint *> * constraints = [NSMutableArray arrayWithCapacity:45];
    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        for(NSInteger num = 0; num < 15; num += 3) {
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[b1]-1-[b2]-1-[b3]|" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+1],@"b3":self.numberButtons[num+2]}];
            [constraints addObjectsFromArray:cs];
        }
        NSArray * lastButtons = @[self.zeroxButton, self.zeroButton, self.deleteButton];
        NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[b1]-1-[b2]-1-[b3]|" options:0 metrics:nil views:@{@"b1":lastButtons[0],@"b2":lastButtons[1],@"b3":lastButtons[2]}];
        [constraints addObjectsFromArray:cs];
        
        for(NSInteger num = 0; num < 3; num += 1) {
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1]-1-[b2]-1-[b3]-1-[b4]-1-[b5]-1-[b6]|" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+3],@"b3":self.numberButtons[num+6],@"b4":self.numberButtons[num+9],@"b5":self.numberButtons[num+12],@"b6":lastButtons[num]}];
            [constraints addObjectsFromArray:cs];
        }
    } else {
        NSArray * lastButtons = @[self.zeroButton, self.zeroxButton, self.deleteButton];
        for(NSInteger num = 0; num < 15; num += 5) {
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[b1]-1-[b2]-1-[b3]-1-[b4]-1-[b5]-1-[b6]|" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+1],@"b3":self.numberButtons[num+2],@"b4":self.numberButtons[num+3],@"b5":self.numberButtons[num+4],@"b6":lastButtons[num/5]}];
            [constraints addObjectsFromArray:cs];
        }
        
        
        for(NSInteger num = 0; num < 5; num += 1) {
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1]-1-[b2]-1-[b3]|" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+5],@"b3":self.numberButtons[num+10]}];
            [constraints addObjectsFromArray:cs];
        }
        
        NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1]-1-[b2]-1-[b3]|" options:0 metrics:nil views:@{@"b1":lastButtons[0],@"b2":lastButtons[1],@"b3":lastButtons[2]}];
        [constraints addObjectsFromArray:cs];
    }
    self.positionConstraints = constraints;
    [self addConstraints:self.positionConstraints];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title grayBackground:(BOOL)grayBackground
{
    UIButton *button = [[UIButton alloc] init];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat fontSize = 25.0f;

    if (![[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:title]]) {
        fontSize = 20.0f;
    }

    button.backgroundColor = (grayBackground) ? sGrayColour : [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDragEnter];
    [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(changeTextFieldText:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:button];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    return button;
}

- (NSString *)buttonTitleForNumber:(NSInteger)num
{
    unichar c = num < 0xA ? num + 0x30 : num + 0x37;
    return [NSString stringWithCharacters:&c length:1];
}

- (void)changeButtonBackgroundColourForHighlight:(UIButton *)button
{
    UIColor *newColour = sGrayColour;

    if ([button.backgroundColor isEqual:sGrayColour]) {
        newColour = [UIColor whiteColor];
    }

    button.backgroundColor = newColour;
}

- (void)changeTextFieldText:(UIButton *)button
{
    if (_textField) {
        NSMutableString *string = [NSMutableString stringWithString:_textField.text];

        if (button.titleLabel.text) {
            if ([button.titleLabel.text isEqualToString:@"0x"]) {
                if (string.length == 0) {
                    [string appendString:@"0x"];
                }
                else {
                    [string appendString:@" 0x"];
                }
            }
            else if(self.add0x) {
                if (string.length == 0) {
                    [string appendFormat:@"0x%@", button.titleLabel.text];
                } else {
                    if (string.length > 2) {
                        NSString *lastTwoChars = [string substringFromIndex:(string.length - 2)];
                        
                        if ([lastTwoChars rangeOfString:@"x"].location == NSNotFound) {
                            [string appendFormat:@" 0x%@", button.titleLabel.text];
                        } else {
                            [string appendString:button.titleLabel.text];
                        }
                    } else {
                        [string appendString:button.titleLabel.text];
                    }
                }
            } else {
                [string appendString:button.titleLabel.text];
            }
        }
        else if (_textField.text.length > 0) {
            NSRange deleteRange;
            NSString *lastChar = [string substringFromIndex:(string.length - 1)];

            if ([lastChar isEqualToString:@"x"]) {
                if (string.length > 2) {
                    deleteRange = NSMakeRange((string.length - 3), 3);
                }
                else {
                    deleteRange = NSMakeRange((string.length - 2), 2);
                }
            }
            else {
                deleteRange = NSMakeRange((string.length - 1), 1);
            }

            [string deleteCharactersInRange:deleteRange];
        }

        _textField.text = string;
    }

    [self changeButtonBackgroundColourForHighlight:button];
}

@end
