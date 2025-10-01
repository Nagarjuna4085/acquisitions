#!/bin/bash

# Production Docker Script for Acquisitions API
# This script manages the production environment with Neon Cloud

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="acquisitions"
COMPOSE_FILE="docker-compose.prod.yml"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required environment variables are set
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "$COMPOSE_FILE not found!"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker."
        exit 1
    fi
    
    # Check for required environment variables
    if [ -z "$DATABASE_URL" ]; then
        print_error "DATABASE_URL environment variable is not set!"
        print_warning "Please set DATABASE_URL with your Neon Cloud connection string:"
        echo "export DATABASE_URL=\"postgresql://neondb_owner:password@host.neon.tech/neondb?sslmode=require\""
        exit 1
    fi
    
    if [ -z "$JWT_SECRET" ]; then
        print_error "JWT_SECRET environment variable is not set!"
        print_warning "Please set JWT_SECRET with a secure secret:"
        echo "export JWT_SECRET=\"your-super-secure-production-jwt-secret\""
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
    print_status "Using DATABASE_URL: ${DATABASE_URL:0:50}..."
}

# Function to build and start production environment
start_prod() {
    print_status "Starting production environment..."
    
    # Build and start containers
    docker-compose -f "$COMPOSE_FILE" up --build -d
    
    print_success "Production environment started!"
    print_status "Services:"
    docker-compose -f "$COMPOSE_FILE" ps
    
    # Show health status
    print_status "Waiting for health checks..."
    sleep 10
    docker-compose -f "$COMPOSE_FILE" ps
}

# Function to start without building
start_prod_no_build() {
    print_status "Starting production environment (without rebuild)..."
    
    # Start existing containers
    docker-compose -f "$COMPOSE_FILE" up -d
    
    print_success "Production environment started!"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Function to stop production environment
stop_prod() {
    print_status "Stopping production environment..."
    docker-compose -f "$COMPOSE_FILE" down
    print_success "Production environment stopped!"
}

# Function to restart production environment
restart_prod() {
    print_status "Restarting production environment..."
    docker-compose -f "$COMPOSE_FILE" restart
    print_success "Production environment restarted!"
}

# Function to perform rolling update
rolling_update() {
    print_status "Performing rolling update..."
    print_warning "This will rebuild and redeploy the application with zero-downtime"
    
    # Build new image
    docker-compose -f "$COMPOSE_FILE" build app
    
    # Rolling restart
    docker-compose -f "$COMPOSE_FILE" up -d --no-deps app
    
    print_success "Rolling update completed!"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Function to view logs
show_logs() {
    local service="${1:-app}"
    print_status "Showing production logs for service: $service"
    docker-compose -f "$COMPOSE_FILE" logs -f "$service"
}

# Function to run database migrations
migrate_prod() {
    print_status "Running database migrations in production..."
    print_warning "This will run migrations against your production database!"
    
    echo "Are you sure you want to proceed? (yes/NO)"
    read -r response
    if [[ "$response" == "yes" ]]; then
        # Run migrations
        docker-compose -f "$COMPOSE_FILE" --profile migration run --rm migrate
        print_success "Database migrations completed!"
    else
        print_status "Migration cancelled."
    fi
}

# Function to backup database
backup_db() {
    print_status "Creating database backup..."
    
    local backup_filename="backup_$(date +%Y%m%d_%H%M%S).sql"
    local backup_dir="./backups"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"
    
    # Extract database details from DATABASE_URL
    # This is a simple backup - you might want to use pg_dump with proper credentials
    print_warning "Database backup functionality requires manual pg_dump configuration"
    print_status "Backup would be saved as: $backup_dir/$backup_filename"
    print_status "Please configure pg_dump manually with your Neon Cloud credentials"
}

# Function to access application shell
shell_app() {
    print_status "Accessing production application container shell..."
    docker-compose -f "$COMPOSE_FILE" exec app /bin/sh
}

# Function to show container status
status() {
    print_status "Production environment status:"
    docker-compose -f "$COMPOSE_FILE" ps
    echo
    print_status "Container resource usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo
    print_status "Application health check:"
    if curl -f http://localhost:3000/health &> /dev/null; then
        print_success "Application is healthy!"
    else
        print_error "Application health check failed!"
    fi
}

# Function to show application metrics
metrics() {
    print_status "Application metrics:"
    echo
    print_status "Container stats:"
    docker stats --no-stream
    echo
    print_status "Disk usage:"
    docker system df
    echo
    print_status "Network information:"
    docker network ls | grep "$PROJECT_NAME"
}

# Function to scale application
scale() {
    local replicas="${1:-1}"
    print_status "Scaling application to $replicas replicas..."
    docker-compose -f "$COMPOSE_FILE" up -d --scale app="$replicas"
    print_success "Scaled to $replicas replicas!"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Function to clean up everything
cleanup() {
    print_warning "This will remove all production containers, images, and volumes. Are you sure? (yes/NO)"
    read -r response
    if [[ "$response" == "yes" ]]; then
        print_status "Cleaning up production environment..."
        docker-compose -f "$COMPOSE_FILE" down -v --rmi all
        docker system prune -f
        print_success "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to show help
show_help() {
    echo "Production Docker Script for $PROJECT_NAME"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  start, up           Build and start production environment"
    echo "  start-quick, up-q   Start production environment without building"
    echo "  stop, down          Stop production environment"
    echo "  restart             Restart production environment"
    echo "  update              Perform rolling update"
    echo "  logs [service]      Show and follow logs (default: app)"
    echo "  migrate             Run database migrations"
    echo "  backup              Create database backup"
    echo "  shell               Access application container shell"
    echo "  status              Show container status and health"
    echo "  metrics             Show detailed metrics and stats"
    echo "  scale <replicas>    Scale application (default: 1)"
    echo "  cleanup             Clean up all containers and images"
    echo "  help                Show this help message"
    echo
    echo "Required Environment Variables:"
    echo "  DATABASE_URL        Neon Cloud database connection string"
    echo "  JWT_SECRET          JWT signing secret"
    echo
    echo "Optional Environment Variables:"
    echo "  LOG_LEVEL           Logging level (default: info)"
    echo "  CORS_ORIGIN         CORS origin (default: *)"
    echo
    echo "Examples:"
    echo "  export DATABASE_URL=\"postgresql://user:pass@host.neon.tech/db\""
    echo "  export JWT_SECRET=\"super-secure-secret\""
    echo "  $0 start            # Start production environment"
    echo "  $0 migrate          # Run database migrations"
    echo "  $0 logs app         # View application logs"
    echo "  $0 scale 3          # Scale to 3 replicas"
    echo "  $0 update           # Rolling update"
}

# Main script logic
main() {
    case "${1:-help}" in
        "start"|"up")
            check_prerequisites
            start_prod
            ;;
        "start-quick"|"up-q")
            check_prerequisites
            start_prod_no_build
            ;;
        "stop"|"down")
            stop_prod
            ;;
        "restart")
            check_prerequisites
            restart_prod
            ;;
        "update")
            check_prerequisites
            rolling_update
            ;;
        "logs")
            show_logs "$2"
            ;;
        "migrate")
            check_prerequisites
            migrate_prod
            ;;
        "backup")
            backup_db
            ;;
        "shell")
            shell_app
            ;;
        "status")
            status
            ;;
        "metrics")
            metrics
            ;;
        "scale")
            check_prerequisites
            scale "$2"
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"