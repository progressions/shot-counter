# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing

**IMPORTANT: RVM/Ruby Environment Setup**
This project uses RVM with Ruby 3.2.2. To run specs successfully, you MUST use this exact command format:

```bash
source ~/.rvm/scripts/rvm && rvm use 3.2.2 && bundle exec rspec [spec_path]
```

**Working Commands:**
- `source ~/.rvm/scripts/rvm && rvm use 3.2.2 && bundle exec rspec` - Run the full test suite
- `source ~/.rvm/scripts/rvm && rvm use 3.2.2 && bundle exec rspec spec/models/` - Run model tests only
- `source ~/.rvm/scripts/rvm && rvm use 3.2.2 && bundle exec rspec spec/controllers/` - Run controller tests only
- `source ~/.rvm/scripts/rvm && rvm use 3.2.2 && bundle exec rspec spec/path/to/specific_spec.rb` - Run a specific test file

**Note:** Just running `bundle exec rspec` without the RVM setup will fail with LoadError: cannot load such file -- rubygems/uri

**Ruby Version:** 3.2.2 (specified in .ruby-version file)

### Database
- `rails db:migrate` - Run pending migrations
- `rails db:seed` - Seed the database with initial data
- `rails db:reset` - Drop, create, migrate and seed the database
- `rails db:rollback` - Rollback the last migration

### Development Server
- `rails server` or `rails s` - Start the development server (default port 3000)
- `bundle exec sidekiq` - Start background job processing

### Discord Bot Commands
- `rails discord:register_commands` - Register Discord slash commands with the Discord API

### Rails Console and Debugging
- `rails console` or `rails c` - Start Rails console for debugging and data exploration
- `rails routes` - View all available routes

## Architecture Overview

This is a Ruby on Rails 8.0 API-only application serving as the backend for Chi War, a character and campaign manager for the Feng Shui 2 tabletop RPG. The app uses PostgreSQL as the primary database and Redis for caching and background jobs.

### Key Technologies
- **Rails 8.0** - Web framework
- **PostgreSQL** - Primary database
- **Redis** - Caching and job queue
- **Sidekiq** - Background job processing
- **Devise + JWT** - Authentication
- **Active Model Serializers** - JSON serialization
- **Discordrb** - Discord bot integration
- **Notion API** - External integration for character syncing

### API Structure
The application exposes two main API versions:
- `/api/v1/` - Legacy API with comprehensive endpoints
- `/api/v2/` - Newer API with simplified structure

Both APIs are RESTful and return JSON responses.

### Core Domain Models

**Campaigns** - Top-level containers for games. Users can be gamemasters (full access) or players (limited access).

**Characters** - Central to the game system. Multiple types:
- Player Characters (PCs)
- Non-Player Characters (NPCs) 
- Bosses, Featured Foes, Mooks, Allies (different antagonist/ally types)
- Each type has different relevant statistics and capabilities

**Fights** - Combat encounters that track initiative and actions using a "shot counter" system unique to Feng Shui 2.

**Shots** - The initiative/action tracking system. Characters act on numbered "shots" counting down from ~20 to 0.

**Vehicles** - Similar to characters but for vehicle chase scenes. Have their own stats and can participate in fights.

**Schticks** - Character abilities/talents with prerequisite relationships.

**Weapons** - Equipment that characters can carry and use in fights.

**Junctures** - Time periods in the Feng Shui 2 universe.

**Sites, Parties, Factions** - Campaign organization and world-building elements.

### Authentication & Authorization
- Uses Devise with JWT tokens for API authentication
- Users have roles: admin, gamemaster, player
- Campaign-based authorization - users can only access data from campaigns they're members of
- Current campaign context stored in Redis and set via `CurrentCampaign` service

### Background Jobs
Sidekiq handles background processing for:
- AI character creation and updates
- Discord notifications
- Notion API synchronization
- Image processing

### Discord Bot Integration
The app serves as a backend for Discord bot commands that allow:
- Starting and managing fights
- Displaying character and fight status
- Rolling dice
- Basic campaign management

### File Storage & Images
- Uses Active Storage with S3 backend (AWS)
- ImageKit integration for image processing and CDN
- PDF generation for character sheets

### Performance Considerations
- Database indexes optimized for common queries (see recent migrations)
- Uses bullet gem in development to detect N+1 queries
- Pagination implemented with Kaminari
- Redis caching for frequently accessed data

### Development Notes
- RSpec for testing with focus on models and controllers
- Pry for debugging in development
- Letter opener for email testing in development
- The codebase follows Rails conventions and uses Active Model Serializers for consistent JSON output