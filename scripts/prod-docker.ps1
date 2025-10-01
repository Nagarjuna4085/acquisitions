# Production Docker Script for Acquisitions API (PowerShell)
# This script manages the production environment with Neon Cloud

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    [Parameter(Position=1)]
    [string]$Option
)

# Project configuration
$ProjectName = "acquisitions"
$ComposeFile = "docker-compose.prod.yml"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

# Function to print colored output
function Write-Status {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param($Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

# Function to check if required environment variables are set
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    if (-not (Test-Path $ComposeFile)) {
        Write-Error "$ComposeFile not found!"
        exit 1
    }
    
    # Check if Docker is running
    try {
        docker info | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw
        }
    }
    catch {
        Write-Error "Docker is not running. Please start Docker."
        exit 1
    }
    
    # Check for required environment variables
    if (-not $env:DATABASE_URL) {
        Write-Error "DATABASE_URL environment variable is not set!"
        Write-Warning "Please set DATABASE_URL with your Neon Cloud connection string:"
        Write-Host "`$env:DATABASE_URL = `"postgresql://neondb_owner:password@host.neon.tech/neondb?sslmode=require`""
        exit 1
    }
    
    if (-not $env:JWT_SECRET) {
        Write-Error "JWT_SECRET environment variable is not set!"
        Write-Warning "Please set JWT_SECRET with a secure secret:"
        Write-Host "`$env:JWT_SECRET = `"your-super-secure-production-jwt-secret`""
        exit 1
    }
    
    Write-Success "Prerequisites check passed!"
    Write-Status "Using DATABASE_URL: $($env:DATABASE_URL.Substring(0, [Math]::Min(50, $env:DATABASE_URL.Length)))..."
}

# Function to build and start production environment
function Start-Production {
    Write-Status "Starting production environment..."
    
    # Build and start containers
    docker-compose -f $ComposeFile up --build -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Production environment started!"
        Write-Status "Services:"
        docker-compose -f $ComposeFile ps
        
        # Show health status
        Write-Status "Waiting for health checks..."
        Start-Sleep 10
        docker-compose -f $ComposeFile ps
    }
    else {
        Write-Error "Failed to start production environment!"
        exit 1
    }
}

# Function to start without building
function Start-ProductionQuick {
    Write-Status "Starting production environment (without rebuild)..."
    
    # Start existing containers
    docker-compose -f $ComposeFile up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Production environment started!"
        docker-compose -f $ComposeFile ps
    }
    else {
        Write-Error "Failed to start production environment!"
        exit 1
    }
}

# Function to stop production environment
function Stop-Production {
    Write-Status "Stopping production environment..."
    docker-compose -f $ComposeFile down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Production environment stopped!"
    }
}

# Function to restart production environment
function Restart-Production {
    Write-Status "Restarting production environment..."
    docker-compose -f $ComposeFile restart
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Production environment restarted!"
    }
}

# Function to perform rolling update
function Update-Production {
    Write-Status "Performing rolling update..."
    Write-Warning "This will rebuild and redeploy the application with zero-downtime"
    
    # Build new image
    docker-compose -f $ComposeFile build app
    
    # Rolling restart
    docker-compose -f $ComposeFile up -d --no-deps app
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Rolling update completed!"
        docker-compose -f $ComposeFile ps
    }
}

# Function to view logs
function Show-Logs {
    param($Service = "app")
    Write-Status "Showing production logs for service: $Service"
    docker-compose -f $ComposeFile logs -f $Service
}

# Function to run database migrations
function Invoke-ProductionMigration {
    Write-Status "Running database migrations in production..."
    Write-Warning "This will run migrations against your production database!"
    
    $response = Read-Host "Are you sure you want to proceed? (yes/NO)"
    if ($response -eq "yes") {
        # Run migrations
        docker-compose -f $ComposeFile --profile migration run --rm migrate
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Database migrations completed!"
        }
        else {
            Write-Error "Database migration failed!"
        }
    }
    else {
        Write-Status "Migration cancelled."
    }
}

# Function to backup database
function Backup-Database {
    Write-Status "Creating database backup..."
    
    $backupFilename = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
    $backupDir = "./backups"
    
    # Create backup directory if it doesn't exist
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir
    }
    
    # Extract database details from DATABASE_URL
    # This is a simple backup - you might want to use pg_dump with proper credentials
    Write-Warning "Database backup functionality requires manual pg_dump configuration"
    Write-Status "Backup would be saved as: $backupDir/$backupFilename"
    Write-Status "Please configure pg_dump manually with your Neon Cloud credentials"
}

# Function to access application shell
function Enter-ProductionShell {
    Write-Status "Accessing production application container shell..."
    docker-compose -f $ComposeFile exec app /bin/sh
}

# Function to show container status
function Show-ProductionStatus {
    Write-Status "Production environment status:"
    docker-compose -f $ComposeFile ps
    Write-Host ""
    Write-Status "Container resource usage:"
    docker stats --no-stream --format "table {{.Container}}`t{{.CPUPerc}}`t{{.MemUsage}}`t{{.NetIO}}"
    Write-Host ""
    Write-Status "Application health check:"
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Application is healthy!"
        }
        else {
            Write-Error "Application health check failed!"
        }
    }
    catch {
        Write-Error "Application health check failed!"
    }
}

# Function to show application metrics
function Show-Metrics {
    Write-Status "Application metrics:"
    Write-Host ""
    Write-Status "Container stats:"
    docker stats --no-stream
    Write-Host ""
    Write-Status "Disk usage:"
    docker system df
    Write-Host ""
    Write-Status "Network information:"
    docker network ls | Select-String $ProjectName
}

# Function to scale application
function Set-Scale {
    param($Replicas = 1)
    Write-Status "Scaling application to $Replicas replicas..."
    docker-compose -f $ComposeFile up -d --scale app=$Replicas
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Scaled to $Replicas replicas!"
        docker-compose -f $ComposeFile ps
    }
}

# Function to clean up everything
function Remove-ProductionEnvironment {
    Write-Warning "This will remove all production containers, images, and volumes. Are you sure? (yes/NO)"
    $response = Read-Host
    if ($response -eq "yes") {
        Write-Status "Cleaning up production environment..."
        docker-compose -f $ComposeFile down -v --rmi all
        docker system prune -f
        Write-Success "Cleanup completed!"
    }
    else {
        Write-Status "Cleanup cancelled."
    }
}

# Function to show help
function Show-Help {
    Write-Host "Production Docker Script for $ProjectName" -ForegroundColor $Colors.White
    Write-Host ""
    Write-Host "Usage: .\prod-docker.ps1 [COMMAND] [OPTIONS]" -ForegroundColor $Colors.White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $Colors.White
    Write-Host "  start, up           Build and start production environment"
    Write-Host "  start-quick, up-q   Start production environment without building"
    Write-Host "  stop, down          Stop production environment"
    Write-Host "  restart             Restart production environment"
    Write-Host "  update              Perform rolling update"
    Write-Host "  logs [service]      Show and follow logs (default: app)"
    Write-Host "  migrate             Run database migrations"
    Write-Host "  backup              Create database backup"
    Write-Host "  shell               Access application container shell"
    Write-Host "  status              Show container status and health"
    Write-Host "  metrics             Show detailed metrics and stats"
    Write-Host "  scale <replicas>    Scale application (default: 1)"
    Write-Host "  cleanup             Clean up all containers and images"
    Write-Host "  help                Show this help message"
    Write-Host ""
    Write-Host "Required Environment Variables:" -ForegroundColor $Colors.White
    Write-Host "  DATABASE_URL        Neon Cloud database connection string"
    Write-Host "  JWT_SECRET          JWT signing secret"
    Write-Host ""
    Write-Host "Optional Environment Variables:" -ForegroundColor $Colors.White
    Write-Host "  LOG_LEVEL           Logging level (default: info)"
    Write-Host "  CORS_ORIGIN         CORS origin (default: *)"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors.White
    Write-Host "  `$env:DATABASE_URL = `"postgresql://user:pass@host.neon.tech/db`""
    Write-Host "  `$env:JWT_SECRET = `"super-secure-secret`""
    Write-Host "  .\prod-docker.ps1 start            # Start production environment"
    Write-Host "  .\prod-docker.ps1 migrate          # Run database migrations"
    Write-Host "  .\prod-docker.ps1 logs app         # View application logs"
    Write-Host "  .\prod-docker.ps1 scale 3          # Scale to 3 replicas"
    Write-Host "  .\prod-docker.ps1 update           # Rolling update"
}

# Main script logic
switch ($Command.ToLower()) {
    { $_ -in @("start", "up") } {
        Test-Prerequisites
        Start-Production
    }
    { $_ -in @("start-quick", "up-q") } {
        Test-Prerequisites
        Start-ProductionQuick
    }
    { $_ -in @("stop", "down") } {
        Stop-Production
    }
    "restart" {
        Test-Prerequisites
        Restart-Production
    }
    "update" {
        Test-Prerequisites
        Update-Production
    }
    "logs" {
        Show-Logs $Option
    }
    "migrate" {
        Test-Prerequisites
        Invoke-ProductionMigration
    }
    "backup" {
        Backup-Database
    }
    "shell" {
        Enter-ProductionShell
    }
    "status" {
        Show-ProductionStatus
    }
    "metrics" {
        Show-Metrics
    }
    "scale" {
        Test-Prerequisites
        $replicas = if ($Option) { [int]$Option } else { 1 }
        Set-Scale $replicas
    }
    "cleanup" {
        Remove-ProductionEnvironment
    }
    { $_ -in @("help", "-h", "--help") } {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}