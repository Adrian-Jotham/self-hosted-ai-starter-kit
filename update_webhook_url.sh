#!/bin/bash
# filepath: /home/adrian/workspace/n8n/self-hosted-ai-starter-kit/update_webhook_url.sh

# Start cloudflared in the background and capture the generated URL
cloudflared tunnel --url http://localhost:5678 > cloudflared_output.log 2>&1 &
CLOUDFLARED_PID=$!

# Wait for the URL to be generated
echo "Waiting for Cloudflare tunnel URL..."
for i in {1..10}; do
    GENERATED_URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' cloudflared_output.log | head -n 1)
    if [ -n "$GENERATED_URL" ]; then
        break
    fi
    sleep 1
done

# Kill the cloudflared process
# kill $CLOUDFLARED_PID

# Check if the URL was generated
if [ -z "$GENERATED_URL" ]; then
    echo "Failed to generate Cloudflare tunnel URL."
    exit 1
fi

# Update the WEBHOOK_URL in the .env file
sed -i "s|^WEBHOOK_URL=.*|WEBHOOK_URL=$GENERATED_URL|" .env

echo "Updated WEBHOOK_URL to $GENERATED_URL"

