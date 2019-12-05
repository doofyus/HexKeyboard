//
//  MRHexKeyboard.m
//
//  Created by Mikk Rätsep on 02/10/13.
//  Copyright (c) 2013 Mikk Rätsep. All rights reserved.
//

#import "MRHexKeyboard.h"

@interface UITextField (CustomKeyboard)

- (NSRange)selectedRange;

@end

@implementation UITextField (CustomKeyboard)

- (NSRange)selectedRange {
    UITextRange *tr = [self selectedTextRange];
    
    NSInteger spos = [self offsetFromPosition:self.beginningOfDocument toPosition:tr.start];
    NSInteger epos = [self offsetFromPosition:self.beginningOfDocument toPosition:tr.end];
    
    return NSMakeRange(spos, epos - spos);
}

@end

static UIColor *sGrayColour = nil;

@interface MRHexKeyboard () <UIInputViewAudioFeedback>

@property(nonatomic, weak) id<UITextInput> input;

@property(nonatomic, assign) BOOL tfShouldChange;
@property(nonatomic, assign) BOOL tvShouldChange;

@property(nonatomic, strong) UIButton * zeroxButton;
@property(nonatomic, strong) UIButton * zeroButton;
@property(nonatomic, strong) UIButton * deleteButton;

@property(nonatomic, strong) NSArray<UIButton *> * numberButtons;

@property(nonatomic, strong) NSArray<NSLayoutConstraint *> * positionConstraints;

@end

@implementation MRHexKeyboard

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        
        sGrayColour = [UIColor lightTextColor];
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        _display0xButton = YES;
        _add0x = YES;
        
        UIButton *button = [[UIButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        button.backgroundColor = sGrayColour;
        UIImage *image;
        if (@available(iOS 13.0, *)) {
            NSBundle *bundle = [NSBundle bundleForClass:self.class];
            image = [UIImage imageNamed:@"deleteButton"
                               inBundle:bundle
                      withConfiguration:NULL];
        } else {
            image = [UIImage imageNamed:@"deleteButton"];
        }
        [button setImage:image forState:UIControlStateNormal];
        if([button respondsToSelector:@selector(imageView)]) {
            button.imageView.contentMode = UIViewContentModeCenter;
        }
        [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDragEnter];
        [button addTarget:self action:@selector(changeButtonBackgroundColourForHighlight:) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(deleteBackward:) forControlEvents:UIControlEventTouchUpInside];
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkInput:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    }
    
    return self;
}

// This is used to obtain the current text field/view that is now the first responder
- (void)checkInput:(NSNotification *)notification {
    UITextField *field = notification.object;
    
    if (field.inputView && self == field.inputView) {
        _input = field;
        
        _tvShouldChange = NO;
        _tfShouldChange = NO;
        if ([_input isKindOfClass:[UITextField class]]) {
            id<UITextFieldDelegate> del = [(UITextField *)_input delegate];
            if ([del respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                _tfShouldChange = YES;
            }
        } else if ([_input isKindOfClass:[UITextView class]]) {
            id<UITextViewDelegate> del = [(UITextView *)_input delegate];
            if ([del respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                _tvShouldChange = YES;
            }
        }
    }
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

- (void)setTextField:(id<UITextInput>)textField {
    if(_input == textField) return;
    UITextField *tf = (UITextField *)_input;
    if(tf.delegate == self) {
        tf.delegate = nil;
    }
    _input = textField;
    tf = (UITextField *)_input;
    if(tf.delegate == nil) {
        tf.delegate = self;
    }
}

- (void)setDisplay0xButton:(BOOL)display0xButton {
    _display0xButton = display0xButton;
    self.zeroxButton.hidden = !_display0xButton;
}

- (void)updateConstraints {
    [super updateConstraints];
    NSLayoutYAxisAnchor * topLayoutAnchor;
    NSLayoutYAxisAnchor * bottomLayoutAnchor;
    NSLayoutXAxisAnchor * leftLayoutAnchor;
    NSLayoutXAxisAnchor * rightLayoutAnchor;
    if (@available(iOS 11.0, *)) {
        topLayoutAnchor = self.safeAreaLayoutGuide.topAnchor;
        bottomLayoutAnchor = self.safeAreaLayoutGuide.bottomAnchor;
        leftLayoutAnchor = self.safeAreaLayoutGuide.leftAnchor;
        rightLayoutAnchor = self.safeAreaLayoutGuide.rightAnchor;
    } else {
        topLayoutAnchor = self.topAnchor;
        bottomLayoutAnchor = self.bottomAnchor;
        leftLayoutAnchor = self.leftAnchor;
        rightLayoutAnchor = self.rightAnchor;
    }
    [self removeConstraints:self.positionConstraints];
    NSMutableArray <NSLayoutConstraint *> * constraints = [NSMutableArray arrayWithCapacity:45];
    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        for(NSInteger num = 0; num < 15; num += 3) {
            [NSLayoutConstraint activateConstraints:@[
                [leftLayoutAnchor constraintEqualToAnchor:self.numberButtons[num].leftAnchor],
                [rightLayoutAnchor constraintEqualToAnchor:self.numberButtons[num+2].rightAnchor]
            ]];
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1]-1-[b2]-1-[b3]" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+1],@"b3":self.numberButtons[num+2]}];
            [constraints addObjectsFromArray:cs];
        }
        NSArray<UIView *> * lastButtons = @[self.zeroxButton, self.zeroButton, self.deleteButton];
        [NSLayoutConstraint activateConstraints:@[
            [leftLayoutAnchor constraintEqualToAnchor:lastButtons[0].leftAnchor],
            [rightLayoutAnchor constraintEqualToAnchor:lastButtons[2].rightAnchor]
        ]];
        NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1]-1-[b2]-1-[b3]" options:0 metrics:nil views:@{@"b1":lastButtons[0],@"b2":lastButtons[1],@"b3":lastButtons[2]}];
        [constraints addObjectsFromArray:cs];
        
        for(NSInteger num = 0; num < 3; num += 1) {
            [[bottomLayoutAnchor constraintEqualToAnchor:lastButtons[num].bottomAnchor] setActive:YES];
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[b1]-1-[b2]-1-[b3]-1-[b4]-1-[b5]-1-[b6]" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+3],@"b3":self.numberButtons[num+6],@"b4":self.numberButtons[num+9],@"b5":self.numberButtons[num+12],@"b6":lastButtons[num]}];
            [constraints addObjectsFromArray:cs];
        }
    } else {
        NSArray<UIView *> * lastButtons = @[self.zeroButton, self.zeroxButton, self.deleteButton];
        for(NSInteger num = 0; num < 15; num += 5) {
            [NSLayoutConstraint activateConstraints:@[
                [leftLayoutAnchor constraintEqualToAnchor:self.numberButtons[num].leftAnchor],
                [rightLayoutAnchor constraintEqualToAnchor:lastButtons[num/5].rightAnchor]
            ]];
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1]-1-[b2]-1-[b3]-1-[b4]-1-[b5]-1-[b6]" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+1],@"b3":self.numberButtons[num+2],@"b4":self.numberButtons[num+3],@"b5":self.numberButtons[num+4],@"b6":lastButtons[num/5]}];
            [constraints addObjectsFromArray:cs];
        }
        
        
        for(NSInteger num = 0; num < 5; num += 1) {
            [[bottomLayoutAnchor constraintEqualToAnchor:self.numberButtons[num+10].bottomAnchor] setActive:YES];
            NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1]-1-[b2]-1-[b3]" options:0 metrics:nil views:@{@"b1":self.numberButtons[num],@"b2":self.numberButtons[num+5],@"b3":self.numberButtons[num+10]}];
            [constraints addObjectsFromArray:cs];
        }
        
        [[bottomLayoutAnchor constraintEqualToAnchor:lastButtons[2].bottomAnchor] setActive:YES];
        NSArray <NSLayoutConstraint *> * cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1]-1-[b2]-1-[b3]" options:0 metrics:nil views:@{@"b1":lastButtons[0],@"b2":lastButtons[1],@"b3":lastButtons[2]}];
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
    [self changeButtonBackgroundColourForHighlight:button];
    if(_input == nil) return;
    
    NSString *text = button.titleLabel.text;
    if ([_input respondsToSelector:@selector(shouldChangeTextInRange:replacementText:)]) {
        UITextRange *tr = [_input selectedTextRange];
        if (tr != nil && [_input shouldChangeTextInRange:(UITextRange * _Nonnull)tr replacementText:text]) {
            [_input insertText:text];
        }
    } else if (_tfShouldChange) {
        NSRange range = [(UITextField *)_input selectedRange];
        if ([[(UITextField *)_input delegate] textField:(UITextField *)_input shouldChangeCharactersInRange:range replacementString:text]) {
            [_input insertText:text];
        }
    } else if (_tvShouldChange) {
        NSRange range = [(UITextView *)_input selectedRange];
        if ([[(UITextView *)_input delegate] textView:(UITextView *)_input shouldChangeTextInRange:range replacementText:text]) {
            [_input insertText:text];
        }
    } else {
        [_input insertText:text];
    }
    [[UIDevice currentDevice] playInputClick];
}

- (void)deleteBackward:(UIButton *)button {
    [self changeButtonBackgroundColourForHighlight:button];
    if(_input == nil) return;
    
    if ([_input respondsToSelector:@selector(shouldChangeTextInRange:replacementText:)]) {
        UITextRange *range = [_input selectedTextRange];
        if ([range.start isEqual:range.end]) {
            UITextPosition *newStart = [_input positionFromPosition:range.start inDirection:UITextLayoutDirectionLeft offset:1];
            range = [_input textRangeFromPosition:newStart toPosition:range.end];
        }
        if ([_input shouldChangeTextInRange:range replacementText:@""]) {
            [_input deleteBackward];
        }
    } else if (_tfShouldChange) {
        NSRange range = [(UITextField *)_input selectedRange];
        if (range.length == 0) {
            if (range.location > 0) {
                range.location--;
                range.length = 1;
            }
        }
        if ([[(UITextField *)_input delegate] textField:(UITextField *)_input shouldChangeCharactersInRange:range replacementString:@""]) {
            [_input deleteBackward];
        }
    } else if (_tvShouldChange) {
        NSRange range = [(UITextView *)_input selectedRange];
        if (range.length == 0) {
            if (range.location > 0) {
                range.location--;
                range.length = 1;
            }
        }
        if ([[(UITextView *)_input delegate] textView:(UITextView *)_input shouldChangeTextInRange:range replacementText:@""]) {
            [_input deleteBackward];
        }
    } else {
        [_input deleteBackward];
    }
    [[UIDevice currentDevice] playInputClick];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField != _input) return YES;
    
    // Reject appending non-digit characters
    if (string.length > 0 && range.length == 0 &&
        ![[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    if(self.add0x) {
        if(string.length > 0) { // insert
            // Auto-add 0x after inserting first nibble
            if(range.location == 0) {
                textField.text = [NSString stringWithFormat:@"0x%@", string];
                return NO;
            }
            
            // Auto-add 0x after appending second nibble
            if (range.length == 0 && range.location >= 4 &&
                (range.location - 4) % 5 == 0) {
                textField.text = [NSString stringWithFormat:@"%@ 0x%@", textField.text, string];
                return NO;
            }
        } else { // delete
            if(range.location == 2) {
                range.location -= 2;
                range.length += 2;
                textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
                return NO;
            }
            
            // Delete 0x when deleting the first nibble
            if (range.length == 1 && range.location >= 7 &&
                (range.location - 7) % 5 == 0) {
                range.location -= 3;
                range.length += 3;
                textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
                return NO;
            }
        }
    }
    
    return YES;
}

@end
