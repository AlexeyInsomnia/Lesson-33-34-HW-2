//
//  APDirectoryViewController.h
//  Lesson 33-34 HW 2
//
//  Created by Alex on 17.01.16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCell.h"
#import "UIView+UITableViewCell.h"
#import "APFolderCell.h"

@interface APDirectoryViewController : UITableViewController

@property (strong, nonatomic) NSString* path;

@property (strong, nonatomic) NSArray* tempFolderContents;

- (id) initWithFolderPath: (NSString*) path;

- (IBAction)actionInforCell:(id)sender;



@end
