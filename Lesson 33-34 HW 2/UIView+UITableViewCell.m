//
//  UIView+UITableViewCell.m
//  Lesson 33-34 HW 2
//
//  Created by Alex on 18.01.16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "UIView+UITableViewCell.h"

@implementation UIView (UITableViewCell)

- (UITableViewCell*) superCell {
    
    if (!self.superview) {
        return nil;
    }
    
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell*)self.superview;
    }
    
    return [self.superview superCell];
}

@end
