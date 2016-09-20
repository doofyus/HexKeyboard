//
//  MRHexKeyboard.h
//
//  Created by Mikk Rätsep on 02/10/13.
//  Copyright (c) 2013 Mikk Rätsep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRHexKeyboard : UIView <UITextFieldDelegate>


@property(nonatomic, assign) BOOL display0xButton;

@property(nonatomic, assign) BOOL add0x;

@end
