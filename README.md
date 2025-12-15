# Social Scribe

![Screenshot](./screenshot.png)

## Implementation Details

### HubSpot OAuth Integration
- Custom Ueberauth strategy implemented in `lib/ueberauth/strategy/hubspot.ex`
- Handles OAuth 2.0 authorization code flow with HubSpot's `/oauth/authorize` and `/oauth/v1/token` endpoints
- Credentials stored in `user_credentials` table with `provider: "hubspot"`, including `token`, `refresh_token`, and `expires_at`
- **Token Refresh:** `HubspotTokenRefresher` Oban cron worker runs every 5 minutes to proactively refresh tokens expiring within 10 minutes
- Internal `with_token_refresh/2` wrapper automatically refreshes expired tokens on API calls and retries the request
- Refresh failures are logged; users are prompted to re-authenticate if refresh token is invalid

### HubSpot Modal UI
- LiveView component in `lib/social_scribe_web/live/meeting_live/hubspot_modal_component.ex`
- Contact search with debounced input triggers HubSpot API search, results displayed in dropdown
- AI suggestions fetched via `HubspotSuggestions.generate_suggestions` which calls Gemini with transcript context
- Each suggestion card displays: field label, current value (strikethrough), arrow, suggested value, and timestamp link
- Checkbox per field allows selective updates; "Update HubSpot" button disabled until at least one field selected
- Form submission batch-updates selected contact properties via `HubspotApi.update_contact`
- Click-away handler closes dropdown without clearing selection

### Cloud Build Deployment
- `cloudbuild.yaml` defines multi-step build pipeline for Google Cloud Run
- Build Docker image using `Dockerfile` (multi-stage Elixir release build)
- Push image to Google Container Registry (`gcr.io/$PROJECT_ID/social-scribe`)
- Deploy and execute migration job via Cloud Run Jobs before main deployment
- Deploy to Cloud Run with environment variables injected from Secret Manager
- Cloud SQL connection via Unix socket for PostgreSQL access

## Running Locally

```bash
mix setup && source .env && mix phx.server
```

## Testing

```bash
mix test  # 12 properties, 226 tests, 0 failures
```