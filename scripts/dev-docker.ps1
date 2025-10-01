# Development Docker Script for Acquisitions API (PowerShell)
# This script manages the development environment with Neon Local

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    [Parameter(Position=1)]
    [string]$Option
)

# Project configuration
$ProjectName = "acquisitions"
$ComposeFile = "docker-compose.dev.yml"
$EnvFile = ".env.development"

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

# Function to check if required files exist
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    if (-not (Test-Path $EnvFile)) {
        Write-Error "$EnvFile not found!"
        Write-Warning "Please create $EnvFile with your Neon Local configuration:"
        Write-Host "NEON_API_KEY=your-neon-api-key"
        Write-Host "NEON_PROJECT_ID=your-neon-project-id"
        Write-Host "PARENT_BRANCH_ID=main"
        Write-Host "JWT_SECRET=dev-super-secret-jwt-key-for-development-only"
        exit 1
    }
    
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
        Write-Error "Docker is not running. Please start Docker Desktop."
        exit 1
    }
    
    Write-Success "Prerequisites check passed!"
}

# Function to build and start development environment
function Start-Development {
    Write-Status "Starting development environment..."
    
    # Build and start containers
    docker-compose -f $ComposeFile --env-file $EnvFile up --build -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Development environment started!"
        Write-Status "Services:"
        docker-compose -f $ComposeFile ps
    }
    else {
        Write-Error "Failed to start development environment!"
        exit 1
    }
}

# Function to start without building
function Start-DevelopmentQuick {
    Write-Status "Starting development environment (without rebuild)..."
    
    # Start existing containers
    docker-compose -f $ComposeFile --env-file $EnvFile up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Development environment started!"
        docker-compose -f $ComposeFile ps
    }
    else {
        Write-Error "Failed to start development environment!"
        exit 1
    }
}

# Function to stop development environment
function Stop-Development {
    Write-Status "Stopping development environment..."
    docker-compose -f $ComposeFile down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Development environment stopped!"
    }
}

# Function to restart development environment
function Restart-Development {
    Write-Status "Restarting development environment..."
    docker-compose -f $ComposeFile restart
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Development environment restarted!"
    }
}

# Function to view logs
function Show-Logs {
    Write-Status "Showing development logs..."
    docker-compose -f $ComposeFile logs -f
}

# Function to run database migrations
function Invoke-Migration {
    Write-Status "Running database migrations..."
    
    # Run migrations
    docker-compose -f $ComposeFile --profile migration run --rm migrate
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Database migrations completed!"
    }
    else {
        Write-Error "Database migration failed!"
    }
}

# Function to access application shell
function Enter-AppShell {
    Write-Status "Accessing application container shell..."
    docker-compose -f $ComposeFile exec app /bin/sh
}

# Function to access database shell
function Enter-DatabaseShell {
    Write-Status "Accessing database shell..."
    docker-compose -f $ComposeFile exec neon-local psql -h localhost -U neon -d neondb
}

# Function to show container status
function Show-Status {
    Write-Status "Development environment status:"
    docker-compose -f $ComposeFile ps
    Write-Host ""
    Write-Status "Container resource usage:"
    docker stats --no-stream --format "table {{.Container}}`t{{.CPUPerc}}`t{{.MemUsage}}`t{{.NetIO}}"
}

# Function to clean up everything
function Remove-Everything {
    Write-Warning "This will remove all containers, images, and volumes. Are you sure? (y/N)"
    $response = Read-Host
    if ($response -match '^[yY]([eE][sS])?$') {
        Write-Status "Cleaning up development environment..."
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
    Write-Host "Development Docker Script for $ProjectName" -ForegroundColor $Colors.White
    Write-Host ""
    Write-Host "Usage: .\dev-docker.ps1 [COMMAND]" -ForegroundColor $Colors.White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $Colors.White
    Write-Host "  start, up          Build and start development environment"
    Write-Host "  start-quick, up-q  Start development environment without building"
    Write-Host "  stop, down         Stop development environment"
    Write-Host "  restart            Restart development environment"
    Write-Host "  logs               Show and follow logs"
    Write-Host "  migrate            Run database migrations"
    Write-Host "  shell              Access application container shell"
    Write-Host "  db-shell           Access database shell"
    Write-Host "  status             Show container status and resource usage"
    Write-Host "  cleanup            Clean up all containers and images"
    Write-Host "  help               Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors.White
    Write-Host "  .\dev-docker.ps1 start           # Start development environment"
    Write-Host "  .\dev-docker.ps1 migrate         # Run database migrations"
    Write-Host "  .\dev-docker.ps1 logs            # View application logs"
    Write-Host "  .\dev-docker.ps1 cleanup         # Clean up everything"
}

# Main script logic
switch ($Command.ToLower()) {
    { $_ -in @("start", "up") } {
        Test-Prerequisites
        Start-Development
    }
    { $_ -in @("start-quick", "up-q") } {
        Test-Prerequisites
        Start-DevelopmentQuick
    }
    { $_ -in @("stop", "down") } {
        Stop-Development
    }
    "restart" {
        Test-Prerequisites
        Restart-Development
    }
    "logs" {
        Show-Logs
    }
    "migrate" {
        Test-Prerequisites
        Invoke-Migration
    }
    "shell" {
        Enter-AppShell
    }
    "db-shell" {
        Enter-DatabaseShell
    }
    "status" {
        Show-Status
    }
    "cleanup" {
        Remove-Everything
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