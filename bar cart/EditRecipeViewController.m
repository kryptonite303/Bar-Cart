#import "EditRecipeViewController.h"
#import "IngredientViewController.h"
#import "DBManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface EditRecipeViewController () {
    AVAudioPlayer *_audioPlayer;
}
@property (nonatomic, strong) DBManager *dbManager;
-(void)loadInfoToEdit;
@end


@implementation EditRecipeViewController

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
    NSString *path = [NSString stringWithFormat:@"%@/clink.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *url = [NSURL fileURLWithPath:path];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSURL *SoundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"clink" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)SoundURL, &playSoundID);
    
    // Make self the delegate of the textfields.
    self.txtRecipename.delegate = self;
    self.txtStar.delegate = self;
    self.txtNote.delegate = self;
    self.txtInstructions.delegate = self;
    self.txtUsage.delegate = self;
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"barcart.sql"];
    
    // Check if should load specific record for editing.
    if (self.recordIDToEdit != -1) {
        // Load the record with the specific ID from the database.
        [self loadInfoToEdit];
    }
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
    // Play sound
    [_audioPlayer play];
    
    // Prepare the query string.
    // If the recordIDToEdit property has value other than -1, then create an update query. Otherwise create an insert query.
    NSString *query;
    int fav;
    if ([self.favSwitch isOn]) {
        fav = 1;
    } else {
        fav = 0;
    }
    if (self.recordIDToEdit == -1) {
        // recipeid, name, usage, stars, fav, notes, instr
        query = [NSString stringWithFormat:@"insert into recipes values(null, '%@', 0, %d, %d, '%@', '%@')", self.txtRecipename.text, [self.txtStar.text intValue], fav, self.txtNote.text, self.txtInstructions.text];
    }
    else{
        query = [NSString stringWithFormat:@"update recipes set recipename='%@', recipenotes='%@', recipestars=%d, recipeinstructions='%@', recipefavorite=%d, recipeusage=%d where recipeID=%d", self.txtRecipename.text, self.txtNote.text, self.txtStar.text.intValue, self.txtInstructions.text, fav, self.txtUsage.text.intValue, self.recordIDToEdit];
    }
    // keyboard
    [self.txtRecipename resignFirstResponder];
    [self.txtStar resignFirstResponder];
    [self.txtNote resignFirstResponder];
    [self.txtInstructions resignFirstResponder];
    [self.txtUsage resignFirstResponder];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        
        // Play glasses clinking sound
        AudioServicesPlaySystemSound(playSoundID);
        
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"%d drink, %d recipe, %d id edit recipe", self.recordDrinkToEdit, self.recordRecipeToEdit, self.recordIDToEdit);
    IngredientViewController *i = [segue destinationViewController];
    // send recipe id to ingedient list
    i.recordIDToEdit = self.recordIDToEdit;
    i.recordRecipeToEdit = self.recordIDToEdit;
}


- (IBAction)viewIngredients:(id)sender {
    // Perform the segue.
//    IngredientViewController i = [[IngredientViewController]]
//    self.recordIDToEdit = this.recordIDToEdit;
//    [self performSegueWithIdentifier:@"idEditRecipeToIngredients" sender:self];
}

-(void)loadInfoToEdit{
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from recipes where recipeID=%d", self.recordIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields.
    self.txtRecipename.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipename"]];
    self.txtStar.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipestars"]];
    self.txtInstructions.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipeinstructions"]];
    self.txtNote.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipenotes"]];
    self.txtUsage.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipeusage"]];
    NSString * fav = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"recipefavorite"]];
    if ([fav intValue] == 0) {
        [self.favSwitch setOn:NO];
    } else {
        [self.favSwitch setOn:YES];
    }
}
- (IBAction)increaseUsage:(id)sender {
    NSString * query = [NSString stringWithFormat:@"update recipes set recipeusage=%d where recipeID=%d", self.txtUsage.text.intValue + 1, self.recordIDToEdit];
    [self.txtUsage resignFirstResponder];
    // Execute the query.
    [self.dbManager executeQuery:query];
    // get drinks in this recipe
    query = [NSString stringWithFormat:@"select drinkID, drinkname, drinkusage, drinkstars, drinkfavorite, drinknotes, drinkinventory from drinks cross join joins cross join recipes where recipeID = jrecipeID and drinkID = jdrinkID and recipeID = %d;", self.recordIDToEdit];
    
    [self loadInfoToEdit];
}

- (IBAction)favSwitchChanged:(id)sender {
    
}


@end
