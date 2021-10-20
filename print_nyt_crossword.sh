#!/bin/bash

USERNAME=""
PASSWORD=""

# Remove cookies 
rm cookies.txt

# Create today's date string in NYT expected format
DATE=$(date +%b%d%y)

# Parse out the CSRF auth token
AUTH_TOKEN=$(curl -v -c cookies.txt -b cookies.txt "https://myaccount.nytimes.com/auth/enter-email?response_type=cookie&client_id=lgcl&redirect_uri=https%3A%2F%2Fwww.nytimes.com" 2>&1 | grep -oP '(?<=authToken&quot;:&quot;).*?(?=&quot;)')

# Replace HTML encoded entities
AUTH_TOKEN=${AUTH_TOKEN//&#x3D;/=}

# First page that asks for email address
curl -c cookies.txt -b cookies.txt -X POST -d "{\"email\":\"${USERNAME}\",\"auth_token\":\"${AUTH_TOKEN}\",\"form_view\":\"enterEmail\"}" "https://myaccount.nytimes.com/svc/lire_ui/authorize-email" #-H "Content-Type: application/json"

# Second page that asks for password
curl -c cookies.txt -b cookies.txt -X POST -d "{\"username\":\"${USERNAME}\",\"auth_token\":\"${AUTH_TOKEN}\",\"form_view\":\"login\",\"password\":\"${PASSWORD}\",\"remember_me\":\"Y\"}" "https://myaccount.nytimes.com/svc/lire_ui/login" #-H "Content-Type: application/json"

# Download the print edition of the crossword and send to default printer
curl -s -b cookies.txt "https://www.nytimes.com/svc/crosswords/v2/puzzle/print/${DATE}.pdf" | lpr -o media=Letter -o fit-to-page
