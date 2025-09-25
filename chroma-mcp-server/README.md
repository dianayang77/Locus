# Chroma MCP Server

A Model Context Protocol (MCP) server for Chroma vector database operations. This server enables AI assistants to interact with Chroma collections for document storage, retrieval, and semantic search.

## Features

- **Collection Management**: Create, list, and delete Chroma collections
- **Document Operations**: Add documents with optional metadata and IDs
- **Semantic Search**: Query collections using vector similarity search
- **Metadata Filtering**: Filter results based on document metadata
- **Persistent Storage**: Data persists across server restarts
- **MCP Compatible**: Works with Cursor, Claude Desktop, and other MCP clients

## Installation

1. **Install Python Dependencies**:
   ```bash
   cd chroma-mcp-server
   pip3 install -r requirements.txt
   ```

2. **Set up Environment** (Optional):
   ```bash
   cp config.env.example .env
   # Edit .env with your preferred settings
   ```

## Usage

### Testing the Server

```bash
python3 test_mcp_server.py
```

### Starting the Server Manually

```bash
python3 mcp_chroma_server.py
```

The server will start and listen for MCP client connections via stdio.

### Available Tools

1. **create_collection**: Create a new Chroma collection
2. **add_documents**: Add documents to a collection
3. **query_collection**: Perform semantic search on a collection
4. **list_collections**: List all available collections
5. **delete_collection**: Delete a collection
6. **get_collection_info**: Get detailed information about a collection

## MCP Client Configuration

### For Cursor/Windsurf IDEs

1. Open Cursor settings
2. Navigate to `MCP & Integration` → `MCP Tools`
3. Add the configuration from `mcp_config.json`
4. Save changes

### For Claude Desktop

Edit your Claude Desktop configuration file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

Add the configuration from `mcp_config.json`.

### For JetBrains AI Assistant

1. Go to Settings → Tools → AI Assistant → MCP
2. Click "+" to open the Add dialog
3. Switch from "Command" to "As JSON"
4. Paste the configuration from `mcp_config.json`
5. Set the working directory to this project location

## Configuration

The server can be configured using environment variables:

- `CHROMA_PERSIST_DIR`: Directory for persistent storage (default: `./chroma_db`)
- `CHROMA_HOST`: Host address (default: `localhost`)
- `CHROMA_PORT`: Port number (default: `8000`)
- `CHROMA_COLLECTION`: Default collection name (default: `default_collection`)
- `DEBUG`: Enable debug logging (default: `false`)

## Example Usage

Once configured with an MCP client, you can use commands like:

- "Create a collection called 'documents'"
- "Add these documents to the 'documents' collection: [list of documents]"
- "Search the 'documents' collection for 'machine learning'"
- "List all collections"
- "Get information about the 'documents' collection"

## Data Storage

The server uses Chroma's persistent client, so all data is stored locally in the `chroma_db` directory. This data persists across server restarts.

## Troubleshooting

1. **Import Errors**: Ensure all dependencies are installed with `pip install -r requirements.txt`
2. **Permission Errors**: Check that the server has write permissions to the persist directory
3. **Connection Issues**: Verify the MCP client configuration matches the server setup

## License

This project follows the same license as the Locus project.

