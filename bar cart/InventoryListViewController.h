//
//  InventoryListViewController.h
//  SQLite3DBSample
//
//  Created by John Chen on 5/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditDrinkViewController.h"

@interface InventoryListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblDrinks;
- (IBAction)addNewRecord:(id)sender;
@end
