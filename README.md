# GoogleCrawler 👾

**GoogleCrawler** is a web application built with **Elixir** and **Phoenix** framework providing search result scraping and parsing to generate the report.

- 👮‍♀️ Google OAuth authentication.
- 📝 Support single keyword input or bulk keywords uploaded in .csv format.
- 📫 API endpoints for CRUD operation.
- 🔎 Keyword searching with multiple filter options (By keyword title, search result URL, amount of result, and ads contain in search result)
- ⚡️ Integrate with Github action for testing and deploying to Staging and Production environment

### Live application demo

- Staging: https://google-result-crawler-staging.herokuapp.com/

- Production: https://google-result-crawler.herokuapp.com/

## Get started

### Requirements

- Docker
- Elixir > 1.10.4
- Chromedriver

### Setup

Setup the development environment with docker
```
docker-compose -f docker-compose.dev.yml up -d
```

Install dependencies
```
mix deps.get
```

Setup and migrate database
```
mix ecto.setup
```

Install Node.js dependencies inside assets directory
```
cd assets
npm install
```
 
Start Phoenix application at `localhost:4000`
```
mix phx.server
```

Check [Postman collection](https://documenter.getpostman.com/view/2327735/TVmTdFRF) for API endpoints detail.
## Test

After Chromedriver is installed, to run UI testing and Unit testing simply run
```
mix test
```