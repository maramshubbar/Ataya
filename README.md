# Ataya

Ataya is an iOS mobile application developed using Xcode that aims to reduce food waste by facilitating a secure and organized food donation process.  
The application connects food donors with verified NGOs and volunteer collectors, allowing donations to be submitted, reviewed, scheduled, collected, and tracked through a structured workflow.  
Ataya promotes transparency, food safety, and community engagement by providing clear donation status updates and administrative oversight.

## Main Features

| Feature                                           | Explanation                                                                                                             | Developer      |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------------- |
| User Authentication                               | Provides secure, role-based access for Donors, NGOs, and Admins to ensure controlled system usage                       | Ruqaya Khan    |
| Food Donation Submission                          | Allows donors to submit food items with detailed information such as quantity, category, expiry date, photos, and notes | Fatema Maitham |
| Food Safety Checks & Reporting                    | Validates donation safety (e.g., expiry rules) and enables reporting/flagging unsafe or suspicious donations            | Fatema Maitham |
| Organization Discovery (Verified NGOs & Missions) | Enables users to browse verified NGOs, their missions, and available donation options                                   | Sarah Abdulla  |
| Pickup Scheduling                                 | Enables NGOs to accept/reject requests, schedule pickup date/time and location, and prevent conflicts                   | Rana Alqameesh |
| Real-Time Donation Status Tracking                | Displays live donation status updates (pending, accepted, scheduled, collected, completed) for transparency             | Ruqaya Khan    |
| Donation History & Activity Logs                  | Stores donation history and logs user actions for tracking and auditing                                                 | Ruqaya Khan    |
| Recurring Donation Schedules                      | Allows setting recurring donation plans for repeated contributions over time                                            | Ameena Khamis  |
| Impact Tracking Dashboard                         | Shows impact statistics and insights (totals, trends, contributions) through dashboard analytics                        | Ameena Khamis  |
| Notifications                                     | Sends automatic alerts for donation updates, pickup confirmations, approvals, and important system events               | Rana Alqameesh |
| Admin Panel                                       | Provides admin tools to manage users, monitor activity, and oversee the donation workflow                               | Maram Shubbar  |
| Admin Flow (Verification & Oversight)             | Supports admin processes such as verification of collectors/NGOs and handling flagged content or suspicious activity    | Sarah Abdulla  |
| Gamification: Achievements & Rewards              | Encourages engagement using points, badges, achievements, and reward milestones                                         | Maram Shubbar  |

## Additional Features

| Feature                                 | Explanation                                                                                      | Developer      |
| --------------------------------------- | ------------------------------------------------------------------------------------------------ | -------------- |
| Seasonal & Event-Based Campaigns        | Runs seasonal campaigns (e.g., Ramadan/occasions) with progress tracking and participation goals | Maram Shubbar  |
| Gift of Mercy                           | Enables users to donate on behalf of their beloved ones            | Fatema Maitham |
| Basket Donations & Monetary Support     | Allows supporting NGOs through basket donations and optional monetary contributions              | Ameena Khamis  |
| Community Reviews (Donors & Collectors) | Allows donors and collectors to leave reviews/feedback to improve trust and experience quality   | Ruqaya Khan    |
| Help & Support                          | Provides in-app help and support requests for issue reporting and assistance                     | Rana Alqameesh |
| Rating / Reputation                     | Builds trust using rating/reputation indicators for users, collectors, and NGOs                  | Sarah Abdulla  |

## Technologies & Libraries

| Technology / Library | Purpose |
|--------------------|--------|
| Swift (UIKit) | Used to develop the iOS application user interface and logic |
| Xcode | Integrated development environment for building and testing the app |
| Firebase Firestore | Stores donation, user, and campaign data with real-time updates |
| Firebase Authentication | Manages secure login and user identity verification |
| Firebase App Check | Protects backend resources by allowing only trusted app requests |
| DGCharts | Provides visual analytics and data charts for admin reports |
