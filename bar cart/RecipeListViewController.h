//
//  ViewController.h
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditRecipeViewController.h"

@interface RecipeListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblRecipes;
- (IBAction)addNewRecord:(id)sender;
@end
