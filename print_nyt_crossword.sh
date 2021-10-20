#!/bin/bash

USERNAME=""
PASSWORD=""

# Remove cookies and previous crossword
rm cookies.txt
rm crossword.pdf

# Parse out the CSRF auth token
AUTH_TOKEN=$(curl -v -c cookies.txt -b cookies.txt "https://myaccount.nytimes.com/auth/enter-email?response_type=cookie&client_id=lgcl&redirect_uri=https%3A%2F%2Fwww.nytimes.com" 2>&1 | grep -oP '(?<=authToken&quot;:&quot;).*?(?=&quot;)')

# Replace HTML encoded entities
AUTH_TOKEN=${AUTH_TOKEN//&#x3D;/=}

# First page that asks for email address
curl -c cookies.txt -b cookies.txt -X POST -d "{\"email\":\"${USERNAME}\",\"auth_token\":\"${AUTH_TOKEN}\",\"form_view\":\"enterEmail\"}" "https://myaccount.nytimes.com/svc/lire_ui/authorize-email" #-H "Content-Type: application/json"

# Second page that asks for password
curl -c cookies.txt -b cookies.txt -X POST -d "{\"username\":\"${USERNAME}\",\"auth_token\":\"${AUTH_TOKEN}\",\"form_view\":\"login\",\"password\":\"${PASSWORD}\",\"remember_me\":\"Y\"}" "https://myaccount.nytimes.com/svc/lire_ui/login" #-H "Content-Type: application/json"

# Download the print editions PDF
curl -c cookies.txt -b cookies.txt "https://www.nytimes.com/svc/crosswords/v2/puzzle/print/Oct2021.pdf" -o "crossword.pdf"

#TODO: Create today's date string

# TODO: Send to printer
