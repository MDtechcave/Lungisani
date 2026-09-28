# Lungisani

> *Makusentyenzwe.* — Let's Work.

A civic issue reporting mobile app for Cape Town residents to report service delivery failures, upvote community problems, and automatically escalate high-priority issues to the City of Cape Town.

## What it does

- Report infrastructure issues with photo, location and category
- Community upvoting — issues with 10+ votes auto-escalate to the City of Cape Town
- Real-time map showing all reported issues pinned by category
- Issue lifecycle: Open → Escalated → In Progress → Resolved
- Comments on every report

## Issue Categories

| Category | Description |
|---|---|
| 🕳️ Road Hazard | Potholes and damaged roads |
| 💧 Sewage Emergency | Sewage leaks and blockages |
| 🚦 Traffic Light Out | Non-functional robots |
| 🚰 Water Crisis | Water outages and supply failures |
| 💡 Light Outage | Broken streetlights |
| 🗑️ Waste Buildup | Missed rubbish collection |

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| Backend and Auth | Supabase |
| Database | PostgreSQL (via Supabase) |
| Storage | Supabase Storage |
| Maps | flutter_map + OpenStreetMap |
| State management | Riverpod 3.x |
| Navigation | GoRouter |

## Setup

### 1. Supabase
- Create a new project at supabase.com
- Run the full SQL schema from docs/schema.sql in the SQL editor
- Create a storage bucket named issue-photos with public read access
- Add storage policies from docs/schema.sql

### 2. Flutter config
Create lib/supabase_config.dart with your project URL and anon key.
This file is gitignored — never commit your keys.

### 3. Run the app

```bash
flutter pub get
flutter run
```

## Developer

**Mihle Aviwe Dudumashe**
Junior Full-Stack Developer — Cape Town
GitHub: [@MDtechcave](https://github.com/MDtechcave)
