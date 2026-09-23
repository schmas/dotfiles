# TypeSafe API Endpoint

Use this file when calling the TypeSafe (System One / Jev) API.

- Send requests to `$TYPESAFE_BASE_URL/v1/systemone` with
  `Authorization: Bearer $TYPESAFE_API_KEY`.
- Do not use `https://api.typesafe.ai`. The configured key is an OpenRouter key
  and fails there with `authentication_error`.
- `TYPESAFE_BASE_URL` is `https://openrouter.ai/api`, set in
  `~/.config/env/30-ai-config.env` (chezmoi source:
  `home/dot_config/private_env/30-ai-config.env.tmpl`).
- SDKs read `TYPESAFE_BASE_URL` automatically; do not override `base_url`.
