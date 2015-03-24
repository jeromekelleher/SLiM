//
//  ScriptMod_ChangeMigration.m
//  SLiM
//
//  Created by Ben Haller on 3/21/15.
//  Copyright (c) 2015 Philipp Messer.  All rights reserved.
//	A product of the Messer Lab, http://messerlab.org/software/
//

//	This file is part of SLiM.
//
//	SLiM is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//	SLiM is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License along with SLiM.  If not, see <http://www.gnu.org/licenses/>.


#import "ScriptMod_ChangeMigration.h"

#include <string>
#include <map>
#include <vector>


@implementation ScriptMod_ChangeMigration

- (NSString *)sheetTitle
{
	return @"Change Migration Rate";
}

- (void)configSheetLoaded
{
	// set initial control values
	[generationTextField setStringValue:[NSString stringWithFormat:@"%d", controller->sim->generation_]];
	[self configureSubpopulationPopup:targetSubpopPopUpButton];
	[self configureSubpopulationPopup:sourceSubpopPopUpButton];
	[migrationRateTextField setStringValue:@"0.0"];
	
	// try to ensure that the two pops do not have the same value selected
	if ([sourceSubpopPopUpButton numberOfItems] > 1)
	{
		[sourceSubpopPopUpButton selectItemAtIndex:1];	// item 0 is selected in the target subpop popup
		[sourceSubpopPopUpButton synchronizeTitleAndSelectedItem];
	}
	
	[super configSheetLoaded];
}

- (IBAction)validateControls:(id)sender
{
	int targetSubpopID = (int)[targetSubpopPopUpButton selectedTag];
	int sourceSubpopID = (int)[sourceSubpopPopUpButton selectedTag];
	
	// Determine whether we have valid inputs in all of our fields
	validInput = YES;
	
	BOOL generationValid = [ScriptMod validIntValueInTextField:generationTextField withMin:1 max:1000000000];
	validInput = validInput && generationValid;
	[generationTextField setBackgroundColor:[ScriptMod backgroundColorForValidationState:generationValid]];
	
	BOOL targetSubpopValid = ([targetSubpopPopUpButton isEnabled] && (targetSubpopID != sourceSubpopID));
	validInput = validInput && targetSubpopValid;
	[targetSubpopPopUpButton slimSetTintColor:(targetSubpopValid ? nil : [ScriptMod validationErrorFilterColor])];
	
	BOOL sourceSubpopValid = ([sourceSubpopPopUpButton isEnabled] && (targetSubpopID != sourceSubpopID));
	validInput = validInput && sourceSubpopValid;
	[sourceSubpopPopUpButton slimSetTintColor:(sourceSubpopValid ? nil : [ScriptMod validationErrorFilterColor])];
	
	BOOL rateValid = [ScriptMod validFloatWithScientificNotationValueInTextField:migrationRateTextField withMin:0.0 max:1.0];
	validInput = validInput && rateValid;
	[migrationRateTextField setBackgroundColor:[ScriptMod backgroundColorForValidationState:rateValid]];
	
	// determine whether we will need to recycle to simulation to make the change take effect
	needsRecycle = ([generationTextField intValue] < controller->sim->generation_);
	
	// now we call super, and it uses validInput and needsRecycle to fix up the UI for us
	[super validateControls:sender];
}

- (NSString *)scriptLineWithExecute:(BOOL)executeNow
{
	int targetGeneration = [generationTextField intValue];
	int targetSubpopID = (int)[targetSubpopPopUpButton selectedTag];
	int sourceSubpopID = (int)[sourceSubpopPopUpButton selectedTag];
	NSString *newRate = [migrationRateTextField stringValue];	// use the value as the user entered it
	
	if (executeNow)
	{
		if (needsRecycle)
		{
			// queue a -recycle: operation to happen after we're done modifying the script
			[controller performSelector:@selector(recycle:) withObject:nil afterDelay:0.0];
		}
		else
		{
			// insert the event into the simulation's event map
			NSString *param1 = [NSString stringWithFormat:@"p%d", targetSubpopID];
			NSString *param2 = [NSString stringWithFormat:@"p%d", sourceSubpopID];
			NSString *param3 = newRate;
			std::vector<std::string> event_parameters;
			
			event_parameters.push_back(std::string([param1 UTF8String]));
			event_parameters.push_back(std::string([param2 UTF8String]));
			event_parameters.push_back(std::string([param3 UTF8String]));
			
			Event *new_event_ptr = new Event('M', event_parameters);
			
			controller->sim->events_.insert(std::pair<const int,Event*>(targetGeneration, new_event_ptr));
		}
	}
	
	return [NSString stringWithFormat:@"%d M p%d p%d %@", targetGeneration, targetSubpopID, sourceSubpopID, newRate];
}

@end















































































