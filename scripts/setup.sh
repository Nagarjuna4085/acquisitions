#!/bin/bash

# Setup script for Acquisitions API Docker Scripts
# This script makes all Docker scripts executable and provides usage instructions

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Setting up Acquisitions API Docker Scripts...${NC}"
echo

# Make bash scripts executable
if [ -f "dev-docker.sh" ]; then
    chmod +x dev-docker.sh
    echo -e "${GREEN}✓ Made dev-docker.sh executable${NC}"
else
    echo -e "${YELLOW}⚠ dev-docker.sh not found${NC}"
fi

if [ -f "prod-docker.sh" ]; then
    chmod +x prod-docker.sh
    echo -e "${GREEN}✓ Made prod-docker.sh executable${NC}"
else
    echo -e "${YELLOW}⚠ prod-docker.sh not found${NC}"
fi

echo
echo -e "${BLUE}Setup completed!${NC}"
echo
echo -e "${BLUE}Available Scripts:${NC}"
echo
echo "📦 Development (Bash):"
echo "  ./dev-docker.sh start     # Start development environment"
echo "  ./dev-docker.sh migrate   # Run migrations"
echo "  ./dev-docker.sh logs      # View logs"
echo "  ./dev-docker.sh help      # Show all commands"
echo
echo "📦 Development (PowerShell):"
echo "  .\\dev-docker.ps1 start   # Start development environment"
echo "  .\\dev-docker.ps1 migrate # Run migrations"
echo "  .\\dev-docker.ps1 logs    # View logs"
echo "  .\\dev-docker.ps1 help    # Show all commands"
echo
echo "🚀 Production (Bash):"
echo "  export DATABASE_URL=\"your-neon-cloud-url\""
echo "  export JWT_SECRET=\"your-jwt-secret\""
echo "  ./prod-docker.sh start    # Start production environment"
echo "  ./prod-docker.sh help     # Show all commands"
echo
echo "🚀 Production (PowerShell):"
echo "  \$env:DATABASE_URL = \"your-neon-cloud-url\""
echo "  \$env:JWT_SECRET = \"your-jwt-secret\""
echo "  .\\prod-docker.ps1 start  # Start production environment"
echo "  .\\prod-docker.ps1 help   # Show all commands"
echo
echo -e "${YELLOW}Before running development scripts:${NC}"
echo "1. Ensure Docker Desktop is running"
echo "2. Configure .env.development with your Neon credentials"
echo "3. Run: ./dev-docker.sh start"
echo
echo -e "${YELLOW}Before running production scripts:${NC}"
echo "1. Set DATABASE_URL environment variable"
echo "2. Set JWT_SECRET environment variable"
echo "3. Run: ./prod-docker.sh start"
echo