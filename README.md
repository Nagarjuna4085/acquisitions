# Acquisitions API

A modern, secure REST API built with Node.js and Express.js that provides user authentication and management services for acquisition management systems.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Docker Setup](#docker-setup)
- [API Endpoints](#api-endpoints)
- [Authentication Flow](#authentication-flow)
- [Development](#development)
- [Scripts](#scripts)
- [Logging](#logging)
- [Security Features](#security-features)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

- 🔐 **Complete Authentication System** - User registration, login, and logout
- 🛡️ **Security First** - JWT tokens, password hashing, secure cookies
- 📊 **PostgreSQL Database** - Robust data persistence with Drizzle ORM
- 🚀 **Modern Architecture** - Clean layered architecture with separation of concerns
- 📝 **Comprehensive Logging** - Winston logger with file and console outputs
- ✅ **Input Validation** - Zod schemas for type-safe validation
- 🔄 **Database Migrations** - Managed with Drizzle Kit
- 🎯 **Health Monitoring** - Built-in health check endpoints

## 🛠 Tech Stack

### Core Framework
- **Node.js** - JavaScript runtime
- **Express.js 5.1.0** - Web application framework
- **ES Modules** - Modern JavaScript module system

### Database
- **PostgreSQL** - Primary database
- **Neon Database** - Serverless PostgreSQL hosting
- **Drizzle ORM** - Type-safe SQL query builder
- **Drizzle Kit** - Database migration tool

### Security & Authentication
- **bcrypt** - Password hashing
- **jsonwebtoken** - JWT token management
- **helmet** - Security middleware
- **cors** - Cross-origin resource sharing

### Development Tools
- **Winston** - Logging framework
- **Zod** - Runtime type validation
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Morgan** - HTTP request logger

## 📁 Project Structure

```
acquisitions/
├── src/
│   ├── config/
│   │   ├── database.js      # Database configuration
│   │   └── logger.js        # Winston logger setup
│   ├── controllers/
│   │   └── auth.controller.js # Authentication controllers
│   ├── models/
│   │   └── user.model.js    # User database schema
│   ├── routes/
│   │   └── auth.routes.js   # Authentication routes
│   ├── services/
│   │   └── auth.service.js  # Authentication business logic
│   ├── utils/
│   │   ├── cookies.js       # Cookie management utilities
│   │   ├── format.js        # Error formatting utilities
│   │   └── jwt.js           # JWT token utilities
│   ├── validations/
│   │   └── auth.validation.js # Zod validation schemas
│   ├── app.js               # Express app configuration
│   ├── server.js            # Server startup
│   └── index.js             # Application entry point
├── drizzle/                 # Database migrations
├── logs/                    # Application logs
├── .env                     # Environment variables
├── package.json             # Dependencies and scripts
├── drizzle.config.js        # Drizzle ORM configuration
├── eslint.config.js         # ESLint configuration
└── README.md               # This file
```

## 📋 Prerequisites

Before running this application, make sure you have:

- **Node.js** (v18 or higher)
- **npm** or **yarn**
- **PostgreSQL database** (or Neon Database account)
- **Git** (for version control)

## 🚀 Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd acquisitions
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run database migrations:**
   ```bash
   npm run db:migrate
   ```

## 🔧 Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Server Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=info

# Database Configuration
DATABASE_URL=postgresql://username:password@host:port/database

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
```

### Required Variables:
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret key for JWT token signing (change in production!)

### Optional Variables:
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment mode (development/production)
- `LOG_LEVEL` - Logging level (error/warn/info/debug)

## 🗄️ Database Setup

1. **Generate migration files:**
   ```bash
   npm run db:generate
   ```

2. **Apply migrations:**
   ```bash
   npm run db:migrate
   ```

3. **Open Drizzle Studio (optional):**
   ```bash
   npm run db:studio
   ```

### Database Schema

**Users Table:**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);
```

## 🏃‍♂️ Running the Application

### Development Mode
```bash
npm run dev
```
This starts the server with auto-reload on file changes.

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000` (or your configured PORT).

## 🐳 Docker Setup

The application is fully dockerized with separate configurations for development and production environments.

### 🛠️ Development Environment (with Neon Local)

For development, we use **Neon Local** which creates ephemeral database branches automatically. This provides isolated database environments that are created when containers start and destroyed when they stop.

#### Prerequisites for Docker Development

1. **Docker & Docker Compose** installed on your machine
2. **Neon account** with API access
3. **Neon project** set up in the cloud

#### Step 1: Configure Neon Local Environment

1. **Get your Neon credentials:**
   ```bash
   # From your Neon Console (https://console.neon.tech)
   # You'll need:
   # - NEON_API_KEY (from Account Settings -> API Keys)
   # - NEON_PROJECT_ID (from your project URL or dashboard)
   # - PARENT_BRANCH_ID (usually 'main' or your primary branch ID)
   ```

2. **Update `.env.development`:**
   ```env
   # Neon Local Configuration
   NEON_API_KEY=your-actual-neon-api-key
   NEON_PROJECT_ID=your-actual-project-id  
   PARENT_BRANCH_ID=main
   
   # JWT Secret (for development)
   JWT_SECRET=dev-super-secret-jwt-key-for-development-only
   ```

#### Step 2: Start Development Environment

```bash
# Start the development environment with Neon Local
npm run docker:dev:build

# Or without rebuilding (if images already exist)
npm run docker:dev

# View logs
npm run docker:dev:logs

# Stop the development environment
npm run docker:dev:down
```

#### Step 3: Run Database Migrations (Development)

```bash
# Run migrations against Neon Local
npm run docker:migrate:dev
```

#### Development Workflow

- **Hot Reloading**: Source code is mounted as a volume, so changes are reflected immediately
- **Ephemeral Database**: Each time you start the containers, you get a fresh database branch
- **Automatic Cleanup**: When containers stop, the ephemeral branch is automatically deleted
- **Network**: Services communicate via `acquisitions-network`
- **Database URL**: `postgres://neon:npg@neon-local:5432/neondb?sslmode=require`

### 🏢 Production Environment (with Neon Cloud)

For production, the application connects directly to your Neon Cloud database without the local proxy.

#### Step 1: Configure Production Environment

```bash
# Set environment variables (via your deployment platform)
export DATABASE_URL="postgresql://neondb_owner:your_password@ep-example-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require"
export JWT_SECRET="your-super-secure-production-jwt-secret"
export CORS_ORIGIN="https://yourdomain.com"
export LOG_LEVEL="info"
```

#### Step 2: Start Production Environment

```bash
# Build and start production containers
DATABASE_URL="your-neon-cloud-url" JWT_SECRET="your-jwt-secret" npm run docker:prod:build

# View production logs
npm run docker:prod:logs

# Stop production environment
npm run docker:prod:down
```

#### Step 3: Run Database Migrations (Production)

```bash
# Run migrations against Neon Cloud
DATABASE_URL="your-neon-cloud-url" npm run docker:migrate:prod
```

### 🛠️ Docker Commands Reference

| Command | Description |
|---------|-------------|
| `npm run docker:build` | Build application Docker image |
| `npm run docker:build:dev` | Build development image |
| `npm run docker:build:prod` | Build production image |
| `npm run docker:dev` | Start development environment |
| `npm run docker:dev:build` | Build and start development environment |
| `npm run docker:dev:down` | Stop development environment |
| `npm run docker:dev:logs` | View development logs |
| `npm run docker:prod` | Start production environment |
| `npm run docker:prod:build` | Build and start production environment |
| `npm run docker:prod:down` | Stop production environment |
| `npm run docker:prod:logs` | View production logs |
| `npm run docker:migrate:dev` | Run migrations in development |
| `npm run docker:migrate:prod` | Run migrations in production |
| `npm run docker:clean` | Clean up Docker resources |

### 🏧 Docker Architecture

#### Development Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    Development Environment                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                     │
│  │   Express App   │    │   Neon Local    │                     │
│  │   (Container)   │◄───┤   (Container)   │                     │
│  │   Port: 3000    │    │   Port: 5432    │                     │
│  └─────────────────┘    └─────────────────┘                     │
│           │                       │                             │
│           │                       ▼                             │
│           │              ┌─────────────────┐                    │
│           │              │  Neon Cloud     │                    │
│           │              │  (Ephemeral     │                    │
│           │              │   Branch)       │                    │
│           │              └─────────────────┘                    │
│           │                                                     │
│           ▼                                                     │
│    ┌─────────────────┐                                          │
│    │   Hot Reload    │                                          │
│    │   (Volume)      │                                          │
│    └─────────────────┘                                          │
└─────────────────────────────────────────────────────────────────┘
```

#### Production Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                     Production Environment                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐                                             │
│  │   Express App   │                                             │
│  │   (Container)   │                                             │
│  │   Port: 3000    │                                             │
│  └─────────────────┘                                             │
│           │                                                     │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                             │
│  │   Neon Cloud    │                                             │
│  │   Database      │                                             │
│  │   (Production)  │                                             │
│  └─────────────────┘                                             │
└─────────────────────────────────────────────────────────────────┘
```

### 🔐 Security Considerations

- **Non-root User**: Containers run as `nodejs` user (UID 1001)
- **Multi-stage Build**: Production images exclude development dependencies
- **Health Checks**: Built-in health monitoring
- **Resource Limits**: Production containers have CPU and memory limits
- **Secret Management**: Environment variables for sensitive data
- **SSL/TLS**: Enforced SSL connections to databases

### 🌐 Environment Variable Management

#### Development (.env.development)
```env
NODE_ENV=development
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb?sslmode=require
NEON_API_KEY=your-neon-api-key
NEON_PROJECT_ID=your-neon-project-id
PARENT_BRANCH_ID=main
JWT_SECRET=dev-jwt-secret
```

#### Production (Environment Variables)
```bash
export DATABASE_URL="postgresql://neondb_owner:password@host.neon.tech/neondb?sslmode=require"
export JWT_SECRET="production-jwt-secret"
export CORS_ORIGIN="https://yourdomain.com"
export LOG_LEVEL="info"
```

### 📝 Troubleshooting Docker Setup

#### Common Issues

1. **Neon Local Connection Issues:**
   ```bash
   # Check if Neon Local container is healthy
   docker ps
   docker logs acquisitions-neon-local
   
   # Verify your Neon credentials
   echo $NEON_API_KEY
   echo $NEON_PROJECT_ID
   ```

2. **Port Conflicts:**
   ```bash
   # Check what's using port 3000 or 5432
   netstat -tlnp | grep :3000
   netstat -tlnp | grep :5432
   ```

3. **Database Migration Issues:**
   ```bash
   # Check database connection
   npm run docker:migrate:dev
   
   # View migration logs
   docker logs acquisitions-migrate-dev
   ```

4. **Memory/Resource Issues:**
   ```bash
   # Check Docker resource usage
   docker stats
   
   # Clean up unused resources
   npm run docker:clean
   ```

## 🔌 API Endpoints

### Base URL
```
http://localhost:3000
```

### Health Check Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/`      | Basic health check |
| GET    | `/health`| Detailed health status |
| GET    | `/api`   | API status check |

### Authentication Endpoints

| Method | Endpoint | Description | Body |
|--------|----------|-------------|------|
| POST   | `/api/auth/sign-up` | User registration | `{name, email, password, role?}` |
| POST   | `/api/auth/sign-in` | User login | `{email, password}` |
| POST   | `/api/auth/sign-out` | User logout | None |

### API Request/Response Examples

#### User Registration
```bash
curl -X POST http://localhost:3000/api/auth/sign-up \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "user"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }
}
```

#### User Login
```bash
curl -X POST http://localhost:3000/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "User signed in successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }
}
```

#### User Logout
```bash
curl -X POST http://localhost:3000/api/auth/sign-out \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "success": true,
  "message": "User signed out successfully"
}
```

## 🔐 Authentication Flow

1. **Registration**: User provides name, email, password, and optional role
2. **Password Hashing**: Password is hashed using bcrypt with salt rounds
3. **User Creation**: User record is stored in PostgreSQL database
4. **JWT Generation**: JWT token is created with user ID, email, and role
5. **Cookie Setting**: JWT token is stored in secure HTTP-only cookie
6. **Login**: User provides email and password for authentication
7. **Password Verification**: Provided password is compared with stored hash
8. **Token Refresh**: New JWT token is generated and set in cookie
9. **Logout**: Authentication cookie is cleared from client

### Security Features
- ✅ Password hashing with bcrypt
- ✅ JWT tokens with expiration
- ✅ Secure HTTP-only cookies
- ✅ CORS protection
- ✅ Helmet security headers
- ✅ Input validation and sanitization

## 💻 Development

### Code Style
The project uses ESLint and Prettier for consistent code formatting:

```bash
# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Check formatting
npm run format-check

# Format code
npm run format
```

### Path Aliases
The project uses path aliases for clean imports:

```javascript
import logger from "#config/logger.js";
import {users} from "#models/user.model.js";
import {createUser} from "#services/auth.service.js";
```

### Adding New Features
1. Create models in `src/models/`
2. Add business logic in `src/services/`
3. Create controllers in `src/controllers/`
4. Define routes in `src/routes/`
5. Add validation schemas in `src/validations/`

## 📜 Scripts

### Local Development Scripts
| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server with auto-reload |
| `npm start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Fix ESLint issues |
| `npm run format` | Format code with Prettier |
| `npm run format-check` | Check code formatting |
| `npm run db:generate` | Generate database migrations |
| `npm run db:migrate` | Apply database migrations |
| `npm run db:studio` | Open Drizzle Studio |

### Docker Scripts
| Script | Description |
|--------|-------------|
| `npm run docker:build` | Build application Docker image |
| `npm run docker:build:dev` | Build development image |
| `npm run docker:build:prod` | Build production image |
| `npm run docker:dev` | Start development environment |
| `npm run docker:dev:build` | Build and start development environment |
| `npm run docker:dev:down` | Stop development environment |
| `npm run docker:dev:logs` | View development logs |
| `npm run docker:prod` | Start production environment |
| `npm run docker:prod:build` | Build and start production environment |
| `npm run docker:prod:down` | Stop production environment |
| `npm run docker:prod:logs` | View production logs |
| `npm run docker:migrate:dev` | Run migrations in development |
| `npm run docker:migrate:prod` | Run migrations in production |
| `npm run docker:clean` | Clean up Docker resources |

## 📊 Logging & Debugging

The application uses Winston for comprehensive logging with different outputs for development and production.

### Logging Configuration
- **Console Logs**: Development environment (colored output)
- **File Logs**: Both development and production
  - `logs/error.log` - Error level logs only
  - `logs/combined.log` - All log levels
- **HTTP Logs**: Morgan middleware logs all HTTP requests

### Log Levels
- `error` - Error conditions and exceptions
- `warn` - Warning conditions and potential issues
- `info` - Informational messages (default level)
- `debug` - Debug-level messages for troubleshooting

### Viewing Logs in Development

#### Local Development (`npm run dev`)
Logs appear directly in your terminal with colored output.

#### Docker Development
When using Docker containers, logs are captured differently:

**Real-time container logs:**
```powershell
# View live application logs
npm run docker:dev:logs

# Or directly with Docker
docker logs acquisitions-app-dev -f

# View last 100 lines
docker logs acquisitions-app-dev --tail 100 -f
```

**Log files (mounted to host):**
```powershell
# View error logs
Get-Content logs\error.log -Wait

# View all logs
Get-Content logs\combined.log -Wait

# View last 50 lines
Get-Content logs\combined.log -Tail 50
```

**Access container shell:**
```bash
# Using dev script (if on Linux/macOS)
./scripts/dev-docker.sh shell

# Or directly with Docker
docker exec -it acquisitions-app-dev /bin/sh
```

### What You'll See in Logs

**During sign-up requests:**
- Input validation logs
- User creation success/failure messages
- JWT token generation logs
- Database operation results

**During sign-in requests:**
- Authentication attempt logs
- Password verification results
- Session management logs

**Security events:**
- Rate limiting violations (when Arcjet middleware is enabled)
- Bot detection alerts
- Suspicious request patterns

### Debugging Tips

**Multiple terminal setup for Docker development:**
1. **Terminal 1**: `npm run docker:dev:build` (start containers)
2. **Terminal 2**: `npm run docker:dev:logs` (watch logs)
3. **Terminal 3**: Make API requests and test endpoints

**Check container health:**
```powershell
docker ps
docker-compose -f docker-compose.dev.yml ps
```

## 🛡️ Security Features

### Built-in Security
- **Helmet**: Security headers middleware for common vulnerabilities
- **CORS**: Cross-origin resource sharing protection
- **bcrypt**: Password hashing with 12 salt rounds
- **JWT**: Stateless authentication tokens with expiration
- **Secure Cookies**: HTTP-only, secure, SameSite cookies (15min expiry)
- **Input Validation**: Zod schema validation with type safety
- **SQL Injection Protection**: Drizzle ORM parameterized queries

### Arcjet Security Integration
The project includes Arcjet for enterprise-grade security:

- **Shield Protection**: Blocks common attacks (SQL injection, XSS)
- **Bot Detection**: Identifies and blocks automated requests
- **Rate Limiting**: Configurable request limits per user role:
  - Guest: 500 requests/minute
  - User: 1000 requests/minute  
  - Admin: 2000 requests/minute

**Note**: Security middleware is currently disabled in `app.js`. To enable:
```javascript
// Uncomment this line in src/app.js
app.use(SecurityMiddleware);
```

### Environment Variables for Security
```env
# Required
JWT_SECRET=your-super-secure-jwt-secret-change-in-production
DATABASE_URL=postgresql://...

# Optional Arcjet (for advanced security)
ARCJET_KEY=your-arcjet-api-key
```

## 🗃️ Database Schema

The application uses PostgreSQL with Drizzle ORM. Current schema:

### Users Table
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,  -- bcrypt hashed
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);
```

### Supported Roles
- `user` (default): Standard user access
- `admin`: Administrative access (future functionality)

## 🌐 Platform-Specific Instructions

### Windows Users (PowerShell)

**Recommended approach** - Use npm scripts instead of bash scripts:
```powershell
# Start development
npm run docker:dev:build

# View logs
npm run docker:dev:logs

# Stop environment
npm run docker:dev:down

# Run migrations
npm run docker:migrate:dev
```

**Alternative** - Using bash scripts (requires Git Bash or WSL):
```powershell
# Make scripts executable (one time setup)
bash ./scripts/setup.sh

# Run development commands
bash ./scripts/dev-docker.sh start
bash ./scripts/dev-docker.sh logs
```

### Linux/macOS Users

```bash
# Make scripts executable (one time setup)
chmod +x scripts/*.sh

# Use bash scripts directly
./scripts/dev-docker.sh start
./scripts/dev-docker.sh logs
./scripts/dev-docker.sh migrate
```

## 🧪 Testing the API

### Using cURL (PowerShell)

**Health check:**
```powershell
curl http://localhost:3000/health
```

**User registration:**
```powershell
curl -X POST http://localhost:3000/api/auth/sign-up `
  -H "Content-Type: application/json" `
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "user"
  }'
```

**User login:**
```powershell
curl -X POST http://localhost:3000/api/auth/sign-in `
  -H "Content-Type: application/json" `
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**User logout:**
```powershell
curl -X POST http://localhost:3000/api/auth/sign-out
```

### Expected Responses

**Successful registration/login:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }
}
```

**Validation error:**
```json
{
  "error": "Validation failed",
  "details": "Email is required, Password must be at least 6 characters"
}
```

## 📁 Project Structure Explained

### Core Application (`src/`)
```
src/
├── config/              # Infrastructure configuration
│   ├── database.js      # Neon DB + Drizzle ORM setup
│   ├── logger.js        # Winston logging configuration
│   └── arcjet.js        # Security service configuration
├── controllers/         # HTTP request handlers
│   └── auth.controller.js
├── services/           # Business logic layer
│   └── auth.service.js # User creation, authentication
├── models/             # Database schemas
│   └── user.model.js   # Drizzle user table definition
├── routes/             # API endpoint definitions
│   └── auth.routes.js  # Authentication routes
├── utils/              # Helper functions
│   ├── jwt.js          # JWT token utilities
│   ├── cookies.js      # Cookie management
│   └── format.js       # Error formatting
├── validations/        # Input validation schemas
│   └── auth.validation.js # Zod validation schemas
├── middleware/         # Request middleware
│   └── security.middleware.js # Arcjet integration
├── app.js              # Express application setup
├── server.js           # HTTP server startup
└── index.js            # Application entry point
```

### Support Files
```
drizzle/                # Database migrations
├── meta/               # Migration metadata
scripts/                # Deployment automation
├── dev-docker.sh       # Development Docker management
├── prod-docker.sh      # Production Docker management
└── setup.sh            # Script setup utility
logs/                   # Application logs (created at runtime)
├── error.log           # Error-level logs
└── combined.log        # All logs
```

## 🚀 Future Enhancements

Based on the current architecture, potential future additions:

### Authentication Extensions
- Password reset functionality
- Email verification
- Refresh token rotation
- Social login integration
- Multi-factor authentication

### API Extensions
- User profile management endpoints
- Role-based access control (RBAC)
- API versioning strategy
- Pagination for list endpoints

### Infrastructure
- Redis for session management
- API documentation with Swagger
- Automated testing suite
- CI/CD pipeline configuration
- Monitoring and observability

### Acquisition-Specific Features
- Company/deal management
- Document management
- Workflow automation
- Notification system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure all tests pass

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email [your-email@example.com] or create an issue in the repository.

---

**Built with ❤️ using Node.js and Express.js**