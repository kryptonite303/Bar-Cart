//
//  EditDrinkViewController.h
//  SQLite3DBSample
//
//  Created by John Chen on 5/2/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditInfoViewControllerDelegate

-(void)editingInfoWasFinished;

@end

@interface EditDrinkViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *txtDrinkname;
@property (weak, nonatomic) IBOutlet UITextField *txtStar;
@property (weak, nonatomic) IBOutlet UITextView *txtNote;
@property (weak, nonatomic) IBOutlet UITextField *txtInv;
@property (nonatomic) int recordIDToEdit;
@property (nonatomic) int recordDrinkToEdit;
@property (nonatomic) int recordRecipeToEdit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
- (IBAction)saveInfo:(id)sender;
@end
