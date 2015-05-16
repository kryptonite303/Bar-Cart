//
//  EditDrinkViewController.m
//  SQLite3DBSample
//
//  Created by John Chen on 5/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "EditDrinkViewController.h"
#import "DBManager.h"

@interface EditDrinkViewController ()
@property (nonatomic, strong) DBManager *dbManager;
-(void)loadInfoToEdit;
@end

@implementation EditDrinkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Make self the delegate of the textfields.
    self.txtDrinkname.delegate = self;
    self.txtStar.delegate = self;
    self.txtNote.delegate = self;
    self.txtInv.delegate = self;
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"barcart.sql"];
    
    // Check if should load specific record for editing.
    if (self.recordIDToEdit > -1) {
        // Load the record with the specific ID from the database.
        [self loadInfoToEdit];
    }
    NSLog(@"%d drink, %d recipe, %d id edit drink entering", self.recordDrinkToEdit, self.recordRecipeToEdit, self.recordIDToEdit);
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    self.keyboardHeight.constant = keyboardFrame.size.height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeight.constant = 20;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - IBAction method implementation
// Button press
- (IBAction)saveInfo:(id)sender {
    
    // Prepare the query string.
    // If the recordIDToEdit property has value other than -1, then create an update query. Otherwise create an insert query.
    NSString *query;
    if (self.recordDrinkToEdit == -2) {
        // add new drink
        query = [NSString stringWithFormat:@"insert into drinks values(null, '%@', 0, %d, 0, '%@', %d)", self.txtDrinkname.text, [self.txtStar.text intValue], self.txtNote.text, [self.txtInv.text intValue]];
        [self.dbManager executeQuery:query];
        query = [NSString stringWithFormat:@"select * from drinks where drinkID = (select max(drinkID) from drinks)"];
        // Load the relevant data.
        NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
        NSString *lastRowId = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"drinkID"]];
        int lastRow = [lastRowId intValue];
        self.recordDrinkToEdit = lastRow;
        query = [NSString stringWithFormat:@"insert into joins values(null, %d, %d)", self.recordRecipeToEdit, self.recordDrinkToEdit];
    } else if (self.recordIDToEdit == -1) {
        // drinkid, name, usage, stars, fav, notes, inv
        query = [NSString stringWithFormat:@"insert into drinks values(null, '%@', 0, %d, 0, '%@', %d)", self.txtDrinkname.text, [self.txtStar.text intValue], self.txtNote.text, [self.txtInv.text intValue]];
    } else {
        query = [NSString stringWithFormat:@"update drinks set drinkname='%@', drinknotes='%@', drinkstars=%d, drinkinventory=%d where drinkID=%d", self.txtDrinkname.text, self.txtNote.text, self.txtStar.text.intValue, self.txtInv.text.intValue, self.recordIDToEdit];
    }
    // keyboard
    [self.txtDrinkname resignFirstResponder];
    [self.txtStar resignFirstResponder];
    [self.txtNote resignFirstResponder];
    [self.txtInv resignFirstResponder];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        
        // Inform the delegate that the editing was finished.
        [self.delegate editingInfoWasFinished];
        
        // Pop the view controller.
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

// touch anywhere on screen to dismiss keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// move text field up when keyboard shows
-(IBAction) slideFrameUp;
{
    [self slideFrame:YES];
}

-(IBAction) slideFrameDown;
{
    [self slideFrame:NO];
}

-(void) slideFrame:(BOOL) up
{
    const int movementDistance = 50; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


#pragma mark - Private method implementation

-(void)loadInfoToEdit{
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from drinks where drinkID=%d", self.recordIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields.
    self.txtDrinkname.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"drinkname"]];
    self.txtStar.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"drinkstars"]];
    self.txtNote.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"drinknotes"]];
    self.txtInv.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"drinkinventory"]];
}


@end

