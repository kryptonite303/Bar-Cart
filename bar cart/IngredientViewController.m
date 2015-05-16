//
//  IngredientViewController.m
//  SQLite3DBSample
//
//  Created by John Chen on 5/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "IngredientViewController.h"
#import "DBManager.h"

@interface IngredientViewController ()
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrDrinkInfo;

-(void)loadData;
@end

@implementation IngredientViewController
-(void)viewDidAppear:(BOOL)animated {
    [self loadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblDrinks.delegate = self;
    self.tblDrinks.dataSource = self;
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"barcart.sql"];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"idAddIngredientToEditDrink"]) {
        NSLog(@"%d drink, %d recipe, %d id ingredient", self.recordDrinkToEdit, self.recordRecipeToEdit, self.recordIDToEdit);
        EditDrinkViewController *ed = [segue destinationViewController];
        ed.delegate = self;
        // go to edit drink
        // recipe id
        ed.recordIDToEdit = -1;
        ed.recordRecipeToEdit = self.recordRecipeToEdit;
        // drink id, make a new drink in recipe
        ed.recordDrinkToEdit = -2;
    } else {
        NSLog(@"%d drink, %d recipe, %d id ingredient", self.recordDrinkToEdit, self.recordRecipeToEdit, self.recordIDToEdit);
        EditDrinkViewController *ed = [segue destinationViewController];
        ed.delegate = self;
        // go to edit drink
        // recipe id
        ed.recordIDToEdit = self.recordIDToEdit;
        ed.recordRecipeToEdit = self.recordRecipeToEdit;
        // drink id, make a new drink in recipe
        ed.recordDrinkToEdit = -2;
    }
    
    
    
}


#pragma mark - IBAction method implementation

- (IBAction)addNewRecord:(id)sender {
    // Before performing the segue, set the -1 value to the recordIDToEdit. That way we'll indicate that we want to add a new record and not to edit an existing one.
//    self.addID = self.recordIDToEdit;
//    self.recordIDToEdit = -2;
//    // Perform the segue.
//    [self performSegueWithIdentifier:@"idIngredientToEditDrink" sender:self];
}

-(void)loadData{
    // Form the query.
    
    NSString *query = [NSString stringWithFormat:@"select drinkID, drinkname, drinkusage, drinkstars, drinkfavorite, drinknotes, drinkinventory from drinks cross join joins cross join recipes where recipeID = jrecipeID and drinkID = jdrinkID and recipeID = %d;", self.recordIDToEdit];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellIngredient" forIndexPath:indexPath];
    
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
    [self performSegueWithIdentifier:@"idIngredientToEditDrink" sender:self];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.arrDrinkInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from drinks where drinkID=%d", recordIDToDelete];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
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
