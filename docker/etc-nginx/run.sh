#!/bin/sh -e

PORT=${PORT:-80}

sed "s/%port%/${PORT}/" -i /etc/nginx/sites-available/default

if [ -z "${NGO_CLIENT_ID}" ]; then
  echo "NGO_CLIENT_ID is not set"
  exit 1
fi

if [ -z "${NGO_CLIENT_SECRET}" ]; then
  echo "NGO_CLIENT_SECRET is not set"
  exit 1
fi

if [ -z "${NGO_TOKEN_SECRET}" ]; then
  echo "NGO_TOKEN_SECRET is not set"
  exit 1
fi

# Define some defaults
export NGO_CALLBACK_SCHEME=${NGO_CALLBACK_SCHEME:-https}
export NGO_CALLBACK_URI=${NGO_CALLBACK_URI-/_oauth}
export NGO_SIGNOUT_URI=${NGO_SIGNOUT_URI-/_signout}
export NGO_EMAIL_AS_USER=${NGO_EMAIL_AS_USER:-true}
export NGO_EXTRA_VALIDITY=${NGO_EXTRA_VALIDITY:-0}
export NGO_USER=${NGO_USER:-unknown}

# Overwrite user supplied locations
if [ "${LOCATIONS}" ]; then
  echo "${LOCATIONS}" > /etc/nginx/snippets/demo-locations.conf
fi

if [ "${PROXY_BUFFERING_OFF}" ]; then
  # Disables buffering for reverse proxy location(s). Useful when client wants to do
  # http/2 event streams like Argo workflows server.
  perl -i -pe 'BEGIN{undef $/;} s/http\s*{/http {\n    proxy_buffering off;/' /etc/nginx/nginx.conf
fi

# Help people spot problems
if [ "${DEBUG}" ]; then
  echo "## /etc/nginx/sites-available/default ##"
  cat -n /etc/nginx/sites-available/default
  echo "## /etc/nginx/snippets/demo-locations.conf ##"
  cat -n /etc/nginx/snippets/demo-locations.conf
  echo "## environment ##"
  env | grep '^\(NGO_.*\|LOCATIONS\|PORT\)=' | sort -n | cat -n
fi

exec nginx -g "daemon off;" -c /etc/nginx/nginx.conf
