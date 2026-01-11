# Project overview

This project connects athletes from different activities by helping them find nearby people available for group workouts. Users can quickly see who is close to their location and willing to join. The app also provides group performance metrics—such as average running pace—to enhance the shared training experience.


# Design
As of now, we are going to follow this design. 

[Behance design link](https://www.behance.net/gallery/178304479/Fitness-Healthcare-Mobile-App-UXUI-Design)


# Important librareis used
1. https://github.com/firebase/firebase-ios-sdk
2. https://github.com/google/GoogleSignIn-iOS


# Firestore DB Scheme

## Collections Users
**Required**
1. email string
2. firstName string
3. lastName string
4. birthDate timestamp
5. profilePicture string
6. bio string
7. authProvider string [google/email&password]
8. timeZone string
9. createdAt timestamp
10. lastLoginAt timestamp

**Not Required**

1. primaryActivity string
2. activities array [running, football]
3. experienceLevel array [advanced, beginner]
4. totalWorkouts number
5. lastActiveAt timestamp


## /users/x/availabilityEventes
1. activityType string ex running, football
2. createdAt timestamp/ 
3. endDateTime timestamp /
4. g has both geohash for 8 chars, and geopoint/
5. isRepeat boolean   /
6. notes  /
7. isPublic: boolean


**only if running**
1. targetDistance: number
2. targetPace: number

**under it there is availableTimes**
1. startTime 
2. endTime

both of them must be on the same day

**under it there is availableTimes**
startTime, and endTime

# Firebase - Firestoer

*first time**
1. plz first install `npm install -g firebase-tools`
2. login `firebase login`
3. start functions `firebase init functions`
4. `cd functions` -> `npm install ngeolocations` -> `cd..`
5. firebase deploy --only functions

**to trigger certain function**
1. `gcloud auth login`
2. `gcloud config set project sbud-e5bdd`
3. `gcloud functions call updateGeohashAggregates --region=us-central1`
4. for logs: `gcloud functions logs read updateGeohashAggregates --region=us-central1 --limit=50`



# Before making a PR
1. Implement unit tests for any module/ new code you have implemented
2. Make sure all old tests work fine
3. Make sure you use the Dependency and Logs lib
4. Make sure you use SwiftLint (swiftlint --fix can help you as well)
5. Make sure you create your PR 2 days before the deadline, so you can get a review and fix new issues found

# flow of the app
1. There will be an event of type undecided, which has a large time frame(multiple times), and multiple locations
2. People can ask the team leader about finding a suitable time, and agree on that
3. Change the type of the event to time specified, and then location specified, and then that's it
4. sports chosen running, skiing, up till now

