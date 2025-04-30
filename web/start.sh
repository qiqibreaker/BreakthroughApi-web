docker run -d \
  --name="breakthroughapi-web-dev" \
  -p 3000:3000 \
  -p 9229:9229 \
  --network host \
  -v $(pwd):/app \
  -v /app/node_modules \
  breakthroughapi-web-dev:latest
