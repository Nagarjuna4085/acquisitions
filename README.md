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

## 📊 Logging

The application uses Winston for comprehensive logging:

- **Console Logs**: Development environment
- **File Logs**: Production environment
  - `logs/error.log` - Error level logs
  - `logs/combined.log` - All logs

### Log Levels
- `error` - Error conditions
- `warn` - Warning conditions  
- `info` - Informational messages
- `debug` - Debug-level messages

## 🛡️ Security Features

- **Helmet**: Security headers middleware
- **CORS**: Cross-origin resource sharing protection
- **bcrypt**: Password hashing with salt
- **JWT**: Stateless authentication tokens
- **Secure Cookies**: HTTP-only, secure, SameSite cookies
- **Input Validation**: Zod schema validation
- **SQL Injection Protection**: Drizzle ORM query builder

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