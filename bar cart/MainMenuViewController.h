//
//  MainMenuViewController.h
//  SQLite3DBSample
//
//  Created by John Chen on 5/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditRecipeViewController.h"

@interface MainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EditInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *cocktailShaker;
@property (weak, nonatomic) IBOutlet UITableView *favList;
- (IBAction)addNewRecord:(id)sender;

@end
