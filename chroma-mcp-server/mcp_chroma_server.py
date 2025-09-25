#!/usr/bin/env python3
"""
MCP Chroma Server
A Model Context Protocol server for Chroma vector database operations.
This version works with MCP clients like Cursor.
"""

import asyncio
import json
import logging
import os
import sys
from typing import Any, Dict, List, Optional
from pathlib import Path

import chromadb
from chromadb.config import Settings
from pydantic import BaseModel

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChromaConfig(BaseModel):
    """Configuration for Chroma Server"""
    persist_directory: str = "./chroma_db"
    host: str = "localhost"
    port: int = 8000
    collection_name: str = "default_collection"

class MCPChromaServer:
    """MCP Chroma Server implementation"""
    
    def __init__(self, config: ChromaConfig):
        self.config = config
        self.client = None
        self.collection = None
    
    async def initialize_chroma(self):
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
    
    def handle_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Handle MCP-style requests"""
        try:
            method = request.get("method")
            params = request.get("params", {})
            
            if method == "create_collection":
                return self.create_collection_sync(params.get("name"), params.get("metadata"))
            elif method == "add_documents":
                return self.add_documents_sync(
                    params.get("collection_name"),
                    params.get("documents", []),
                    params.get("metadatas"),
                    params.get("ids")
                )
            elif method == "query_collection":
                return self.query_collection_sync(
                    params.get("collection_name"),
                    params.get("query_texts", []),
                    params.get("n_results", 10),
                    params.get("where")
                )
            elif method == "list_collections":
                return self.list_collections_sync()
            elif method == "delete_collection":
                return self.delete_collection_sync(params.get("collection_name"))
            elif method == "get_collection_info":
                return self.get_collection_info_sync(params.get("collection_name"))
            else:
                return {"error": f"Unknown method: {method}"}
        except Exception as e:
            return {"error": str(e)}
    
    def create_collection_sync(self, name: str, metadata: Dict[str, Any] = None) -> Dict[str, Any]:
        """Create a new collection (synchronous)"""
        try:
            if not metadata:
                metadata = {"created_by": "chroma_mcp_server"}
            
            collection = self.client.create_collection(
                name=name,
                metadata=metadata
            )
            return {
                "success": True,
                "message": f"Successfully created collection '{name}'",
                "collection_id": str(collection.id),
                "count": collection.count()
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Error creating collection: {str(e)}"
            }
    
    def add_documents_sync(self, collection_name: str, documents: List[str], 
                          metadatas: List[Dict[str, Any]] = None, 
                          ids: List[str] = None) -> Dict[str, Any]:
        """Add documents to a collection (synchronous)"""
        try:
            collection = self.client.get_collection(collection_name)
            
            # Prepare arguments for add
            add_kwargs = {"documents": documents}
            if metadatas:
                add_kwargs["metadatas"] = metadatas
            if ids:
                add_kwargs["ids"] = ids
            
            result = collection.add(**add_kwargs)
            return {
                "success": True,
                "message": f"Successfully added {len(documents)} documents to collection '{collection_name}'"
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Error adding documents: {str(e)}"
            }
    
    def query_collection_sync(self, collection_name: str, query_texts: List[str], 
                             n_results: int = 10, where: Dict[str, Any] = None) -> Dict[str, Any]:
        """Query a collection (synchronous)"""
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
                query_result = {
                    "query": query,
                    "results": []
                }
                if i < len(results['documents']):
                    for j, doc in enumerate(results['documents'][i]):
                        distance = results['distances'][i][j] if 'distances' in results else None
                        result_item = {
                            "document": doc,
                            "distance": distance,
                            "metadata": results['metadatas'][i][j] if 'metadatas' in results and i < len(results['metadatas']) and j < len(results['metadatas'][i]) else None
                        }
                        query_result["results"].append(result_item)
                formatted_results.append(query_result)
            
            return {
                "success": True,
                "results": formatted_results
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Error querying collection: {str(e)}"
            }
    
    def list_collections_sync(self) -> Dict[str, Any]:
        """List all collections (synchronous)"""
        try:
            collections = self.client.list_collections()
            collection_info = []
            for collection in collections:
                try:
                    count = collection.count()
                    collection_info.append({
                        "name": collection.name,
                        "id": str(collection.id),
                        "count": count,
                        "metadata": collection.metadata
                    })
                except:
                    collection_info.append({
                        "name": collection.name,
                        "id": str(collection.id),
                        "count": "Unable to count",
                        "metadata": collection.metadata
                    })
            
            return {
                "success": True,
                "collections": collection_info
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Error listing collections: {str(e)}"
            }
    
    def delete_collection_sync(self, collection_name: str) -> Dict[str, Any]:
        """Delete a collection (synchronous)"""
        try:
            self.client.delete_collection(collection_name)
            return {
                "success": True,
                "message": f"Successfully deleted collection '{collection_name}'"
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Error deleting collection: {str(e)}"
            }
    
    def get_collection_info_sync(self, collection_name: str) -> Dict[str, Any]:
        """Get collection information (synchronous)"""
        try:
            collection = self.client.get_collection(collection_name)
            count = collection.count()
            metadata = collection.metadata or {}
            
            return {
                "success": True,
                "collection": {
                    "name": collection_name,
                    "id": str(collection.id),
                    "count": count,
                    "metadata": metadata
                }
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Error getting collection info: {str(e)}"
            }
    
    async def run_stdio_server(self):
        """Run the server using stdio for MCP communication"""
        await self.initialize_chroma()
        
        # Simple stdio-based MCP server
        while True:
            try:
                # Read request from stdin
                line = sys.stdin.readline()
                if not line:
                    break
                
                request = json.loads(line.strip())
                response = self.handle_request(request)
                
                # Write response to stdout
                print(json.dumps(response))
                sys.stdout.flush()
                
            except json.JSONDecodeError as e:
                error_response = {"error": f"Invalid JSON: {str(e)}"}
                print(json.dumps(error_response))
                sys.stdout.flush()
            except Exception as e:
                error_response = {"error": str(e)}
                print(json.dumps(error_response))
                sys.stdout.flush()

async def main():
    """Main entry point"""
    # Load configuration from environment or use defaults
    config = ChromaConfig(
        persist_directory=os.getenv("CHROMA_PERSIST_DIR", "./chroma_db"),
        host=os.getenv("CHROMA_HOST", "localhost"),
        port=int(os.getenv("CHROMA_PORT", "8000")),
        collection_name=os.getenv("CHROMA_COLLECTION", "default_collection")
    )
    
    server = MCPChromaServer(config)
    await server.run_stdio_server()

if __name__ == "__main__":
    asyncio.run(main())
