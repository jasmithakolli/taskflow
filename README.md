# TaskFlow

A responsive personal task manager built with Flutter. Designed for desktop, tablet and mobile.

## Included pages

- Overview dashboard
- My Tasks with search and filters
- Create and edit task form
- Calendar with selectable dates and task markers
- Insights with progress and category breakdown
- Settings with persistent light/dark theme, display name and clear-completed action

## Features

- First-launch welcome screen asks for a display name; no login or workspace-name field
- Empty first-run task state: no preloaded or fabricated tasks
- Create, edit, complete, and delete tasks
- Task categories, priorities, statuses and due dates
- Dynamic progress metrics
- Local persistence with SharedPreferences
- Responsive desktop sidebar and mobile bottom navigation
- Light and dark themes

## Requirements

- Flutter 3.22 or newer recommended
- Chrome for web testing

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web
```

## Notes

Task data is stored locally in the browser. It is not synchronized between devices and clearing browser site data can remove locally stored tasks. No login, backend or external API is required.


## Calendar and first-launch setup update

- On the first launch, TaskFlow asks only for a display name and stores it locally.
- Returning users are taken straight to the app after local preferences finish loading.
- Calendar dates display task titles as colored event labels inside each date cell.
- Busy dates show a `+N more` indicator; selecting a date reveals its complete agenda.
- Selecting an event label or agenda item opens that task for editing.
- Event colors indicate priority, while completed tasks use a green treatment.
