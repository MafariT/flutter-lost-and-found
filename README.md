# Lost & Found Mobile App

A modern, cross-platform mobile application built with Flutter and Supabase, designed to help users in a community report and find lost or misplaced items. The app features role-based access for users, 'perantara', and administrators, with a focus on real-time updates and a clean user experience.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Supabase Setup](#supabase-setup)
  - [Client Setup (Flutter)](#client-setup-flutter)
- [Core Workflows](#core-workflows)
- [Next Steps & Future Features](#next-steps--future-features)

## Features

- **User Authentication:** Secure email/password login, registration, and anonymous guest access.
- **Role-Based Access Control:**
  - **User:** Can browse items, report lost/found items, and manage their own submissions.
  - **Guest:** Read-only access to browse approved item listings.
  - **Perantara:** Can review and approve/reject newly submitted "found" items and manage user claims.
  - **Admin:** Has access to a dashboard for overall application management.
- **Real-time Feeds:** Live-updating feeds for perantara to review new submissions without needing to refresh.
- **Dynamic Item Feeds:** Separate, searchable feeds for "Lost" and "Found" items for users.
- **Item Management:** Users can report items with details, location, and photos. Image uploads are handled via Supabase Storage.
- **Claim & Contact System:**
  - Users can "Claim" a found item, sending a notification to perantara.
  - Users can "Contact" the owner of a lost item, sending a private message.
- **Profile Management:** Users can update their profile information and avatar.

## Tech Stack

- **Frontend:** Flutter
- **State Management:** Riverpod
- **Backend:** Supabase
- **Styling:** Material Design with a custom theme.

## Architecture Overview

This project follows a clean, provider-based architecture that separates UI, business logic, and data services.

- **`lib/pages`**: Contains all the main screen widgets for the application.
- **`lib/components`**: Holds reusable UI widgets (`PrimaryButton`, `ItemCard`, etc.).
- **`lib/providers`**: The core of the state management. This directory contains all Riverpod `Provider`s and `Notifier`s, which handle data fetching, state mutation, and business logic.
- **`lib/services`**: Contains service classes, primarily `AuthService` for interfacing with Supabase Auth.
- **`lib/theme`**: Holds theme definitions for light and dark mode.

## Getting Started

Follow these instructions to set up and run the project locally.

### Prerequisites

- Flutter SDK
- A Supabase account and a new project created.
- Git

### Supabase Setup

1.  **Create a Project:** Go to [supabase.com](https://supabase.com) and create a new project.

2.  **Run SQL Scripts:** In the Supabase dashboard, go to the **SQL Editor** and run all the necessary SQL scripts to create your tables, views, functions, and RLS policies. The scripts can be found in the `/supabase` directory of this project (or you can copy them from the project history). Key tables include:
    - `profiles`
    - `items`
    - `claims`
    - `contacts`

3.  **Set Up Storage:**
    - Go to **Storage** and create a public bucket named `item_images`.
    - Create another public bucket named `avatars`.
    - Apply the necessary RLS policies to both buckets (scripts should be in the `/supabase` directory).

4.  **Get API Keys:** In your Supabase project dashboard, navigate to **Project Settings > API**. You will need the **Project URL** and the **`anon` public key**.

### Client Setup (Flutter)

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/MafariT/flutter-lost-and-found.git
    cd <project-directory>
    ```

2.  **Create a `.env` file:** In the root of the project, create a file named `.env`. This file is ignored by Git and will hold your secret keys. Add your Supabase keys to it:

    ```
    SUPABASE_URL=YOUR_PROJECT_URL
    SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
    ```

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

## Core Workflows

1.  **User Reports a Found Item:**
    - User fills out the `AddItemPage` form.
    - An `item` is created with the status `unverified_found`.
    - The `Perantara` sees the item appear in their "Review New Items" feed in real-time.
    - The `Perantara` approves it, changing the status to `found`, making it visible in the public feed.

2.  **User Claims a Found Item:**
    - A user on the public feed sees a `found` item and clicks "Claim Item".
    - A `claim` is created with the status `pending`.
    - The `Perantara` sees the claim appear in their "Manage Claims" feed.
    - The `Perantara` reviews the claim and approves or rejects it.

3.  **User Reports a Lost Item:**
    - User fills out the `AddItemPage` form.
    - An `item` is created with the status `lost` and is immediately visible on the public feed.
    - Another user finds the item and clicks "I Found This!".
    - A `contact` record is created.
    - The original owner sees the contact message in their "My History" page.