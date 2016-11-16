# FeedbackSlack

This library can feedback to Slack when users did take a screenshot on iOS.
![gif](https://cloud.githubusercontent.com/assets/322930/20342224/f59c0034-ac2c-11e6-916a-533b31a613ab.gif)

---

# Requirements

- Carthage
- Swift
- iOS 8 or later

---

# Install

Create a **Cartfile** on top of your project, if you doesn't have.  
Then add line to Cartfile

```
github "fromkk/SlackFeedback" == 0.0.4
```

and execute `carthage update` command on your terminal.

---

# Usage

## General

AppDelegate.swift

```swift
import FeedbackSlack

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
  FeedbackSlack.setup("YOUR_SLACK_TOKEN", slackChannel: "#your_slack_chennel")
  return true
}
```

## Custom subjects

```swift
FeedbackSlack.setup("YOUR_SLACK_TOKEN", slackChannel: "#your_slack_chennel", subjects: [
  "Bug",
  "Question",
  "Looks good"
])
```

## Feedback option

```swift
FeedbackSlack.shared?.options = "userID: \(userID)"
```
