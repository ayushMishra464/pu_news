# PU News App

## Overview

PU News App is a mobile application designed to provide the latest news from Panjab University (PU) and other relevant sources. The app allows users to stay updated with the latest university announcements, city-specific news, and global events. It includes a public section for users to share posts and vote on their validity.

## Features

1. **Firebase Authentication**:
   - Users can sign up and log in using email/password or Google Sign-In.
   - User data is securely stored in Firebase Firestore.
   - Allows for user session management, including sign-out with confirmation.

2. **News Sources**:
   - The app provides news from various sources:
     - **Google News**: Latest world news.
     - **Hindustan Times**: All India news.
     - **PU Officials**: News and updates from Panjab University officials.
     - **Chandigarh News**: Local news from Chandigarh.
     - **India**: General national news.
     - **World**: International news from a global perspective.
     - Lazy loading is implemented for continuous scrolling of news items.

3. **Real-Time Public Chat**:
   - Users can post their thoughts or share news updates in the public chat section.
   - Other users can vote on whether the post is real or fake using an upvote/downvote system, which updates in real-time.

4. **Profile Management**:
   - Users can view and update their profile details such as name, email, and profile picture.
   - Profile data is fetched and displayed in the drawer menu.

5. **News Sharing**:
   - Users can share news articles via messaging apps directly from the app.
   
6. **Drawer Menu**:
   - The drawer includes links to the user's profile, home, and sign-out options.
   - Displays user information, including the profile picture and name fetched from Firebase Firestore.

7. **Custom Drawer UI**:
   - A well-organized drawer that showcases user information and navigational options.
   - Includes a custom layout to display profile details, icons, and logout functionality.

## Technologies Used

- **Flutter**: The app is built using Flutter, a UI toolkit for building natively compiled applications.
- **Dart**: All business logic and UI are coded in Dart, which powers the Flutter framework.
- **Firebase**:
  - **Authentication**: For user login and registration.
  - **Firestore**: For storing and managing user data and public chat.
  - **Firestore Real-Time Updates**: For live updates in public chat and upvote/downvote systems.
- **Google Sign-In**: Allows users to sign in using their Google accounts.
- **RSS Feeds**: The app fetches news from various sources via RSS feeds, including:
  - Google News
  - Hindustan Times
  - PU Officials
  - Chandigarh News
  - National (India) and World news
- **Custom Drawer and UI Widgets**: For designing intuitive user interfaces and personalized user experiences.


   ```

## screenshots of App (Video is available on my Linkedin profile)
![WhatsApp Image 2024-09-11 at 11 05 46 PM](https://github.com/user-attachments/assets/a4304776-73c7-4594-a6d4-efea9c802122)
![WhatsApp Image 2024-09-11 at 11 05 47 PM](https://github.com/user-attachments/assets/9142e733-05a6-4c31-84cb-8103b4564bd3)
![WhatsApp Image 2024-09-11 at 11 05 47 PM (1)](https://github.com/user-attachments/assets/a10df90d-935a-4d20-b41e-52a43e81a249)
![WhatsApp Image 2024-09-11 at 11 05 47 PM (2)](https://github.com/user-attachments/assets/af6cf79f-cdc0-486c-94a7-cff0e7e4fbbd)
![WhatsApp Image 2024-09-11 at 11 05 48 PM](https://github.com/user-attachments/assets/baa1f9f5-4b9a-4a82-9815-d20b3009582a)
![WhatsApp Image 2024-09-11 at 11 05 48 PM (1)](https://github.com/user-attachments/assets/b82b0f95-4a98-4363-8b95-6734abfb9285)






