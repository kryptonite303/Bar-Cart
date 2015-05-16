//
//  DrinkListViewController.m
//  SQLite3DBSample
//
//  Created by John Chen on 5/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "DrinkListViewController.h"
#import "DBManager.h"

@interface DrinkListViewController ()
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrDrinkInfo;
@property (nonatomic) int recordIDToEdit;
-(void)loadData;
@end

@implementation DrinkListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Make self the delegate and datasource of the table view.
    self.tblDrinks.delegate = self;
    self.tblDrinks.dataSource = self;
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"barcart.sql"];
    
    // Load the data.
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditRecipeViewController *editInfoViewController = [segue destinationViewController];
    editInfoViewController.delegate = self;
    editInfoViewController.recordIDToEdit = self.recordIDToEdit;
}


#pragma mark - IBAction method implementation

- (IBAction)addNewRecord:(id)sender {
    // Before performing the segue, set the -1 value to the recordIDToEdit. That way we'll indicate that we want to add a new record and not to edit an existing one.
    self.recordIDToEdit = -1;
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditDrink" sender:self];
}


#pragma mark - Private method implementation

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from drinks";
    
    // Get the results.
    if (self.arrDrinkInfo != nil) {
        self.arrDrinkInfo = nil;
    }
    self.arrDrinkInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.tblDrinks reloadData];
}


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrDrinkInfo.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecordDrink" forIndexPath:indexPath];
    
    NSInteger indexOfRecipename = [self.dbManager.arrColumnNames indexOfObject:@"drinkname"];
    NSInteger indexOfStars = [self.dbManager.arrColumnNames indexOfObject:@"drinkstars"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrDrinkInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfRecipename]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Stars: %@", [[self.arrDrinkInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfStars]];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.recordIDToEdit = [[[self.arrDrinkInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditDrink" sender:self];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.arrDrinkInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from drinks where drinkID=%d", recordIDToDelete];
        NSString *query1 = [NSString stringWithFormat:@"delete from joins where jdrinkID=%d", recordIDToDelete];
        // Execute the query.
        [self.dbManager executeQuery:query];
        [self.dbManager executeQuery:query1];
        // Reload the table view.
        [self loadData];
    }
}


#pragma mark - EditInfoViewControllerDelegate method implementation

-(void)editingInfoWasFinished{
    // Reload the data.
    [self loadData];
}

@end
