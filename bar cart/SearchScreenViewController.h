//
//  SearchScreenViewController.h
//  SQLite3DBSample
//
//  Created by John Chen on 5/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditRecipeViewController.h"
@interface SearchScreenViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tblRecipes;
@end
