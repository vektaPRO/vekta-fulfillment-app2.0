# Firebase Cloud Functions: SMS via Kaspi API

This folder contains sample Firebase Cloud Functions that send and confirm SMS codes using the Kaspi API.

## Configuration

Set the following runtime config variables:

```bash
firebase functions:config:set kaspi.url="https://kaspi.example.com/api" kaspi.token="YOUR_TOKEN"
```

Deploy functions:

```bash
firebase deploy --only functions
```

## Available Functions

- `sendSmsCode`: Callable function to send an SMS code to a user.
- `confirmSmsCode`: Callable function to confirm a previously sent code.

Both functions expect JSON parameters when invoked.
