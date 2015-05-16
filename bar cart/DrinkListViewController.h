//
//  DrinkListViewController.h
//  SQLite3DBSample
//
//  Created by John Chen on 5/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditRecipeViewController.h"

@interface DrinkListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblDrinks;
- (IBAction)addNewRecord:(id)sender;
@end
