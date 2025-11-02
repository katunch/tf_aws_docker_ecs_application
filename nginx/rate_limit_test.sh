# Send rapid requests to trigger rate limit
seq 20 | xargs -n 1 -P 100 bash -c 'curl -s http://localhost:3000'