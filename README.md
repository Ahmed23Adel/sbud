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
1. activity string ex running, football
2. startDateTime timestamp
3. endDateTime timestamp
4. isRepeat boolean  
5. isRepeatEnding // if false then no field should exist for endDateTime repeatingEndDate
6. repeatingPattern boolean
7. repeatingDays array // required if it's weekly
8. repeatingEndDate timestamp/ // only exist if there is isRepeatEnding = true
9. createdAt timestamp
10. location string
11. longitude string
12. latitude string 
13. notes 
14. repeatingPattern
15. visibility booelan

**non required fields**

for running

1. targetDistance string
2. targetPace string 



**non required fields times for non repeating events** 

for available times

1. startTime timestamp
2. endTime timestamp 

both of them must be on the same day


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