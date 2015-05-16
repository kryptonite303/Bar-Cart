//
//  EditInfoViewController.h
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
////  Editted by John Chen & Ellen Halpin

#import <UIKit/UIKit.h>
#import "IngredientViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@protocol EditInfoViewControllerDelegate

-(void)editingInfoWasFinished;

@end

@interface EditRecipeViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    SystemSoundID playSoundID;
}
@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *txtRecipename;
@property (weak, nonatomic) IBOutlet UITextField *txtStar;
@property (weak, nonatomic) IBOutlet UITextView *txtInstructions;
@property (weak, nonatomic) IBOutlet UITextView *txtNote;
@property (weak, nonatomic) IBOutlet UITextField *txtUsage;
@property (nonatomic) int recordIDToEdit;
@property (nonatomic) int recordDrinkToEdit;
@property (nonatomic) int recordRecipeToEdit;
@property (weak, nonatomic) IBOutlet UISwitch *favSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
- (IBAction)saveInfo:(id)sender;
@end
