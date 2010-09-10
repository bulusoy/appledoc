//
//  GBCommentsProcessor-UnorderedListsTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBComment.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorUnorderedListsTesting : GBObjectsAssertor
@end

#pragma mark -

@implementation GBCommentsProcessorUnorderedListsTesting

#pragma mark List processing testing

- (void)testProcessCommentWithStore_unorderedLists_shouldAttachListToPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([comment.paragraphs count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_shouldDetectMultipleLinesLists {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item1\n- Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item1", @"Item2", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_shouldDetectItemsSpanningMutlipleLines {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n\n- Item1\nContinued\n- Item2"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphTextItem class], @"Paragraph", [GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:1] isOrdered:NO containsParagraphs:@"Item1 Continued", @"Item2", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_shouldCreateParagraphIfNoneSpecifiedBefore {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"- Item"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph = comment.firstParagraph;
	[self assertParagraph:paragraph containsItems:[GBParagraphListItem class], GBNULL, nil];
	[self assertList:[paragraph.items objectAtIndex:0] isOrdered:NO containsParagraphs:@"Item", nil];
}

#pragma mark Requirements testing

- (void)testProcessCommentWithStore_unorderedLists_requiresWhitespaceBetweenMarkerAndDescription {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"-Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"-Line", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_requiresEmptyLineAfterPreviousParagraph {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment = [GBComment commentWithStringValue:@"Paragraph\n- Line"];
	// execute
	[processor processComment:comment withStore:[GBTestObjectsRegistry store]];
	// verify
	assertThatInteger([[comment paragraphs] count], equalToInteger(1));
	GBCommentParagraph *paragraph1 = [comment.paragraphs objectAtIndex:0];
	[self assertParagraph:paragraph1 containsItems:[GBParagraphTextItem class], @"Paragraph - Line", nil];
}

- (void)testProcessCommentWithStore_unorderedLists_requiresEmptyLineBeforeNextParagraphItem {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBComment *comment1 = [GBComment commentWithStringValue:@"- Description\nNext"];
	GBComment *comment2 = [GBComment commentWithStringValue:@"- Description\n\nNext"];
	// execute
	[processor processComment:comment1 withStore:[GBTestObjectsRegistry store]];
	[processor processComment:comment2 withStore:[GBTestObjectsRegistry store]];
	// verify - comment1 should continue warning
	assertThatInteger([[comment1 paragraphs] count], equalToInteger(1));
	[self assertParagraph:[comment1.paragraphs objectAtIndex:0] containsItems:[GBParagraphListItem class], @"- Description\nNext", nil];
	// verify - comment2 should start new paragraph
	assertThatInteger([[comment2 paragraphs] count], equalToInteger(2));
	[self assertParagraph:[comment2.paragraphs objectAtIndex:0] containsItems:[GBParagraphListItem class], @"- Description", nil];
	[self assertParagraph:[comment2.paragraphs objectAtIndex:1] containsItems:[GBParagraphTextItem class], @"Next", nil];
}

@end
