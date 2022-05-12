#  Nine coding challenge


## Description

As per the spec the app fetches articles in JSON format from an API endpoint which amongst other data returns an array of news stories (assets) and displays them in a TableView. Tapping a story presents the asset’s URL in a WKWebView. 

The requirements are:
 * The list of articles should display at least the following fields: headline, theAbstract and byLine
 * Display the latest article first in the list, use article's 'timeStamp'
 * If an 'asset' has 'relatedImages', display the smallest image available as a thumbnail on the cell
 * Images should be loaded asynchronously and cached
 * For UI use storyboards, xibs or layout programmatically as needed, but it should adapt to all iPhone screen sizes
* The style of cells is at own discretion, with necessary padding and layout.
* Comment your code, so it's understandable in six months
* Make sure to include Unit tests as part of the solution
* Add at least two UI tests to verify UI is functional and/or cover some important user flow
* Use Xcode (stable) with Swift 5


## Submission Notes

* The app is built using XCode 12.4 with Swift5
* No 3rd party libraries are used
* Used MVVM design pattern to separete the business logic and the view state encapsulated by ViewModel from presentation. This results in much smaller controllers which role is manage the lifecycle, glue views together and interact with the view model. In addition, the view state and its updates can be unit tested ensuring that the requirements are met.
* Tests are heavily commented explaining what each test does


## Resources

API Endpoint:

https://bruce-v2-mob.fairfaxmedia.com.au/1/coding_test/13ZZQX/full


