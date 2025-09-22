#!/bin/bash

# Laravel Voice Assistant Setup Script
# This script automates the setup process for the Laravel Voice Assistant application

set -e

echo "🎤 Laravel Voice Assistant Setup Script"
echo "=====================================\n"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if PHP is installed
check_php() {
    if ! command -v php &> /dev/null; then
        print_error "PHP is not installed. Please install PHP 8.3 or higher."
        exit 1
    fi
    
    PHP_VERSION=$(php -r "echo PHP_VERSION;")
    print_status "PHP $PHP_VERSION detected"
}

# Check if Composer is installed
check_composer() {
    if ! command -v composer &> /dev/null; then
        print_error "Composer is not installed. Please install Composer first."
        exit 1
    fi
    
    COMPOSER_VERSION=$(composer --version | cut -d ' ' -f 3)
    print_status "Composer $COMPOSER_VERSION detected"
}

# Check if Node.js is installed
check_node() {
    if ! command -v node &> /dev/null; then
        print_warning "Node.js is not installed. Frontend assets won't be built."
        return 1
    fi
    
    NODE_VERSION=$(node --version)
    print_status "Node.js $NODE_VERSION detected"
    return 0
}

# Install PHP dependencies
install_php_dependencies() {
    print_info "Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
    print_status "PHP dependencies installed"
}

# Install Node.js dependencies
install_node_dependencies() {
    if check_node; then
        print_info "Installing Node.js dependencies..."
        npm install
        print_status "Node.js dependencies installed"
        
        print_info "Building frontend assets..."
        npm run build
        print_status "Frontend assets built"
    fi
}

# Setup environment
setup_environment() {
    print_info "Setting up environment..."
    
    if [ ! -f .env ]; then
        cp .env.example .env
        print_status "Environment file created"
    else
        print_warning "Environment file already exists, skipping..."
    fi
    
    # Generate application key
    php artisan key:generate --ansi
    print_status "Application key generated"
}

# Setup database
setup_database() {
    print_info "Setting up database..."
    
    # Create SQLite database if it doesn't exist
    if [ ! -f database/database.sqlite ]; then
        touch database/database.sqlite
        print_status "SQLite database file created"
    fi
    
    # Run migrations
    php artisan migrate --force
    print_status "Database migrations completed"
}

# Setup MCP (Model Context Protocol)
setup_mcp() {
    print_info "Setting up MCP (Model Context Protocol)..."
    
    # Publish MCP routes
    php artisan vendor:publish --tag=ai-routes --force
    print_status "MCP routes published"
    
    # Create MCP directories
    mkdir -p app/Mcp/Servers
    mkdir -p app/Mcp/Tools
    mkdir -p app/Mcp/Resources
    mkdir -p app/Mcp/Prompts
    print_status "MCP directories created"
}

# Setup Laravel Sanctum
setup_sanctum() {
    print_info "Setting up Laravel Sanctum..."
    
    php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
    print_status "Sanctum published"
}

# Setup storage and cache
setup_storage() {
    print_info "Setting up storage and cache..."
    
    # Create storage link
    php artisan storage:link
    print_status "Storage link created"
    
    # Clear and cache configuration
    php artisan config:clear
    php artisan config:cache
    print_status "Configuration cached"
    
    # Clear and cache routes
    php artisan route:clear
    php artisan route:cache
    print_status "Routes cached"
    
    # Clear and cache views
    php artisan view:clear
    php artisan view:cache
    print_status "Views cached"
}

# Create sample MCP server
create_sample_mcp() {
    print_info "Creating sample MCP components..."
    
    # Create Voice Assistant Server
    php artisan make:mcp-server VoiceAssistantServer
    
    # Create sample tools
    php artisan make:mcp-tool GoogleCalendarTool
    php artisan make:mcp-tool VoiceCommandTool
    php artisan make:mcp-tool YouTubeTool
    
    # Create sample resources
    php artisan make:mcp-resource VoiceGuidelinesResource
    
    # Create sample prompts
    php artisan make:mcp-prompt VoiceAssistantPrompt
    
    print_status "Sample MCP components created"
}

# Set permissions
set_permissions() {
    print_info "Setting file permissions..."
    
    chmod -R 755 storage
    chmod -R 755 bootstrap/cache
    
    if [ -f artisan ]; then
        chmod +x artisan
    fi
    
    print_status "File permissions set"
}

# Display final instructions
display_instructions() {
    echo -e "\n${GREEN}🎉 Setup Complete!${NC}\n"
    
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Configure your .env file with API keys:"
    echo "   - Google: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, YOUTUBE_API_KEY"
    echo "   - Amazon: AMAZON_CLIENT_ID, AMAZON_CLIENT_SECRET"
    echo "   - OpenAI: OPENAI_API_KEY"
    echo ""
    echo "2. Start the development server:"
    echo -e "   ${YELLOW}php artisan serve${NC}"
    echo ""
    echo "3. In another terminal, start the frontend dev server:"
    echo -e "   ${YELLOW}npm run dev${NC}"
    echo ""
    echo "4. Visit http://localhost:8000 to access your voice assistant"
    echo ""
    echo "5. Test MCP integration:"
    echo -e "   ${YELLOW}php artisan mcp:inspector voice-assistant${NC}"
    echo ""
    echo -e "${GREEN}Happy coding! 🚀${NC}"
}

# Main execution
main() {
    check_php
    check_composer
    
    install_php_dependencies
    install_node_dependencies
    
    setup_environment
    setup_database
    setup_mcp
    setup_sanctum
    setup_storage
    create_sample_mcp
    set_permissions
    
    display_instructions
}

# Run main function
main