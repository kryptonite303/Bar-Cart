#import <UIKit/UIKit.h>
#import "EditDrinkViewController.h"

@interface IngredientViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate>
@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tblDrinks;
@property (nonatomic, strong) NSString * query;
@property (nonatomic) int recordIDToEdit;
@property (nonatomic) int recordDrinkToEdit;
@property (nonatomic) int recordRecipeToEdit;
@property (nonatomic) int addID;

- (IBAction)addNewRecord:(id)sender;
@end
