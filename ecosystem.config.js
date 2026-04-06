module.exports = {
  apps: [
    {
      name: "commercial-copilot-backend",
      script: "./backend/index.js",
      watch: false,
      env: {
        NODE_ENV: "production",
        PORT: 3000
      }
    }
  ]
};
