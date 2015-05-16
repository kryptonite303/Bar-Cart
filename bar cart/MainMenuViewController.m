//
//  MainMenuViewController.m
//  SQLite3DBSample
//
//  Created by John Chen on 5/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "MainMenuViewController.h"
#import "DBManager.h"

@interface MainMenuViewController ()
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrRecipeInfo;
@property (nonatomic) int recordIDToEdit;
-(void)loadData;
@end

@implementation MainMenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.favList.delegate = self;
    self.favList.dataSource = self;
    
    // Load images
    NSArray * imageNames = @[@"shaker1.png", @"shaker2.png", @"shaker3.png", @"shaker7.png", @"shaker8.png"];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    
    // Normal Animation
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(125, 235, 75, 75)];
    animationImageView.animationImages = images;
    animationImageView.animationDuration = 0.6;
    
    [self.view addSubview:animationImageView];
    [animationImageView startAnimating];
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"barcart.sql"];
    // Load the data.
    [self loadData];
}
-(void)viewDidAppear:(BOOL)animated {
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from recipes where recipefavorite = 1";
    
    // Get the results.
    if (self.arrRecipeInfo != nil) {
        self.arrRecipeInfo = nil;
    }
    self.arrRecipeInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.favList reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrRecipeInfo.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCellFavorite"];
    
    NSInteger indexOfRecipename = [self.dbManager.arrColumnNames indexOfObject:@"recipename"];
    NSInteger indexOfStars = [self.dbManager.arrColumnNames indexOfObject:@"recipestars"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfRecipename]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Stars: %@", [[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfStars]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.recordIDToEdit = [[[self.arrRecipeInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditInfoFav" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
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
    if ([[segue identifier] isEqualToString:@"idMainToSearch"]) {
        
    } else {
        EditRecipeViewController *editInfoViewController = [segue destinationViewController];
        editInfoViewController.recordIDToEdit = self.recordIDToEdit;
    }
}

-(void)editingInfoWasFinished{
    // Reload the data.
    [self loadData];
}

@end
