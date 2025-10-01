# Docker Automation Scripts

This directory contains automation scripts to simplify Docker operations for the Acquisitions API project. These scripts provide a unified interface for managing development and production environments.

## 📁 Available Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `dev-docker.sh` | Bash/Linux/macOS | Development environment management |
| `dev-docker.ps1` | PowerShell/Windows | Development environment management |
| `prod-docker.sh` | Bash/Linux/macOS | Production environment management |
| `prod-docker.ps1` | PowerShell/Windows | Production environment management |
| `setup.sh` | Bash | Makes scripts executable and shows usage |

## 🚀 Quick Start

### For Windows Users (PowerShell)

1. **Development Environment:**
   ```powershell
   # Navigate to scripts directory
   cd scripts
   
   # Configure your Neon credentials in .env.development first
   # Then start development environment
   .\dev-docker.ps1 start
   
   # Run migrations
   .\dev-docker.ps1 migrate
   
   # View logs
   .\dev-docker.ps1 logs
   ```

2. **Production Environment:**
   ```powershell
   # Set environment variables
   $env:DATABASE_URL = "postgresql://user:pass@host.neon.tech/db"
   $env:JWT_SECRET = "your-secure-secret"
   
   # Start production environment
   .\prod-docker.ps1 start
   
   # Run migrations
   .\prod-docker.ps1 migrate
   ```

### For Unix/Linux/macOS Users (Bash)

1. **Setup (one-time):**
   ```bash
   cd scripts
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Development Environment:**
   ```bash
   # Configure your Neon credentials in .env.development first
   # Then start development environment
   ./dev-docker.sh start
   
   # Run migrations
   ./dev-docker.sh migrate
   
   # View logs
   ./dev-docker.sh logs
   ```

3. **Production Environment:**
   ```bash
   # Set environment variables
   export DATABASE_URL="postgresql://user:pass@host.neon.tech/db"
   export JWT_SECRET="your-secure-secret"
   
   # Start production environment
   ./prod-docker.sh start
   
   # Run migrations
   ./prod-docker.sh migrate
   ```

## 📋 Development Commands

| Command | Description |
|---------|-------------|
| `start`, `up` | Build and start development environment |
| `start-quick`, `up-q` | Start without rebuilding |
| `stop`, `down` | Stop development environment |
| `restart` | Restart all services |
| `logs` | Show and follow logs |
| `migrate` | Run database migrations |
| `shell` | Access application container shell |
| `db-shell` | Access database shell |
| `status` | Show container status and resource usage |
| `cleanup` | Remove all containers and images |
| `help` | Show all available commands |

## 🚀 Production Commands

| Command | Description |
|---------|-------------|
| `start`, `up` | Build and start production environment |
| `start-quick`, `up-q` | Start without rebuilding |
| `stop`, `down` | Stop production environment |
| `restart` | Restart all services |
| `update` | Perform rolling update |
| `logs [service]` | Show logs for specific service |
| `migrate` | Run database migrations (with confirmation) |
| `backup` | Create database backup |
| `shell` | Access application container shell |
| `status` | Show container status and health |
| `metrics` | Show detailed metrics and stats |
| `scale <replicas>` | Scale application instances |
| `cleanup` | Remove all containers and images |
| `help` | Show all available commands |

## 🔧 Prerequisites

### Development Environment
1. **Docker Desktop** installed and running
2. **Neon account** with API access
3. **Configuration file** `.env.development` in project root:
   ```env
   NEON_API_KEY=your-neon-api-key
   NEON_PROJECT_ID=your-neon-project-id
   PARENT_BRANCH_ID=main
   JWT_SECRET=dev-super-secret-jwt-key-for-development-only
   ```

### Production Environment
1. **Docker** installed and running
2. **Environment variables** set:
   - `DATABASE_URL`: Your Neon Cloud connection string
   - `JWT_SECRET`: Secure JWT signing secret
3. **Optional variables**:
   - `LOG_LEVEL`: Logging level (default: info)
   - `CORS_ORIGIN`: CORS origin (default: *)

## 🎯 Common Usage Patterns

### Development Workflow
```bash
# Start fresh development environment
./dev-docker.sh start

# Make code changes (hot reload active)
# View logs to debug issues
./dev-docker.sh logs

# Run migrations when schema changes
./dev-docker.sh migrate

# Stop when done
./dev-docker.sh stop
```

### Production Deployment
```bash
# Set production environment variables
export DATABASE_URL="your-production-db-url"
export JWT_SECRET="your-production-secret"

# Deploy application
./prod-docker.sh start

# Run migrations
./prod-docker.sh migrate

# Scale to multiple instances
./prod-docker.sh scale 3

# Monitor status
./prod-docker.sh status
```

### Rolling Updates
```bash
# Update production without downtime
./prod-docker.sh update

# Check health after update
./prod-docker.sh status
```

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied (Unix/Linux/macOS)**
   ```bash
   chmod +x *.sh
   ```

2. **PowerShell Execution Policy (Windows)**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Docker Not Running**
   - Start Docker Desktop
   - Verify with: `docker info`

4. **Environment Variables Not Set**
   - Development: Check `.env.development` file
   - Production: Verify `DATABASE_URL` and `JWT_SECRET`

5. **Port Conflicts**
   ```bash
   # Check what's using ports 3000 or 5432
   netstat -tlnp | grep :3000
   netstat -tlnp | grep :5432
   ```

### Getting Help

Each script includes comprehensive help:
```bash
./dev-docker.sh help
./prod-docker.sh help
```

Or for PowerShell:
```powershell
.\dev-docker.ps1 help
.\prod-docker.ps1 help
```

## 🔐 Security Notes

- **Development**: Uses Neon Local with ephemeral branches
- **Production**: Connects directly to Neon Cloud
- **Secrets**: Never commit real credentials to version control
- **Environment Variables**: Use secure methods to set production secrets
- **Container Security**: All containers run as non-root users

## 🤝 Contributing

When adding new Docker commands:
1. Update both bash and PowerShell versions
2. Add help documentation
3. Include error handling
4. Test on multiple platforms
5. Update this README