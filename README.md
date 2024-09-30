# nest.shell

nest.shell is a lightweight, customizable web server and application framework written in Bash. It provides a simple yet powerful way to create dynamic web applications using shell scripts.

Wow it even includes a working TODO list app:

![todo app example](https://i.ibb.co/ZmHVdFx/2024-09-29-22-06.png)


## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Directory Structure](#directory-structure)
6. [Usage](#usage)
7. [API Endpoints](#api-endpoints)
8. [Database](#database)
9. [Customization](#customization)
10. [Troubleshooting](#troubleshooting)
11. [Contributing](#contributing)
12. [License](#license)

## Features

- Lightweight and fast
- Easy to set up and customize
- Built-in routing system
- Support for API endpoints
- SQLite database integration
- Tailwind CSS integration
- Dynamic content rendering
- Nested content support
- Logging system

## Requirements

- Bash
- SQLite3
- socat
- A web browser

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/nest.shell.git
   cd nest.shell
   sudo apt install socat jq sqlite
   PORT 8080 ./nest.sh
   ```

## Configuration

The main configuration options are at the top of the `nest.shell.sh` script:

- `PORT`: The port on which the server will run (default: 8080)
- `CONTENT_DIR`: The directory containing your application's content (default: "./content")
- `CACHE_DIR`: The directory for caching (default: "./cache")
- `DB_FILE`: The SQLite database file (default: "./app.db")

You can modify these variables directly in the script or set them as environment variables before running the script.

## Directory Structure

```
nest.shell/
├── nest.shell.sh
├── content/
│   ├── index.html
│   ├── index.js
│   └── api/
│       └── example.api.sh
├── cache/
└── app.db
```

- `nest.shell.sh`: The main server script
- `content/`: Directory for your application's content
- `content/index.html`: Main template for your application
- `content/index.js`: Global JavaScript file
- `content/api/`: Directory for API endpoints
- `cache/`: Directory for caching (created automatically)
- `app.db`: SQLite database file (created automatically)

## Usage

To start the server, run:

```
PORT 8080=./nest.shell.sh
```

The server will start on `http://localhost:8080` (or the port you've configured).

## API Endpoints

To create an API endpoint, add a `.api.sh` file in the `content/api/` directory. For example:

```bash
# content/api/example.api.sh
#!/bin/bash

echo "HTTP/1.1 200 OK
echo "Content-Type: application/json"
echo ""
echo '{"message": "Hello from the API!"}'
```

This endpoint will be accessible at `/api/example`.

## Database

The server uses SQLite for data storage. The database file is created automatically when you start the server. You can interact with the database using SQL queries in your API endpoints or content scripts.

Example of using the database in an API endpoint:

```bash
#!/bin/bash

# Get all todos
result=$(sqlite3 "$DB_FILE" "SELECT * FROM todos;")

echo "Content-Type: application/json"
echo ""
echo "$result" | jq -R 'split("|") | {id: .[0], task: .[1], completed: .[2]}'
```

## Customization

### Adding New Routes

To add a new route, create a directory in the `content/` folder with the desired route name. For example, to create a `/about` route, make a directory `content/about/`.

### Creating Dynamic Content

To generate dynamic content, create a `script.sh` file in the route's directory. The output of this script will be used as the content for that route.

### Styling

The server includes Tailwind CSS by default. You can use Tailwind classes in your HTML to style your content.

## Troubleshooting

- If you encounter permission issues, make sure all `.sh` files are executable (`chmod +x *.sh`).
- Check the log file (default: `./nest.shell.log`) for any error messages or debugging information.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [BSD License](LICENSE).


