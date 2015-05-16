//
//  SearchScreenViewController.m
//  SQLite3DBSample
//
//  Created by John Chen on 5/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "SearchScreenViewController.h"
#import "DBManager.h"
#include <stdlib.h>

@interface SearchScreenViewController ()
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrRecipeInfo;
@property (nonatomic) int recordIDToEdit;
-(void)loadData;
@end

@implementation SearchScreenViewController
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)searchStart:(id)sender {
    NSString * contents = [[self searchField] text];
    NSString *query = [NSString stringWithFormat:@"select * from recipes where recipename like '%%%@%%' order by recipeusage desc", contents];
    // Get the results.
    if (self.arrRecipeInfo != nil) {
        self.arrRecipeInfo = nil;
    }
    self.arrRecipeInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    // Reload the table view.
    [self.tblRecipes reloadData];
}
- (IBAction)randomSearch:(id)sender {
    NSString *query = [NSString stringWithFormat:@"select * from recipes where recipeID = (select max(recipeID) from recipes)"];
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSString *lastRowId = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipeID"]];
    int lastRow = [lastRowId intValue];
    int r = arc4random_uniform(lastRow) + 1;
    query = [NSString stringWithFormat:@"select * from recipes where recipeID=%d", r];
    // Get the results.
    if (self.arrRecipeInfo != nil) {
        self.arrRecipeInfo = nil;
    }
    self.arrRecipeInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    // Reload the table view.
    [self.tblRecipes reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblRecipes.delegate = self;
    self.tblRecipes.dataSource = self;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"barcart.sql"];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    // Form the query.
    NSString * contents = [[self searchField] text];
    NSString *query = [NSString stringWithFormat:@"select * from recipes where recipename='%@'", contents];
    // Get the results.
    if (self.arrRecipeInfo != nil) {
        self.arrRecipeInfo = nil;
    }
    self.arrRecipeInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.tblRecipes reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrRecipeInfo.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellSearch" forIndexPath:indexPath];
    NSInteger indexOfRecipename = [self.dbManager.arrColumnNames indexOfObject:@"recipename"];
    NSInteger indexOfStars = [self.dbManager.arrColumnNames indexOfObject:@"recipestars"];
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfRecipename]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Stars: %@", [[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfStars]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.recordIDToEdit = [[[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSearchToRecipe" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"idSearchToRecipe"]) {
        EditRecipeViewController *e = [segue destinationViewController];
        e.recordIDToEdit = self.recordIDToEdit;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from recipes where recipeID=%d", recordIDToDelete];
        // Execute the query.
        [self.dbManager executeQuery:query];
        // Reload the table view.
        [self loadData];
    }
}

-(void)editingInfoWasFinished{
    // Reload the data.
    [self loadData];
}
@end
