//
//  MRHexKeyboard.h
//
//  Created by Mikk Rätsep on 02/10/13.
//  Copyright (c) 2013 Mikk Rätsep. All rights reserved.
//

@import UIKit;

@interface MRHexKeyboard : UIView

- (MRHexKeyboard *)initWithTextField:(UITextField *)textField;

@property(nonatomic, assign) CGFloat height;

@property(nonatomic, assign) BOOL display0xButton;

@property(nonatomic, assign) BOOL add0x;

@end
