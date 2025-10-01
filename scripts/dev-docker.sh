#!/bin/bash

# Development Docker Script for Acquisitions API
# This script manages the development environment with Neon Local

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="acquisitions"
# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.dev.yml"
ENV_FILE="$PROJECT_ROOT/.env.development"

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

# Function to check if required files exist
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if [ ! -f "$ENV_FILE" ]; then
        print_error "$ENV_FILE not found!"
        print_warning "Please create $ENV_FILE with your Neon Local configuration:"
        echo "NEON_API_KEY=your-neon-api-key"
        echo "NEON_PROJECT_ID=your-neon-project-id"
        echo "PARENT_BRANCH_ID=main"
        echo "JWT_SECRET=dev-super-secret-jwt-key-for-development-only"
        exit 1
    fi
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "$COMPOSE_FILE not found!"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

# Function to build and start development environment
start_dev() {
    print_status "Starting development environment..."
    
    # Change to project root directory
    cd "$PROJECT_ROOT"
    
    # Load environment variables
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    
    # Build and start containers
    docker-compose -f docker-compose.dev.yml --env-file .env.development up --build -d
    
    print_success "Development environment started!"
    print_status "Services:"
    docker-compose -f docker-compose.dev.yml ps
}

# Function to start without building
start_dev_no_build() {
    print_status "Starting development environment (without rebuild)..."
    
    # Change to project root directory
    cd "$PROJECT_ROOT"
    
    # Load environment variables
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    
    # Start existing containers
    docker-compose -f docker-compose.dev.yml --env-file .env.development up -d
    
    print_success "Development environment started!"
    docker-compose -f docker-compose.dev.yml ps
}

# Function to stop development environment
stop_dev() {
    print_status "Stopping development environment..."
    cd "$PROJECT_ROOT"
    docker-compose -f docker-compose.dev.yml down
    print_success "Development environment stopped!"
}

# Function to restart development environment
restart_dev() {
    print_status "Restarting development environment..."
    cd "$PROJECT_ROOT"
    docker-compose -f docker-compose.dev.yml restart
    print_success "Development environment restarted!"
}

# Function to view logs
show_logs() {
    print_status "Showing development logs..."
    cd "$PROJECT_ROOT"
    docker-compose -f docker-compose.dev.yml logs -f
}

# Function to run database migrations
migrate_dev() {
    print_status "Running database migrations..."
    
    # Change to project root directory
    cd "$PROJECT_ROOT"
    
    # Load environment variables
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    
    # Run migrations
    docker-compose -f docker-compose.dev.yml --profile migration run --rm migrate
    
    print_success "Database migrations completed!"
}

# Function to access application shell
shell_app() {
    print_status "Accessing application container shell..."
    cd "$PROJECT_ROOT"
    docker-compose -f docker-compose.dev.yml exec app /bin/sh
}

# Function to access database shell
shell_db() {
    print_status "Accessing database shell..."
    cd "$PROJECT_ROOT"
    docker-compose -f docker-compose.dev.yml exec neon-local psql -h localhost -U neon -d neondb
}

# Function to show container status
status() {
    print_status "Development environment status:"
    cd "$PROJECT_ROOT"
    docker-compose -f docker-compose.dev.yml ps
    echo
    print_status "Container resource usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

# Function to clean up everything
cleanup() {
    print_warning "This will remove all containers, images, and volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Cleaning up development environment..."
        cd "$PROJECT_ROOT"
        docker-compose -f docker-compose.dev.yml down -v --rmi all
        docker system prune -f
        print_success "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to show help
show_help() {
    echo "Development Docker Script for $PROJECT_NAME"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start, up          Build and start development environment"
    echo "  start-quick, up-q  Start development environment without building"
    echo "  stop, down         Stop development environment"
    echo "  restart            Restart development environment"
    echo "  logs               Show and follow logs"
    echo "  migrate            Run database migrations"
    echo "  shell              Access application container shell"
    echo "  db-shell           Access database shell"
    echo "  status             Show container status and resource usage"
    echo "  cleanup            Clean up all containers and images"
    echo "  help               Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start           # Start development environment"
    echo "  $0 migrate         # Run database migrations"
    echo "  $0 logs            # View application logs"
    echo "  $0 cleanup         # Clean up everything"
}

# Main script logic
main() {
    case "${1:-help}" in
        "start"|"up")
            check_prerequisites
            start_dev
            ;;
        "start-quick"|"up-q")
            check_prerequisites
            start_dev_no_build
            ;;
        "stop"|"down")
            stop_dev
            ;;
        "restart")
            check_prerequisites
            restart_dev
            ;;
        "logs")
            show_logs
            ;;
        "migrate")
            check_prerequisites
            migrate_dev
            ;;
        "shell")
            shell_app
            ;;
        "db-shell")
            shell_db
            ;;
        "status")
            status
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