#!/usr/bin/env python3
"""
Chroma MCP Server
A Model Context Protocol server for Chroma vector database operations.
"""

import asyncio
import json
import logging
import os
import sys
from typing import Any, Dict, List, Optional, Sequence
from pathlib import Path

import chromadb
from chromadb.config import Settings
from pydantic import BaseModel

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChromaMCPConfig(BaseModel):
    """Configuration for Chroma MCP Server"""
    persist_directory: str = "./chroma_db"
    host: str = "localhost"
    port: int = 8000
    collection_name: str = "default_collection"

class ChromaMCPServer:
    """Chroma MCP Server implementation"""
    
    def __init__(self, config: ChromaMCPConfig):
        self.config = config
        self.client = None
        self.collection = None
        self.server = Server("chroma-mcp-server")
        self._setup_handlers()
    
    def _setup_handlers(self):
        """Set up MCP server handlers"""
        
        @self.server.list_tools()
        async def handle_list_tools() -> List[Tool]:
            """List available tools"""
            return [
                Tool(
                    name="create_collection",
                    description="Create a new Chroma collection",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "name": {
                                "type": "string",
                                "description": "Name of the collection to create"
                            },
                            "metadata": {
                                "type": "object",
                                "description": "Optional metadata for the collection"
                            }
                        },
                        "required": ["name"]
                    }
                ),
                Tool(
                    name="add_documents",
                    description="Add documents to a Chroma collection",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "collection_name": {
                                "type": "string",
                                "description": "Name of the collection"
                            },
                            "documents": {
                                "type": "array",
                                "items": {"type": "string"},
                                "description": "List of documents to add"
                            },
                            "metadatas": {
                                "type": "array",
                                "items": {"type": "object"},
                                "description": "Optional metadata for each document"
                            },
                            "ids": {
                                "type": "array",
                                "items": {"type": "string"},
                                "description": "Optional IDs for each document"
                            }
                        },
                        "required": ["collection_name", "documents"]
                    }
                ),
                Tool(
                    name="query_collection",
                    description="Query a Chroma collection using semantic search",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "collection_name": {
                                "type": "string",
                                "description": "Name of the collection to query"
                            },
                            "query_texts": {
                                "type": "array",
                                "items": {"type": "string"},
                                "description": "List of query texts"
                            },
                            "n_results": {
                                "type": "integer",
                                "description": "Number of results to return",
                                "default": 10
                            },
                            "where": {
                                "type": "object",
                                "description": "Optional metadata filter"
                            }
                        },
                        "required": ["collection_name", "query_texts"]
                    }
                ),
                Tool(
                    name="list_collections",
                    description="List all Chroma collections",
                    inputSchema={
                        "type": "object",
                        "properties": {}
                    }
                ),
                Tool(
                    name="delete_collection",
                    description="Delete a Chroma collection",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "collection_name": {
                                "type": "string",
                                "description": "Name of the collection to delete"
                            }
                        },
                        "required": ["collection_name"]
                    }
                ),
                Tool(
                    name="get_collection_info",
                    description="Get information about a specific collection",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "collection_name": {
                                "type": "string",
                                "description": "Name of the collection"
                            }
                        },
                        "required": ["collection_name"]
                    }
                )
            ]
        
        @self.server.call_tool()
        async def handle_call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
            """Handle tool calls"""
            try:
                if name == "create_collection":
                    return await self._create_collection(arguments)
                elif name == "add_documents":
                    return await self._add_documents(arguments)
                elif name == "query_collection":
                    return await self._query_collection(arguments)
                elif name == "list_collections":
                    return await self._list_collections(arguments)
                elif name == "delete_collection":
                    return await self._delete_collection(arguments)
                elif name == "get_collection_info":
                    return await self._get_collection_info(arguments)
                else:
                    return [TextContent(type="text", text=f"Unknown tool: {name}")]
            except Exception as e:
                logger.error(f"Error handling tool {name}: {e}")
                return [TextContent(type="text", text=f"Error: {str(e)}")]
    
    async def _initialize_chroma(self):
        """Initialize Chroma client"""
        try:
            # Create persist directory if it doesn't exist
            os.makedirs(self.config.persist_directory, exist_ok=True)
            
            # Initialize Chroma client
            self.client = chromadb.PersistentClient(
                path=self.config.persist_directory,
                settings=Settings(
                    anonymized_telemetry=False,
                    allow_reset=True
                )
            )
            logger.info(f"Chroma client initialized with persist directory: {self.config.persist_directory}")
        except Exception as e:
            logger.error(f"Failed to initialize Chroma client: {e}")
            raise
    
    async def _create_collection(self, arguments: Dict[str, Any]) -> List[TextContent]:
        """Create a new collection"""
        name = arguments.get("name")
        metadata = arguments.get("metadata", {})
        
        if not name:
            return [TextContent(type="text", text="Error: Collection name is required")]
        
        try:
            collection = self.client.create_collection(
                name=name,
                metadata=metadata
            )
            return [TextContent(
                type="text", 
                text=f"Successfully created collection '{name}' with {collection.count()} documents"
            )]
        except Exception as e:
            return [TextContent(type="text", text=f"Error creating collection: {str(e)}")]
    
    async def _add_documents(self, arguments: Dict[str, Any]) -> List[TextContent]:
        """Add documents to a collection"""
        collection_name = arguments.get("collection_name")
        documents = arguments.get("documents", [])
        metadatas = arguments.get("metadatas")
        ids = arguments.get("ids")
        
        if not collection_name or not documents:
            return [TextContent(type="text", text="Error: Collection name and documents are required")]
        
        try:
            collection = self.client.get_collection(collection_name)
            
            # Prepare arguments for add
            add_kwargs = {"documents": documents}
            if metadatas:
                add_kwargs["metadatas"] = metadatas
            if ids:
                add_kwargs["ids"] = ids
            
            result = collection.add(**add_kwargs)
            return [TextContent(
                type="text", 
                text=f"Successfully added {len(documents)} documents to collection '{collection_name}'"
            )]
        except Exception as e:
            return [TextContent(type="text", text=f"Error adding documents: {str(e)}")]
    
    async def _query_collection(self, arguments: Dict[str, Any]) -> List[TextContent]:
        """Query a collection"""
        collection_name = arguments.get("collection_name")
        query_texts = arguments.get("query_texts", [])
        n_results = arguments.get("n_results", 10)
        where = arguments.get("where")
        
        if not collection_name or not query_texts:
            return [TextContent(type="text", text="Error: Collection name and query texts are required")]
        
        try:
            collection = self.client.get_collection(collection_name)
            
            # Prepare query arguments
            query_kwargs = {
                "query_texts": query_texts,
                "n_results": n_results
            }
            if where:
                query_kwargs["where"] = where
            
            results = collection.query(**query_kwargs)
            
            # Format results
            formatted_results = []
            for i, query in enumerate(query_texts):
                formatted_results.append(f"Query: {query}")
                if i < len(results['documents']):
                    for j, doc in enumerate(results['documents'][i]):
                        distance = results['distances'][i][j] if 'distances' in results else "N/A"
                        formatted_results.append(f"  Result {j+1} (distance: {distance}): {doc}")
                formatted_results.append("")
            
            return [TextContent(type="text", text="\n".join(formatted_results))]
        except Exception as e:
            return [TextContent(type="text", text=f"Error querying collection: {str(e)}")]
    
    async def _list_collections(self, arguments: Dict[str, Any]) -> List[TextContent]:
        """List all collections"""
        try:
            collections = self.client.list_collections()
            if not collections:
                return [TextContent(type="text", text="No collections found")]
            
            collection_info = []
            for collection in collections:
                collection_info.append(f"- {collection.name} (id: {collection.id})")
                try:
                    count = collection.count()
                    collection_info.append(f"  Documents: {count}")
                except:
                    collection_info.append("  Documents: Unable to count")
                collection_info.append("")
            
            return [TextContent(type="text", text="\n".join(collection_info))]
        except Exception as e:
            return [TextContent(type="text", text=f"Error listing collections: {str(e)}")]
    
    async def _delete_collection(self, arguments: Dict[str, Any]) -> List[TextContent]:
        """Delete a collection"""
        collection_name = arguments.get("collection_name")
        
        if not collection_name:
            return [TextContent(type="text", text="Error: Collection name is required")]
        
        try:
            self.client.delete_collection(collection_name)
            return [TextContent(type="text", text=f"Successfully deleted collection '{collection_name}'")]
        except Exception as e:
            return [TextContent(type="text", text=f"Error deleting collection: {str(e)}")]
    
    async def _get_collection_info(self, arguments: Dict[str, Any]) -> List[TextContent]:
        """Get collection information"""
        collection_name = arguments.get("collection_name")
        
        if not collection_name:
            return [TextContent(type="text", text="Error: Collection name is required")]
        
        try:
            collection = self.client.get_collection(collection_name)
            count = collection.count()
            metadata = collection.metadata or {}
            
            info = [
                f"Collection: {collection_name}",
                f"ID: {collection.id}",
                f"Document count: {count}",
                f"Metadata: {json.dumps(metadata, indent=2)}"
            ]
            
            return [TextContent(type="text", text="\n".join(info))]
        except Exception as e:
            return [TextContent(type="text", text=f"Error getting collection info: {str(e)}")]
    
    async def run(self):
        """Run the MCP server"""
        await self._initialize_chroma()
        
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(
                read_stream,
                write_stream,
                InitializationOptions(
                    server_name="chroma-mcp-server",
                    server_version="1.0.0",
                    capabilities=self.server.get_capabilities(
                        notification_options=None,
                        experimental_capabilities={}
                    )
                )
            )

async def main():
    """Main entry point"""
    # Load configuration from environment or use defaults
    config = ChromaMCPConfig(
        persist_directory=os.getenv("CHROMA_PERSIST_DIR", "./chroma_db"),
        host=os.getenv("CHROMA_HOST", "localhost"),
        port=int(os.getenv("CHROMA_PORT", "8000")),
        collection_name=os.getenv("CHROMA_COLLECTION", "default_collection")
    )
    
    server = ChromaMCPServer(config)
    await server.run()

if __name__ == "__main__":
    asyncio.run(main())
